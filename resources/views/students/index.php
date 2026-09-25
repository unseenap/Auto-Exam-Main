<?php $pageTitle = 'Students'; ?>
<section class="page-heading"><div><p class="eyebrow">Academic records</p><h1>Student directory</h1><p>Search official roll numbers, confirm programme mappings, and identify records requiring manual review.</p></div><div class="heading-actions"><a class="secondary-button" href="<?= e(url('students/import')) ?>">Import file</a><a class="primary-button" href="<?= e(url('students/create')) ?>">Add student</a></div></section>
<?php if ($success): ?><div class="alert success" role="status"><?= e($success) ?></div><?php endif; ?>
<?php if ($error): ?><div class="alert error" role="alert"><?= e($error) ?></div><?php endif; ?>
<section class="panel table-panel">
  <form class="filter-bar" method="get" action="<?= e(url('students')) ?>">
    <label>Search<input name="search" type="search" value="<?= e($search) ?>" placeholder="Roll number or student name"></label>
    <label>Programme<select name="programme_id"><option value="">All programmes</option><?php foreach ($programmes as $programme): ?><option value="<?= (int) $programme['id'] ?>" <?= $programmeId === (int) $programme['id'] ? 'selected' : '' ?>><?= e($programme['code']) ?> - <?= e($programme['name']) ?></option><?php endforeach; ?></select></label>
    <label>Batch<select name="batch_id"><option value="">All batches</option><?php foreach($batches as $batch):?><option value="<?= (int)$batch['id'] ?>" <?= $batchId===(int)$batch['id']?'selected':'' ?>><?= e($batch['label']) ?></option><?php endforeach;?></select></label>
    <button class="secondary-button" type="submit">Apply filters</button>
    <?php if ($search !== '' || $programmeId || $batchId): ?><a class="text-button" href="<?= e(url('students')) ?>">Clear</a><?php endif; ?>
  </form>
  <div class="table-toolbar"><strong><?= number_format($result['total']) ?> student records</strong><span>Page <?= $result['page'] ?> of <?= $result['pages'] ?></span></div>
  <?php if ($result['items']): ?>
  <div class="table-scroll"><table><thead><tr><th>Roll / Enrollment</th><th>Student</th><th>Session</th><th>Branch / Department</th><th>Year / Semester</th><th>Contact</th><th>Parsing</th><th>Status</th><th></th></tr></thead><tbody>
  <?php foreach ($result['items'] as $student): ?><tr>
    <td><strong><?= e($student['roll_no_original']) ?></strong><small class="cell-note"><?= e($student['enrollment_number']?:$student['normalized_roll_no']) ?></small></td>
    <td><?= e($student['name']) ?><small class="cell-note"><?= e($student['school_name']) ?> | Section <?= e($student['section']) ?></small></td>
    <td><?= e($student['academic_session']) ?><small class="cell-note"><?= e($student['batch_label']?:'Batch not assigned') ?></small></td><td><?= e($student['branch']) ?><small class="cell-note"><?= e($student['department_name']) ?></small></td>
    <td>Year <?= (int)$student['current_year_of_study'] ?><small class="cell-note">Semester <?= (int)$student['semester'] ?></small></td><td><?= e($student['mobile_number']?:'-') ?></td>
    <td><span class="status-label <?= e($student['parsing_status']) ?>"><?= e(ucfirst($student['parsing_status'])) ?></span></td>
    <td><span class="status-label <?= e($student['status']) ?>"><?= e(ucfirst($student['status'])) ?></span></td>
    <td><div class="record-actions"><a class="row-action" href="<?= e(url('students/' . $student['id'] . '/edit')) ?>">Edit</a><form method="post" action="<?= e(url('students/'.$student['id'].'/delete')) ?>" onsubmit="return confirm('Delete student <?= e($student['roll_no_original']) ?>? This cannot be undone and will be blocked if examination records use the student.')"><?= csrf_field() ?><button class="delete-action" type="submit"><i class="ti ti-trash" aria-hidden="true"></i> Delete</button></form></div></td>
  </tr><?php endforeach; ?></tbody></table></div>
  <nav class="pagination" aria-label="Student pages">
    <?php if ($result['page'] > 1): ?><a href="?<?= e(http_build_query(['search'=>$search,'programme_id'=>$programmeId,'batch_id'=>$batchId,'page'=>$result['page']-1])) ?>">Previous</a><?php endif; ?>
    <span><?= $result['page'] ?> / <?= $result['pages'] ?></span>
    <?php if ($result['page'] < $result['pages']): ?><a href="?<?= e(http_build_query(['search'=>$search,'programme_id'=>$programmeId,'batch_id'=>$batchId,'page'=>$result['page']+1])) ?>">Next</a><?php endif; ?>
  </nav>
  <?php else: ?><div class="empty-state"><strong>No student records found</strong><p>Add a student or change the filters. Bulk import will be added in the next workflow.</p><a class="primary-button" href="<?= e(url('students/create')) ?>">Add first student</a></div><?php endif; ?>
</section>
