<?php

declare(strict_types=1);

require dirname(__DIR__) . '/app/Academic/RollNumberParser.php';

use App\Academic\RollNumberParser;

$programmes = [
    'UCS' => ['id' => 1, 'lateral_entry' => 0, 'legacy' => 0],
    'UAI' => ['id' => 2, 'lateral_entry' => 0, 'legacy' => 0],
    'LCS' => ['id' => 3, 'lateral_entry' => 1, 'legacy' => 0],
    'ICS' => ['id' => 4, 'lateral_entry' => 0, 'legacy' => 1],
];

$cases = [
    ['245UCS005', '245UCS005', 'UCS', '005', 'none', 'verified'],
    ['245/UCS/030', '245UCS030', 'UCS', '030', 'none', 'verified'],
    ['R-235UAI060', 'R-235UAI060', 'UAI', '060', 'repeat', 'verified'],
    ['255LCS011', '255LCS011', 'LCS', '011', 'none', 'verified'],
    ['225/ICS/002', '225ICS002', 'ICS', '002', 'none', 'verified'],
    ['245XYZ009', '245XYZ009', 'XYZ', '009', 'none', 'review'],
];

$parser = new RollNumberParser();
foreach ($cases as $index => [$input, $normalized, $code, $sequence, $special, $status]) {
    $result = $parser->parse($input, $programmes);
    assert($result['normalized_roll_no'] === $normalized, "Case {$index}: normalized roll mismatch");
    assert($result['programme_code_detected'] === $code, "Case {$index}: code mismatch");
    assert($result['student_sequence'] === $sequence, "Case {$index}: sequence mismatch");
    assert($result['special_status'] === $special, "Case {$index}: special status mismatch");
    assert($result['parsing_status'] === $status, "Case {$index}: parsing status mismatch");
}
foreach(['235LCS001'=>[1,'LCS'],'235LAI001'=>[2,'LAI'],'R-235LCS002'=>[1,'LCS']] as $roll=>[$id,$code]){
    $result=$parser->parse($roll,$programmes);
    assert($result['programme_id']===$id&&$result['programme_code_detected']===$code&&$result['admission_type']==='lateral'&&$result['registration_prefix']==='235','Lateral entry did not map to regular programme');
    assert($result['normalized_roll_no']===$roll,'Lateral roll identity was changed');
}
$unmapped=$parser->parse('235LZZ001',$programmes);assert($unmapped['programme_id']===null&&$unmapped['parsing_status']==='review'&&$unmapped['admission_type']==='lateral','Missing regular lateral programme silently accepted');

echo 'RollNumberParser: ' . count($cases) . " cases passed.\n";

