<?php
declare(strict_types=1);
define('BASE_PATH',dirname(__DIR__));
spl_autoload_register(static function(string $class):void{if(str_starts_with($class,'App\\'))require BASE_PATH.'/app/'.str_replace('\\','/',substr($class,4)).'.php';});
function borderCheck(bool $ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
function borderColumn(int $column):string{$name='';while($column){$column--;$name=chr(65+$column%26).$name;$column=intdiv($column,26);}return $name;}
function borderNumber(string $name):int{$n=0;foreach(str_split($name) as $letter)$n=$n*26+ord($letter)-64;return $n;}
$item=['programme_code'=>'UCS','programme_name'=>'B.Tech Computer Science','batch_label'=>'2024-2028','semester'=>5,'course_code'=>'CS301','course_name'=>'Graph Theory','category'=>'regular','roll_detail'=>'UCS001 to UCS004','count'=>4,'detail'=>'B.Tech Computer Science · 2024-2028 · Semester 5 (UCS001 to UCS004) CS301 Graph Theory'];
$document=['allocation'=>['exam_type'=>'mid_sem','exam_date'=>'2026-10-30','session_label'=>'Morning Shift (10:00 am - 11:30 am)'],'rooms'=>[]];
foreach(['IL-101','IL-102'] as $code)$document['rooms'][]=['code'=>$code,'building'=>'ICT Block','school_label'=>'SOICT','rows_count'=>6,'columns_count'=>12,'aisle_after'=>6,'grid'=>[1=>[1=>['student'=>['roll_no_original'=>'UCS001']]]],'summary'=>[$item],'assigned_count'=>4];
$out=BASE_PATH.'/outputs/room-layout-export';if(!is_dir($out))mkdir($out,0770,true);$file=$out.'/merged-border-regression.xlsx';file_put_contents($file,(new App\Export\SeatingPlanXlsx())->build($document));
$zip=new ZipArchive();borderCheck($zip->open($file)===true,'Invalid workbook');$styles=new DOMDocument();$styles->loadXML($zip->getFromName('xl/styles.xml'));$xfs=$styles->getElementsByTagName('cellXfs')->item(0)->getElementsByTagName('xf');$borders=$styles->getElementsByTagName('borders')->item(0)->getElementsByTagName('border');$checked=0;
foreach([1,2,3] as $sheetId){
    $sheet=new DOMDocument();borderCheck($sheet->loadXML($zip->getFromName('xl/worksheets/sheet'.$sheetId.'.xml')),'Invalid worksheet XML');$cells=[];$previousRow=0;
    foreach($sheet->getElementsByTagName('row') as $row){$r=(int)$row->getAttribute('r');borderCheck($r>$previousRow,'Rows are out of order');$previousRow=$r;$previousColumn=0;
        foreach($row->getElementsByTagName('c') as $cell){$ref=$cell->getAttribute('r');borderCheck(!isset($cells[$ref]),'Duplicate cell '.$ref);preg_match('/^([A-Z]+)\d+$/',$ref,$m);$column=borderNumber($m[1]);borderCheck($column>$previousColumn,'Cells are out of order');$previousColumn=$column;$cells[$ref]=$cell;}
    }
    $edgeStyles=static function(DOMElement $cell)use($xfs,$borders):array{
        $style=(int)$cell->getAttribute('s');borderCheck($style<$xfs->length,'Invalid style index');$border=$borders->item((int)$xfs->item($style)->getAttribute('borderId'));$edges=[];
        foreach(['left','right','top','bottom'] as $side){$edge=$border->getElementsByTagName($side)->item(0);$edges[$side]=$edge&&$edge->hasAttribute('style');}return $edges;
    };
    foreach($sheet->getElementsByTagName('mergeCell') as $merge){preg_match('/^([A-Z]+)(\d+):([A-Z]+)(\d+)$/',$merge->getAttribute('ref'),$m);$left=borderNumber($m[1]);$top=(int)$m[2];$right=borderNumber($m[3]);$bottom=(int)$m[4];$anchor=$cells[$m[1].$top];
        if(!in_array(true,$edgeStyles($anchor),true))continue;
        for($r=$top;$r<=$bottom;$r++)for($c=$left;$c<=$right;$c++){$ref=borderColumn($c).$r;borderCheck(isset($cells[$ref]),'Missing merged border cell '.$ref);$expected=['left'=>$c===$left,'right'=>$c===$right,'top'=>$r===$top,'bottom'=>$r===$bottom];borderCheck($edgeStyles($cells[$ref])===$expected,'Broken perimeter or internal border at '.$ref.' in sheet '.$sheetId);}
        $checked++;
    }
    borderCheck(!in_array(true,$edgeStyles($cells['A1']),true),'An unbordered heading became boxed');
    if($sheetId===2){borderCheck(str_contains($cells['A11']->textContent,'WHITE BOARD'),'Whiteboard text changed');borderCheck(str_contains($cells['B15']->textContent,'Graph Theory'),'Summary text changed');}
}
borderCheck($checked>=20,'Merged border coverage is incomplete');$zip->close();echo "Merged borders: PASS ($checked bordered ranges; horizontal/vertical perimeters, no internal lines, ordered cells, preserved text and titles)\n";
