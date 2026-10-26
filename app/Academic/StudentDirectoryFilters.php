<?php
declare(strict_types=1);

namespace App\Academic;

final class StudentDirectoryFilters
{
    public static function resolve(array $input,array $schools,array $programmes,array $batches):array
    {
        $id=static fn(string $key):int => is_scalar($input[$key]??null)?max(0,(int)$input[$key]):0;
        $schoolId=$id('school_id');$programmeId=$id('programme_id');$batchId=$id('batch_id');
        $schoolsById=array_column($schools,null,'id');
        $programmesById=array_column($programmes,null,'id');
        $batchesById=array_column($batches,null,'id');
        if(!isset($schoolsById[$schoolId]))$schoolId=0;
        if(!$schoolId||!isset($programmesById[$programmeId])||(int)$programmesById[$programmeId]['school_id']!==$schoolId)$programmeId=0;
        if(!$programmeId||!isset($batchesById[$batchId])||(int)$batchesById[$batchId]['programme_id']!==$programmeId)$batchId=0;
        return ['schoolId'=>$schoolId?:null,'programmeId'=>$programmeId?:null,'batchId'=>$batchId?:null];
    }
}
