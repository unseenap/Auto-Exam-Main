<?php $pageTitle='Attendance sheet'; ?>
<section class="page-heading no-print">
  <div>
    <p class="eyebrow">Room-wise attendance</p>
    <h1><?= e($allocation['cycle_name']) ?></h1>
    <p><?= e(date('d F Y',strtotime($allocation['exam_date'])).' · '.$allocation['shift_name']) ?></p>
  </div>
  <div class="heading-actions">
    <a class="primary-button" href="<?= e(url('attendance/'.$allocation['id'].'/export.xlsx')) ?>">Download session master Excel</a>
    <a class="secondary-button" href="<?= e(url('attendance/cycles/'.$allocation['cycle_id'].'/export.xlsx')) ?>">Download exam-cycle master Excel</a>
    <button class="secondary-button" onclick="window.print()">Print</button>
  </div>
</section>
<?php if($success): ?><div class="alert success no-print" role="status"><?= e($success) ?></div><?php endif; ?>
<?php if($error): ?><div class="alert error no-print" role="alert"><?= e($error) ?></div><?php endif; ?>
<?php if(!$byRoom): ?><p>No attendance records are available for this shift.</p><?php endif; ?>

<?php require __DIR__.'/live-rooms.php'; ?>

<?php foreach($byRoom as $room=>$items):
    $roomId=(int)$items[0]['room_id'];
    $roomState=$roomStates[$roomId];
    $locked=$roomState['status']==='submitted';
?>
<form method="post" action="<?= e(url('attendance/'.$allocation['id'])) ?>" id="attendance-room-<?= $roomId ?>">
  <?= csrf_field() ?>
  <input type="hidden" name="revisions[<?= $roomId ?>]" value="<?= (int)$roomState['revision'] ?>">
  <section class="attendance-sheet">
    <header>
      <strong>Gautam Buddha University</strong>
      <h2>Attendance Sheet - Room <?= e($room) ?></h2>
      <p><?= e(date('d-m-Y',strtotime($allocation['exam_date'])).' | '.$allocation['shift_name'].' | '.substr($allocation['start_time'],0,5).'-'.substr($allocation['end_time'],0,5)) ?></p>
      <p class="no-print"><?= $locked?(($roomState['lock_reason']??'manual')==='automatic'?'Automatically locked at the deadline. Approve a correction request to reopen.':'Locked by the teacher. Approve a correction request to reopen.'):'Teachers can mark and lock this room. It locks automatically at exam end.' ?></p>
    </header>
    <table>
      <thead><tr><th>S.No.</th><th>Seat</th><th>Roll Number</th><th>Student Name</th><th>Programme</th><th>Paper</th><th>Attendance</th><th>Signature</th></tr></thead>
      <tbody>
      <?php foreach($items as $i=>$record): $id=(int)$record['id']; ?>
        <tr>
          <td><?= $i+1 ?></td>
          <td><?= e($record['seat_label']) ?></td>
          <td><strong><?= e($record['roll_no_original']) ?></strong></td>
          <td><?= e($record['name']) ?></td>
          <td><?= e($record['programme_code']) ?></td>
          <td><?= e($record['course_code']) ?></td>
          <td>
            <select name="status[<?= $id ?>]" data-attendance-status aria-label="Attendance for <?= e($record['roll_no_original']) ?>" <?= $locked?'disabled':'' ?>>
              <?php foreach(['unmarked','present','absent','unfair_means','withheld','other'] as $status): ?>
              <option value="<?= $status ?>" <?= $record['status']===$status?'selected':'' ?>><?= $status==='unfair_means'?'UFM (Unfair Means)':e(ucwords(str_replace('_',' ',$status))) ?></option>
              <?php endforeach; ?>
            </select>
            <label class="no-print">Remarks<input name="remarks[<?= $id ?>]" maxlength="255" value="<?= e($record['remarks']??'') ?>" <?= $locked?'disabled':'' ?>></label>
            <div class="no-print" data-attendance-ufm>
              <label>First answer-book serial<input name="ufm[<?= $id ?>][first_copy_serial]" maxlength="64" value="<?= e($record['first_copy_serial']??'') ?>" <?= $locked?'disabled':'' ?>></label>
              <label>Second answer-book serial (if issued)<input name="ufm[<?= $id ?>][second_copy_serial]" maxlength="64" value="<?= e($record['second_copy_serial']??'') ?>" <?= $locked?'disabled':'' ?>></label>
            </div>
          </td>
          <td class="signature"></td>
        </tr>
      <?php endforeach; ?>
      </tbody>
    </table>
    <footer><span>Invigilator Signature</span><span>Total: <?= count($items) ?></span></footer>
    <?php if(!$locked): ?><button class="primary-button no-print">Save room <?= e($room) ?></button><?php endif; ?>
  </section>
</form>
<?php endforeach; ?>
<script>
document.querySelectorAll('[data-attendance-status]').forEach(select=>{
  const fields=select.parentElement.querySelector('[data-attendance-ufm]');
  const update=()=>{
    fields.hidden=select.value!=='unfair_means';
    fields.querySelectorAll('input').forEach(input=>input.disabled=select.disabled||fields.hidden);
  };
  select.addEventListener('change',update);
  update();
});
</script>
