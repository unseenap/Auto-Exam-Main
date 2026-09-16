<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/Exams/WrittenPaperPolicy.php';
foreach(['Physics Lab','Language LAB','Programming Laboratory','Chemistry Practicals','Lab-II','Practical Examination'] as $name)assert(App\Exams\WrittenPaperPolicy::isLab($name),$name);
foreach(['Programming Fundamentals','Collaborative Computing','Labour Law','Mathematics'] as $name)assert(!App\Exams\WrittenPaperPolicy::isLab($name),$name);
echo "Written paper policy: PASS (lab/practical names, case, boundaries)\n";
