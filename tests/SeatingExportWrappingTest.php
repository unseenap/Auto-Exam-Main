<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));
require BASE_PATH.'/app/Export/SeatingPlanXlsx.php';
require BASE_PATH.'/app/Seating/SeatingPlanDocument.php';
function exportCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
$rolls=[];for($i=1;$i<=160;$i+=2)$rolls[]='26DEMO'.str_pad((string)$i,3,'0',STR_PAD_LEFT);
$summary=['programme_name'=>'Demonstration Computer Science and Engineering','programme_code'=>'DEMO','batch_label'=>'DEMO 2026-2030','semester'=>1,'category'=>'regular','course_code'=>'DEMO101','course_name'=>'Demonstration Written Examination','roll_detail'=>implode(', ',$rolls),'detail'=>'Demonstration students','count'=>count($rolls)];
$room=['code'=>'DEMO-101','building'=>'Demo Building','school_label'=>'DEMO','columns_count'=>2,'rows_count'=>1,'aisle_after'=>1,'grid'=>[],'summary'=>[$summary],'assigned_count'=>count($rolls)];
$second=$room;$second['code']='DEMO-102';$second['summary'][0]['roll_detail']='26DEMO200 to 26DEMO202';$second['summary'][0]['count']=3;$second['assigned_count']=3;
$document=['allocation'=>['exam_type'=>'end_sem','exam_date'=>'2026-11-04','session_label'=>'Morning Shift'],'rooms'=>[$room,$second]];
$out=BASE_PATH.'/outputs/seating-export-wrapping';if(!is_dir($out))mkdir($out,0770,true);
$file=$out.'/wrapping-regression.xlsx';file_put_contents($file,(new App\Export\SeatingPlanXlsx())->build($document));
$zip=new ZipArchive();exportCheck($zip->open($file)===true,'Invalid XLSX archive');
$dom=new DOMDocument();exportCheck($dom->loadXML($zip->getFromName('xl/worksheets/sheet1.xml')),'Invalid worksheet XML');
$xp=new DOMXPath($dom);$xp->registerNamespace('s','http://schemas.openxmlformats.org/spreadsheetml/2006/main');
$rollText='';$rollRows=0;$counts=0;
foreach($xp->query('//s:sheetData/s:row') as $row){
    $number=(int)$row->getAttribute('r');$height=(float)$row->getAttribute('ht');
    exportCheck($height<=409,'Exceeded Excel row-height limit');
    $text=$xp->evaluate('string(s:c[@r="F'.$number.'"]/s:is/s:t)',$row);
    if(str_contains($text,'26DEMO')){
        $rollRows++;$rollText.=$text;
        exportCheck($height>=18*(substr_count($text,"\n")+1)+8,'Roll list clipped by row height');
        $counts+=(int)$xp->evaluate('string(s:c[@r="G'.$number.'"]/s:v)',$row);
    }
}
exportCheck($rollRows>2,'Long roll list was not split into continuation rows');
foreach($rolls as $roll)exportCheck(substr_count($rollText,$roll)===1,'Roll number missing or duplicated: '.$roll);
exportCheck($counts===count($rolls)+3,'Continuation rows duplicated student counts');
exportCheck($xp->evaluate('string(//s:pageSetup/@fitToHeight)')==='0','Master must paginate vertically');
exportCheck($xp->query('//s:mergeCell[starts-with(@ref,"E5:")]')->length===1,'Room label not merged across continuation rows');
$zip->close();
echo "Seating export wrapping: PASS (fragmented rolls, row heights, continuation rows, counts and print pagination)\n";
