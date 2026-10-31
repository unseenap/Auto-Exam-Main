<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/Import/TabularReader.php';

use App\Import\TabularReader;

function checkReader(bool $condition,string $message):void
{
    if(!$condition)throw new RuntimeException($message);
}

if(!class_exists(ZipArchive::class))throw new RuntimeException('Enable the PHP zip extension to run XLSX tests.');
$reader=new TabularReader();
$temporary=tempnam(__DIR__,'gbu_xlsx_');
try{
    foreach([false,true] as $bom){
        file_put_contents($temporary,($bom?"\xEF\xBB\xBF":'')."\"Enrollment/Roll Number\",\"Full Name\"\r\n\"235UCS501\",\"Demo Student\"\r\n");
        checkReader($reader->read($temporary,'csv')===[['Enrollment/Roll Number','Full Name'],['235UCS501','Demo Student']],'Quoted CSV header failed with BOM='.($bom?'yes':'no'));
    }
    foreach(['default','prefixed','none'] as $style){
        $prefix=$style==='prefixed'?'x:':'';
        $namespace=$style==='none'?'':($style==='prefixed'?' xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main"':' xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"');
        $sheet='<worksheet'.$namespace.'><sheetData><row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="inlineStr"><is><t>Full Name</t></is></c></row><row r="2"><c r="A2" t="str"><v>235UCS501</v></c><c r="B2" t="inlineStr"><is><r><t>Demo </t></r><r><t>Student</t></r></is></c><c r="D2"><v>5</v></c><c r="F2" t="str"><v>0000000001</v></c></row></sheetData></worksheet>';
        $strings='<sst'.$namespace.'><si><r><t>Enrollment/</t></r><r><t>Roll Number</t></r></si></sst>';
        if($prefix!==''){
            $sheet=preg_replace('/(<\/?)([A-Za-z][A-Za-z0-9]*)(?=[\s>\/])/','$1'.$prefix.'$2',$sheet);
            $strings=preg_replace('/(<\/?)([A-Za-z][A-Za-z0-9]*)(?=[\s>\/])/','$1'.$prefix.'$2',$strings);
        }
        $zip=new ZipArchive();checkReader($zip->open($temporary,ZipArchive::CREATE|ZipArchive::OVERWRITE)===true,'Could not create fixture');
        $zip->addFromString('xl/worksheets/sheet1.xml',$sheet);$zip->addFromString('xl/sharedStrings.xml',$strings);checkReader($zip->close(),'Could not save fixture');
        $rows=$reader->read($temporary,'xlsx');
        checkReader($rows===[['Enrollment/Roll Number','Full Name'],['235UCS501','Demo Student','','5','','0000000001']],'XLSX parsing failed for '.$style.' namespace');
    }
    echo "TabularReader: PASS (quoted CSV with/without BOM; XLSX namespaces, rich text, sparse cells, leading-zero identifiers).\n";
}finally{if(is_file($temporary))unlink($temporary);}
