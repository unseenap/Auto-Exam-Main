<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function layoutCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
function layoutXml(ZipArchive $zip,string $name):DOMDocument{$xml=$zip->getFromName($name);layoutCheck($xml!==false,'Missing '.$name);$dom=new DOMDocument();layoutCheck($dom->loadXML($xml),'Invalid XML: '.$name);return $dom;}
$exporter=new App\Export\SeatingPlanXlsx();
$out=BASE_PATH.'/outputs/room-layout-export';if(!is_dir($out))mkdir($out,0770,true);
foreach([12,5,1] as $columns){
    $room=['code'=>'IL-'.$columns,'school_code'=>'ICT','building'=>'Teaching & Research Block','rows_count'=>6,'columns_count'=>$columns,'usable_capacity'=>6*$columns,'seat_order'=>'column_major'];$seats=[];
    for($r=1;$r<=6;$r++)for($c=1;$c<=$columns;$c++)$seats[]=['row_no'=>$r,'column_no'=>$c,'seat_label'=>$r===1&&$c===1?'=Seat&A1':'R'.$r.'C'.$c,'is_blocked'=>in_array($c,[2,5,8,11],true)?1:0];
    $room['usable_capacity']-=count(array_filter($seats,static fn(array $s):bool=>(bool)$s['is_blocked']));
    $bytes=$exporter->buildRoomLayout($room,$seats);$file=$out.'/room-layout-'.$columns.'-columns.xlsx';file_put_contents($file,$bytes);
    $zip=new ZipArchive();layoutCheck($zip->open($file)===true,'Invalid Excel archive');
    $workbook=layoutXml($zip,'xl/workbook.xml');layoutCheck($workbook->getElementsByTagName('sheet')->length===1,'Room export must contain just its geometry, without student sheets');
    $sheet=layoutXml($zip,'xl/worksheets/sheet1.xml');$xp=new DOMXPath($sheet);$xp->registerNamespace('s','http://schemas.openxmlformats.org/spreadsheetml/2006/main');
    $seen=[];foreach($xp->query('//s:c') as $cell){$ref=$cell->getAttribute('r');layoutCheck(!isset($seen[$ref]),'Duplicate cell '.$ref);$seen[$ref]=true;}
    layoutCheck($xp->evaluate('string(//s:c[@r="A4"]/s:is/s:t)')==='=Seat&A1','Seat label was not preserved as text');
    layoutCheck($xp->query('//s:f')->length===0,'Seat labels were treated as formulas');
    layoutCheck($xp->query('//s:pageSetup[@orientation="landscape" and @fitToWidth="1"]')->length===1,'Landscape print configuration missing');
    layoutCheck(str_contains($sheet->textContent,'WHITE BOARD')&&str_contains($sheet->textContent,'DESK-1'),'Room reference landmarks missing');
    layoutCheck(!str_contains($sheet->textContent,'Student Detail'),'Student allocation table leaked into empty room geometry');
    if($columns===12){
        layoutCheck($xp->evaluate('string(//s:c[@r="B4"]/s:is/s:t)')==="BLOCKED\nR1C2",'Blocked position is missing its label');
        layoutCheck($xp->evaluate('string(//s:c[@r="H4"]/s:is/s:t)')==='R1C7','Aisle shifted the wrong physical seat');
        layoutCheck($xp->query('//s:c[@r="G4"]')->length===0,'Aisle contains a seat');
        $styles=layoutXml($zip,'xl/styles.xml');$styleId=(int)$xp->evaluate('string(//s:c[@r="B4"]/@s)');$xfs=$styles->getElementsByTagName('cellXfs')->item(0)->getElementsByTagName('xf');$fillId=(int)$xfs->item($styleId)->getAttribute('fillId');$fill=$styles->getElementsByTagName('fills')->item(0)->getElementsByTagName('fill')->item($fillId);
        layoutCheck($fill->getElementsByTagName('fgColor')->item(0)->getAttribute('rgb')==='FFE0E4E1','Blocked seat shading missing');
    }
    layoutXml($zip,'xl/drawings/drawing1.xml');$types=layoutXml($zip,'[Content_Types].xml');layoutCheck(str_contains($types->saveXML(),'/xl/drawings/drawing1.xml'),'Drawing content type missing');
    $zip->close();
}
echo "Room layout Excel: PASS (saved geometry, aisle, blocked labels and shading, text safety, odd/single columns, print settings)\n";
