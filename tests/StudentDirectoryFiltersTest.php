<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/Academic/StudentDirectoryFilters.php';

use App\Academic\StudentDirectoryFilters;

function checkFilters(bool $condition,string $message):void{if(!$condition)throw new RuntimeException($message);}
$schools=[['id'=>1],['id'=>2]];
$programmes=[['id'=>10,'school_id'=>1],['id'=>20,'school_id'=>2]];
$batches=[['id'=>100,'programme_id'=>10],['id'=>200,'programme_id'=>20]];
$resolve=static fn($input)=>StudentDirectoryFilters::resolve($input,$schools,$programmes,$batches);
checkFilters($resolve(['school_id'=>1,'programme_id'=>10,'batch_id'=>100])===['schoolId'=>1,'programmeId'=>10,'batchId'=>100],'Valid selections lost');
checkFilters($resolve(['school_id'=>2,'programme_id'=>10,'batch_id'=>100])===['schoolId'=>2,'programmeId'=>null,'batchId'=>null],'Cross-school selection retained');
checkFilters($resolve(['school_id'=>1,'programme_id'=>10,'batch_id'=>200])['batchId']===null,'Cross-programme batch retained');
checkFilters($resolve(['programme_id'=>10,'batch_id'=>100])===['schoolId'=>null,'programmeId'=>null,'batchId'=>null],'Missing parent retained children');
checkFilters($resolve(['school_id'=>999,'programme_id'=>10,'batch_id'=>100])['programmeId']===null,'Unknown school retained children');
checkFilters($resolve(['school_id'=>[1],'programme_id'=>[10],'batch_id'=>[100]])===['schoolId'=>null,'programmeId'=>null,'batchId'=>null],'Malformed filters not cleared');
echo "Student directory filters: PASS (valid scope, changed school, changed programme, missing parents, invalid IDs).\n";

if(in_array('--database',$argv,true)){
    require dirname(__DIR__).'/app/Support/helpers.php';
    require dirname(__DIR__).'/app/Foundation/Environment.php';
    require dirname(__DIR__).'/app/Foundation/Database.php';
    require dirname(__DIR__).'/app/Academic/StudentRepository.php';
    App\Foundation\Environment::load(dirname(__DIR__).'/.env');
    $pdo=(new App\Foundation\Database(require dirname(__DIR__).'/config/database.php'))->connection();
    $pdo->exec('SET TRANSACTION READ ONLY');$pdo->beginTransaction();
    try{
        $repo=new App\Academic\StudentRepository($pdo);
        $schools=$pdo->query('SELECT id FROM schools')->fetchAll();
        foreach($schools as $s){
            $id=(int)$s['id'];
            $q=$pdo->prepare('SELECT COUNT(*) FROM students s JOIN programmes p ON p.id=s.programme_id WHERE p.school_id=?');$q->execute([$id]);
            $result=$repo->paginate('',null,null,1,25,$id);
            checkFilters($result['total']===(int)$q->fetchColumn(),'School total differs');
            foreach($result['items'] as $student){$p=$pdo->prepare('SELECT school_id FROM programmes WHERE id=?');$p->execute([$student['programme_id']]);checkFilters((int)$p->fetchColumn()===$id,'Student from another school');}
        }
        $first=$pdo->query('SELECT s.*,p.school_id FROM students s JOIN programmes p ON p.id=s.programme_id WHERE s.batch_id IS NOT NULL LIMIT 1')->fetch();
        if($first){
            $result=$repo->paginate($first['roll_no_original'],(int)$first['programme_id'],(int)$first['batch_id'],1,25,(int)$first['school_id']);
            checkFilters($result['total']===1&&(int)$result['items'][0]['id']===(int)$first['id'],'Combined search and academic filters failed');
        }
        echo "Database: PASS (read-only school totals, result scope and combined search/programme/batch filters).\n";
    }finally{$pdo->rollBack();}
}
