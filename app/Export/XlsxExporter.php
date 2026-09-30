<?php

declare(strict_types=1);

namespace App\Export;

final class XlsxExporter
{
    public function build(string $title, string $schoolName, string $dateRange, array $headers, array $rows, array $widths = [], ?string $logoPng = null): string
    {
        $files=[
            '[Content_Types].xml'=>$this->contentTypes($logoPng!==null),
            '_rels/.rels'=>$this->packageRelationships(),
            'docProps/app.xml'=>$this->appProperties(),
            'docProps/core.xml'=>$this->coreProperties($title),
            'xl/workbook.xml'=>$this->workbook(),
            'xl/_rels/workbook.xml.rels'=>$this->workbookRelationships(),
            'xl/styles.xml'=>$this->styles(),
            'xl/worksheets/sheet1.xml'=>$this->worksheet($title,$schoolName,$dateRange,$headers,$rows,$widths,$logoPng!==null),
        ];
        if($logoPng!==null){
            $files['xl/worksheets/_rels/sheet1.xml.rels']=$this->worksheetRelationships();
            $files['xl/drawings/drawing1.xml']=$this->drawing(max(1,count($headers)));
            $files['xl/drawings/_rels/drawing1.xml.rels']=$this->drawingRelationships();
            $files['xl/media/gbu-emblem.png']=$logoPng;
        }
        return $this->zip($files);
    }

    private function worksheet(string $title, string $schoolName, string $dateRange, array $headers, array $rows, array $widths, bool $hasLogo): string
    {
        $columnCount=max(1,count($headers));$last=$this->column($columnCount);$xml=[];
        $xml[]='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
        $xml[]='<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">';
        $xml[]='<sheetViews><sheetView workbookViewId="0" showGridLines="0"><pane ySplit="8" topLeftCell="A9" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>';
        $xml[]='<cols>';for($i=1;$i<=$columnCount;$i++){$width=(float)($widths[$i-1]??18);$xml[]='<col min="'.$i.'" max="'.$i.'" width="'.$width.'" customWidth="1"/>';}$xml[]='</cols><sheetData>';
        $xml[]='<row r="1" ht="52" customHeight="1"/><row r="2" ht="6" customHeight="1"/>';
        $xml[]='<row r="3" ht="28" customHeight="1">'.$this->cell('A3','Gautam Buddha University',5).'</row>';
        $xml[]='<row r="4" ht="22" customHeight="1">'.$this->cell('A4',$schoolName,6).'</row>';
        $xml[]='<row r="5" ht="28" customHeight="1">'.$this->cell('A5',$title,7).'</row>';
        $xml[]='<row r="6" ht="22" customHeight="1">'.$this->cell('A6','('.$dateRange.')',8).'</row><row r="7" ht="12" customHeight="1"/>';
        $cells=[];foreach(array_values($headers) as $index=>$header)$cells[]=$this->cell($this->column($index+1).'8',(string)$header,3);$xml[]='<row r="8" ht="46" customHeight="1">'.implode('',$cells).'</row>';
        foreach(array_values($rows) as $rowIndex=>$row){$number=$rowIndex+9;$cells=[];$maxLines=1;foreach(array_values($row) as $index=>$value){$value=(string)$value;$maxLines=max($maxLines,substr_count($value,"\n")+1);$cells[]=$this->cell($this->column($index+1).$number,$value,4);}$height=min(180,max(70,16*$maxLines));$xml[]='<row r="'.$number.'" ht="'.$height.'" customHeight="1">'.implode('',$cells).'</row>';}
        $xml[]='</sheetData>';
        $xml[]='<mergeCells count="4"><mergeCell ref="A3:'.$last.'3"/><mergeCell ref="A4:'.$last.'4"/><mergeCell ref="A5:'.$last.'5"/><mergeCell ref="A6:'.$last.'6"/></mergeCells>';
        $xml[]='<pageMargins left="0.2" right="0.2" top="0.3" bottom="0.3" header="0.2" footer="0.2"/><pageSetup orientation="landscape" fitToWidth="1" fitToHeight="0"/>';
        if($hasLogo)$xml[]='<drawing r:id="rId1"/>';
        $xml[]='</worksheet>';
        return implode('',$xml);
    }

    private function cell(string $reference,string $value,int $style):string{return '<c r="'.$reference.'" t="inlineStr" s="'.$style.'"><is><t xml:space="preserve">'.$this->xml($value).'</t></is></c>';}
    private function column(int $number):string{$label='';while($number>0){$number--;$label=chr(65+($number%26)).$label;$number=intdiv($number,26);}return $label;}
    private function xml(string $value):string{return htmlspecialchars($value,ENT_XML1|ENT_QUOTES,'UTF-8');}
    private function zip(array $files):string
    {
        $body='';$directory='';$offset=0;$count=0;
        foreach($files as $name=>$content){$name=(string)$name;$content=(string)$content;$crc=crc32($content);$size=strlen($content);$nameLength=strlen($name);
            $local=pack('VvvvvvVVVvv',0x04034b50,20,0,0,0,0,$crc,$size,$size,$nameLength,0).$name.$content;$body.=$local;
            $directory.=pack('VvvvvvvVVVvvvvvVV',0x02014b50,20,20,0,0,0,0,$crc,$size,$size,$nameLength,0,0,0,0,0,$offset).$name;$offset+=strlen($local);$count++;}
        return $body.$directory.pack('VvvvvVVv',0x06054b50,0,0,$count,$count,strlen($directory),strlen($body),0);
    }
    private function contentTypes(bool $hasLogo):string{$drawing=$hasLogo?'<Default Extension="png" ContentType="image/png"/><Override PartName="/xl/drawings/drawing1.xml" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/>':'';return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/>'.$drawing.'<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/><Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/><Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/></Types>';}
    private function packageRelationships():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/></Relationships>';}
    private function workbook():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><bookViews><workbookView/></bookViews><sheets><sheet name="Date Sheet" sheetId="1" r:id="rId1"/></sheets></workbook>';}
    private function workbookRelationships():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>';}
    private function styles():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="7"><font><sz val="10"/><name val="Arial"/></font><font><b/><sz val="10"/><name val="Arial"/></font><font><b/><sz val="10"/><name val="Arial"/></font><font><b/><sz val="16"/><name val="Arial"/></font><font><b/><sz val="11"/><name val="Arial"/></font><font><b/><sz val="14"/><name val="Arial"/></font><font><sz val="11"/><name val="Arial"/></font></fonts><fills count="3"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill><fill><patternFill patternType="solid"><fgColor rgb="FFEAF0ED"/><bgColor indexed="64"/></patternFill></fill></fills><borders count="2"><border/><border><left style="thin"><color rgb="FF4B5652"/></left><right style="thin"><color rgb="FF4B5652"/></right><top style="thin"><color rgb="FF4B5652"/></top><bottom style="thin"><color rgb="FF4B5652"/></bottom></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="9"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="2" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf><xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf><xf numFmtId="0" fontId="3" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf><xf numFmtId="0" fontId="4" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf><xf numFmtId="0" fontId="5" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf><xf numFmtId="0" fontId="6" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles></styleSheet>';}

    private function worksheetRelationships():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing1.xml"/></Relationships>';}
    private function drawingRelationships():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/gbu-emblem.png"/></Relationships>';}
    private function drawing(int $columnCount):string{$column=max(0,intdiv($columnCount-1,2));return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><xdr:oneCellAnchor><xdr:from><xdr:col>'.$column.'</xdr:col><xdr:colOff>190500</xdr:colOff><xdr:row>0</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from><xdr:ext cx="476250" cy="476250"/><xdr:pic><xdr:nvPicPr><xdr:cNvPr id="2" name="GBU Emblem"/><xdr:cNvPicPr/></xdr:nvPicPr><xdr:blipFill><a:blip r:embed="rId1"/><a:stretch><a:fillRect/></a:stretch></xdr:blipFill><xdr:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="476250" cy="476250"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></xdr:spPr></xdr:pic><xdr:clientData/></xdr:oneCellAnchor></xdr:wsDr>';}
    private function appProperties():string{return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"><Application>GBU Examination Operations</Application></Properties>';}
    private function coreProperties(string $title):string{$now=gmdate('Y-m-d\TH:i:s\Z');return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>'.$this->xml($title).'</dc:title><dc:creator>Gautam Buddha University</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">'.$now.'</dcterms:created></cp:coreProperties>';}
}
