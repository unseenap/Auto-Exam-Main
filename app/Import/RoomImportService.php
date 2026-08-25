<?php

declare(strict_types=1);

namespace App\Import;

use App\Rooms\RoomSeatGenerator;
use PDO;
use RuntimeException;

final class RoomImportService
{
    public function __construct(private readonly PDO $pdo) {}

    public function stage(string $path,string $originalName,int $userId): int
    {
        $rows=(new TabularReader())->read($path,strtolower(pathinfo($originalName,PATHINFO_EXTENSION)));
        if(count($rows)<2)throw new RuntimeException('The file must contain a header and at least one room row.');
        $headers=array_map([$this,'headerKey'],array_shift($rows));
        foreach(['room_code','building','rows','columns'] as $required)if(!in_array($required,$headers,true))throw new RuntimeException("Missing required column: {$required}.");
        $q=$this->pdo->prepare("INSERT INTO import_batches(import_type,original_filename,stored_filename,status,uploaded_by) VALUES('rooms',:original,:stored,'validating',:user)");
        $q->execute(['original'=>$originalName,'stored'=>basename($path),'user'=>$userId]);$batch=(int)$this->pdo->lastInsertId();$valid=0;$invalid=0;$seen=[];
        $insert=$this->pdo->prepare('INSERT INTO import_rows(import_batch_id,source_row_number,source_data,normalized_data,validation_status,validation_messages) VALUES(:batch,:row,:source,:normalized,:status,:messages)');
        foreach($rows as $index=>$values){$source=[];foreach($headers as $column=>$header)if($header!=='')$source[$header]=trim((string)($values[$column]??''));$messages=[];
            $code=strtoupper(trim($source['room_code']??''));$building=trim($source['building']??'');$rowCount=(int)($source['rows']??0);$columnCount=(int)($source['columns']??0);
            $order=strtolower(trim($source['seat_order']??''))?:'column_major';$order=['row'=>'row_major','column'=>'column_major'][$order]??$order;
            $priority=trim($source['priority']??'')===''?100:(int)$source['priority'];$status=strtolower(trim($source['status']??''))?:'active';
            if($code==='')$messages[]='Room code is required.';if($building==='')$messages[]='Building is required.';
            if($rowCount<1||$rowCount>100)$messages[]='Rows must be between 1 and 100.';if($columnCount<1||$columnCount>100)$messages[]='Columns must be between 1 and 100.';
            if(!in_array($order,['row_major','column_major'],true))$messages[]='Seat order must be row_major or column_major.';
            if($priority<1||$priority>65535)$messages[]='Priority must be between 1 and 65535.';if(!in_array($status,['active','inactive','maintenance'],true))$messages[]='Invalid room status.';
            if(isset($seen[$code]))$messages[]='Room code is duplicated in this file.';$seen[$code]=true;
            $dup=$this->pdo->prepare('SELECT COUNT(*) FROM rooms WHERE code=:code');$dup->execute(['code'=>$code]);if((int)$dup->fetchColumn())$messages[]='Room code already exists.';
            [$blocked,$blockedErrors]=$this->blockedCoordinates($source['disabled_seat_numbers']??'',max(0,$rowCount),max(0,$columnCount));array_push($messages,...$blockedErrors);
            $data=['code'=>$code,'building'=>$building,'floor'=>trim($source['floor']??'')?:null,'rows_count'=>$rowCount,'columns_count'=>$columnCount,'physical_capacity'=>$rowCount*$columnCount,
                'usable_capacity'=>max(0,$rowCount*$columnCount-count($blocked)),'seat_order'=>$order,'priority'=>$priority?:100,'status'=>$status,'notes'=>trim($source['notes']??'')?:null,'blocked'=>$blocked];
            $validation=$messages?'invalid':'valid';$messages?$invalid++:$valid++;$insert->execute(['batch'=>$batch,'row'=>$index+2,'source'=>json_encode($source),'normalized'=>json_encode($data),'status'=>$validation,'messages'=>json_encode($messages)]);
        }
        $this->pdo->prepare("UPDATE import_batches SET status='review',total_rows=:total,valid_rows=:valid,invalid_rows=:invalid WHERE id=:id")->execute(['total'=>count($rows),'valid'=>$valid,'invalid'=>$invalid,'id'=>$batch]);return $batch;
    }

    public function commit(int $batchId,int $userId): int
    {
        $q=$this->pdo->prepare("SELECT * FROM import_batches WHERE id=:id AND import_type='rooms' AND status='review' FOR UPDATE");$q->execute(['id'=>$batchId]);if(!$q->fetch())throw new RuntimeException('Room import is not available for commit.');
        $q=$this->pdo->prepare("SELECT * FROM import_rows WHERE import_batch_id=:id AND validation_status='valid' ORDER BY source_row_number");$q->execute(['id'=>$batchId]);$count=0;
        $insert=$this->pdo->prepare('INSERT INTO rooms(code,building,floor,rows_count,columns_count,physical_capacity,usable_capacity,seat_order,priority,status,notes) VALUES(:code,:building,:floor,:rows_count,:columns_count,:physical_capacity,:usable_capacity,:seat_order,:priority,:status,:notes)');
        foreach($q as $row){$data=json_decode($row['normalized_data'],true,flags:JSON_THROW_ON_ERROR);$blocked=$data['blocked'];unset($data['blocked']);$insert->execute($data);$roomId=(int)$this->pdo->lastInsertId();(new RoomSeatGenerator($this->pdo))->regenerate($roomId,(int)$data['rows_count'],(int)$data['columns_count'],$data['seat_order'],$blocked);$this->pdo->prepare('UPDATE import_rows SET committed_entity_id=:entity WHERE id=:id')->execute(['entity'=>$roomId,'id'=>$row['id']]);$count++;}
        $this->pdo->prepare("UPDATE import_batches SET status='committed',committed_at=NOW() WHERE id=:id")->execute(['id'=>$batchId]);
        $this->pdo->prepare("INSERT INTO audit_logs(user_id,action,entity_type,entity_id,new_values) VALUES(:user,'room_import.committed','import_batch',:id,:data)")->execute(['user'=>$userId,'id'=>$batchId,'data'=>json_encode(['rooms_created'=>$count])]);return $count;
    }

    private function blockedCoordinates(string $value,int $rows,int $columns): array
    {
        $blocked=[];$errors=[];$tokens=preg_split('/[|;,]+/',strtoupper(trim($value)),-1,PREG_SPLIT_NO_EMPTY)?:[];
        foreach($tokens as $token){$token=trim($token);if(!preg_match('/^(?:R)?0*(\d+)(?:\s*[-:]\s*C?0*(\d+))$/',$token,$match)){$errors[]="Disabled seat '{$token}' is invalid.";continue;}$row=(int)$match[1];$column=(int)$match[2];
            if($row<1||$row>$rows||$column<1||$column>$columns){$errors[]="Disabled seat '{$token}' is outside the room layout.";continue;}$blocked[$row.'-'.$column]=true;}
        return [array_keys($blocked),$errors];
    }

    private function headerKey(string $header): string
    {
        $key=trim(preg_replace('/[^a-z0-9]+/','_',strtolower(trim($header)))??'','_');$aliases=['code'=>'room_code','room'=>'room_code','room_number'=>'room_code','rows_count'=>'rows','columns_count'=>'columns','cols'=>'columns','disabled_seats'=>'disabled_seat_numbers','blocked_seats'=>'disabled_seat_numbers','blocked_coordinates'=>'disabled_seat_numbers','order'=>'seat_order'];return $aliases[$key]??$key;
    }
}
