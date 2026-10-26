<?php
declare(strict_types=1);
namespace App\Export;
use RuntimeException;
use ZipArchive;

/** Dynamic version of the supplied university seating form, using its original styles. */
final class SeatingPlanXlsx
{
    private function x(string $text): string{return htmlspecialchars($text,ENT_XML1|ENT_QUOTES,'UTF-8');}
    private function col(int $n): string{$s='';while($n>0){$n--;$s=chr(65+$n%26).$s;$n=intdiv($n,26);}return $s;}
    private function cell(int $col,int $row,string|int $value,int $style):string
    {$r=$this->col($col).$row;return is_int($value)?'<c r="'.$r.'" s="'.$style.'"><v>'.$value.'</v></c>':'<c r="'.$r.'" s="'.$style.'" t="inlineStr"><is><t xml:space="preserve">'.$this->x($value).'</t></is></c>';}
    private function row(int $row,array $cells,float $height=19.5):string{return '<row r="'.$row.'" ht="'.$height.'" customHeight="1">'.implode('',$cells).'</row>';}

    public function build(array $document): string
    {
        if(!class_exists(ZipArchive::class))throw new RuntimeException('Excel export requires the PHP zip extension.');
        $sheets=[];$names=['Master'];$sheets[]=$this->master($document);
        foreach($document['rooms'] as $room){$base=mb_substr(preg_replace('/[\\\\\/\?\*\[\]:]/u','-',$room['code'])?:'Room',0,27);$name=$base;$i=2;while(in_array(strtolower($name),array_map('strtolower',$names),true))$name=$base.'-'.$i++;$names[]=$name;$sheets[]=$this->room($document['allocation'],$room);}
        $workbookSheets='';$rels='';$overrides='';$defined='<definedName name="_xlnm.Print_Titles" localSheetId="0">Master!$1:$4</definedName>';
        foreach($sheets as $i=>$sheet){$n=$i+1;$workbookSheets.='<sheet name="'.$this->x($names[$i]).'" sheetId="'.$n.'" r:id="rId'.$n.'"/>';$rels.='<Relationship Id="rId'.$n.'" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet'.$n.'.xml"/>';if($i>0)$overrides.='<Override PartName="/xl/drawings/drawing'.$n.'.xml" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/>';$overrides.='<Override PartName="/xl/worksheets/sheet'.$n.'.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>';$defined.='<definedName name="_xlnm.Print_Area" localSheetId="'.$i.'">'.$this->x("'".str_replace("'","''",$names[$i])."'!".$sheet['area']).'</definedName>';}
        $tmp=tempnam(sys_get_temp_dir(),'seating_xlsx_');if($tmp===false)throw new RuntimeException('Cannot create Excel export.');$zip=new ZipArchive();
        try{
            if($zip->open($tmp,ZipArchive::OVERWRITE)!==true)throw new RuntimeException('Cannot open Excel archive.');
            $zip->addFromString('[Content_Types].xml','<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'.$overrides.'</Types>');
            $zip->addFromString('_rels/.rels','<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>');
            $zip->addFromString('xl/workbook.xml','<?xml version="1.0" encoding="UTF-8"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><bookViews><workbookView/></bookViews><sheets>'.$workbookSheets.'</sheets><definedNames>'.$defined.'</definedNames></workbook>');
            $zip->addFromString('xl/_rels/workbook.xml.rels','<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'.$rels.'<Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rIdTheme" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/></Relationships>');
            $zip->addFile(BASE_PATH.'/resources/templates/seating/styles.xml','xl/styles.xml');$zip->addFile(BASE_PATH.'/resources/templates/seating/theme.xml','xl/theme/theme1.xml');
            foreach($sheets as $i=>$sheet){$n=$i+1;$zip->addFromString('xl/worksheets/sheet'.$n.'.xml',$sheet['xml']);if(isset($sheet['drawing'])){$zip->addFromString('xl/drawings/drawing'.$n.'.xml',$sheet['drawing']);$zip->addFromString('xl/worksheets/_rels/sheet'.$n.'.xml.rels','<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rIdDrawing" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing'.$n.'.xml"/></Relationships>');}}
            $zip->close();$bytes=file_get_contents($tmp);if($bytes===false)throw new RuntimeException('Cannot read Excel export.');return $bytes;
        }finally{if(is_file($tmp))unlink($tmp);}
    }

    private function sheet(string $rows,string $cols,array $merges,string $area,int $fitHeight=1): array
    {
        $merged='';foreach($merges as $merge)$merged.='<mergeCell ref="'.$merge.'"/>';
        return ['area'=>$area,'xml'=>'<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetPr><pageSetUpPr fitToPage="1"/></sheetPr><sheetViews><sheetView workbookViewId="0" showGridLines="0"/></sheetViews><sheetFormatPr defaultRowHeight="19.5"/><cols>'.$cols.'</cols><sheetData>'.$rows.'</sheetData><mergeCells count="'.count($merges).'">'.$merged.'</mergeCells><printOptions horizontalCentered="1"/><pageMargins left="0.16" right="0.16" top="0.22" bottom="0.20" header="0.16" footer="0.16"/><pageSetup paperSize="9" orientation="landscape" fitToWidth="1" fitToHeight="'.$fitHeight.'"/></worksheet>'];
    }

    private function room(array $allocation,array $room): array
    {
        $columns=(int)$room['columns_count'];$total=max(3,$columns+1);$aisle=(int)$room['aisle_after'];$last=$this->col($total);$cols='';
        $layout=json_decode(file_get_contents(BASE_PATH.'/resources/templates/seating/layout.json'),true);
        for($c=1;$c<=$total;$c++)$cols.='<col min="'.$c.'" max="'.$c.'" width="'.($columns===$layout['reference_columns']?$layout['column_widths'][$c-1]:($c===$aisle+1?'14.42578125':'15.28515625')).'" customWidth="1"/>';
        $rows='';$merges=[];foreach(['Seating Plan ('.$room['school_label'].')','Room No - '.$room['code'],$allocation['session_label']] as $i=>$text){$r=$i+1;$rows.=$this->row($r,[$this->cell(1,$r,$text,117)]);$merges[]='A'.$r.':'.$last.$r;}
        for($r=1;$r<=(int)$room['rows_count'];$r++){$cells=[];for($c=1;$c<=$columns;$c++){$entry=$room['grid'][$r][$c]??null;$value=$entry['student']['roll_no_original']??'';$cells[]=$this->cell($c+($c>$aisle?1:0),$r+3,$value,78);}$rows.=$this->row($r+3,$cells,42.75);}
        $r=(int)$room['rows_count']+4;$desk=[];
        foreach([[1,$aisle],[$aisle+1,$columns]] as [$start,$end]){$n=1;for($c=$start;$c<=$end;$c+=2){$from=$c+($c>$aisle?1:0);$to=min($c+1,$end)+(min($c+1,$end)>$aisle?1:0);$desk[]=$this->cell($from,$r,'DESK-'.$n++,115);if($to>$from)$merges[]=$this->col($from).$r.':'.$this->col($to).$r;}}
        $rows.=$this->row($r,$desk);$r++;$rows.=$this->row($r,[$this->cell(1,$r,'WHITE BOARD',123)],23.25);$merges[]='A'.$r.':'.$last.$r;
        $r++;$rows.=$this->row($r,[$this->cell(1,$r,'Left Side of Invigilator',126),$this->cell($aisle+1,$r,'',85),$this->cell($aisle+2,$r,'Right Side of Invigilator',127)],26.25);
        if($aisle>1)$merges[]='A'.$r.':'.$this->col($aisle).$r;if($aisle+2<$total)$merges[]=$this->col($aisle+2).$r.':'.$last.$r;
        $r+=2;$rows.=$this->row($r,[$this->cell(1,$r,'S.No.',85),$this->cell(2,$r,'Student Detail',119),$this->cell($total,$r,'No. of Student',46)]);if($total>3)$merges[]='B'.$r.':'.$this->col($total-1).$r;
        foreach($room['summary'] as $i=>$item){$r++;$rows.=$this->row($r,[$this->cell(1,$r,$i+1,85),$this->cell(2,$r,$item['detail'],112),$this->cell($total,$r,(int)$item['count'],85)],max(37.5,15*ceil(mb_strlen($item['detail'])/max(35,($total-2)*14))));if($total>3)$merges[]='B'.$r.':'.$this->col($total-1).$r;}
        for($blank=count($room['summary']);$blank<3;$blank++){$r++;$rows.=$this->row($r,[$this->cell(1,$r,$blank+1,85),$this->cell(2,$r,'',112),$this->cell($total,$r,'',85)],37.5);if($total>3)$merges[]='B'.$r.':'.$this->col($total-1).$r;}
        $r++;$rows.=$this->row($r,[$this->cell($total-1,$r,'Total',42),$this->cell($total,$r,(int)$room['assigned_count'],7)]);
        $sheet=$this->sheet($rows,$cols,$merges,'$A$1:$'.$last.'$'.$r);
        $sheet['drawing']=str_replace(['@AISLE@','@ROW@'],[(string)$aisle,(string)((int)$room['rows_count']+5)],file_get_contents(BASE_PATH.'/resources/templates/seating/invigilator.xml'));
        $sheet['xml']=str_replace('</worksheet>','<drawing xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="rIdDrawing"/></worksheet>',$sheet['xml']);return $sheet;
    }

    private function master(array $document): array
    {
        $a=$document['allocation'];$rows='';$merges=[];
        foreach(['Gautam Buddha University',(['mid_sem'=>'Mid Semester','end_sem'=>'End Semester'][$a['exam_type']]??ucwords(str_replace('_',' ',$a['exam_type']))).' Examination ('.date('d-m-Y',strtotime($a['exam_date'])).')','Master Seating Plan for '.$a['session_label']] as $i=>$text){$r=$i+1;$rows.=$this->row($r,[$this->cell(1,$r,$text,$r===1?109:110)],$r===1?22.5:18.75);$merges[]='A'.$r.':H'.$r;}
        $headers=['S.No','Programme, Batch & Semester','Course Code & Course name','Building','Room','Roll No.','No. of Students','Total No. of Students'];$cells=[];foreach($headers as $i=>$text)$cells[]=$this->cell($i+1,4,$text,80);$rows.=$this->row(4,$cells,47.25);$r=4;$n=0;$total=0;
        $groups=[];foreach($document['rooms'] as $room)foreach($room['summary'] as $item){$key=json_encode([$item['programme_code'],$item['batch_label'],$item['semester'],$item['course_code'],$item['category']]);if(!isset($groups[$key]))$groups[$key]=['item'=>$item,'parts'=>[],'total'=>0];$groups[$key]['parts'][]=['building'=>$room['building'],'room'=>$room['code'],'rolls'=>$item['roll_detail'],'count'=>(int)$item['count']];$groups[$key]['total']+=(int)$item['count'];}
        foreach($groups as $group){$item=$group['item'];$start=$r+1;$n++;$total+=$group['total'];$sameBuilding=count(array_unique(array_column($group['parts'],'building')))===1;
            foreach($group['parts'] as $index=>$part){$r++;$values=[$index===0?$n:'',$index===0?$item['programme_name'].' · '.($item['batch_label']?:'Batch not recorded').' · '.\App\Seating\SeatingPlanDocument::ordinal($item['semester']).' Semester':'',$index===0?$item['course_code'].' '.$item['course_name']:'',$index===0||!$sameBuilding?$part['building']:'',$part['room'],$part['rolls'],$part['count'],$index===0?$group['total']:''];$cells=[];foreach($values as $i=>$value)$cells[]=$this->cell($i+1,$r,$value,$i===0?106:($i===4?16:102));$rows.=$this->row($r,$cells,$index===0?37.5:19.5);}
            if($r>$start)foreach($sameBuilding?[1,2,3,4,8]:[1,2,3,8] as $column)$merges[]=$this->col($column).$start.':'.$this->col($column).$r;
        }
        $r++;$rows.=$this->row($r,[$this->cell(6,$r,'Total',42),$this->cell(7,$r,$total,47),$this->cell(8,$r,$total,47)]);$cols='';foreach([5.5703125,47.85546875,61.140625,15,11.5703125,41.5703125,12,14] as $i=>$width)$cols.='<col min="'.($i+1).'" max="'.($i+1).'" width="'.$width.'" customWidth="1"/>';
        return $this->sheet($rows,$cols,$merges,'$A$1:$H$'.$r,0);
    }
}
