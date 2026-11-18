<section class="panel attendance-live-rooms no-print" data-attendance-live
    data-snapshot="<?= e(url(isset($allocation)?'attendance/'.$allocation['id'].'/snapshot':'attendance/snapshot')) ?>"
    data-base="<?= e(url('')) ?>">
  <header class="attendance-live-heading">
    <div><h2>Teacher attendance updates</h2><p>Shared room sheets refresh every 15 seconds. Scroll across for marking and lock details.</p></div>
    <span data-attendance-refresh role="status">Live room register</span>
  </header>
  <div class="table-scroll">
    <table>
      <thead><tr><th>Exam session</th><th>Room / Excel</th><th>Assigned teachers</th><th>Students</th><th>Present</th><th>Absent</th><th>UFM</th><th>Unmarked</th><th>Lock status</th><th>Last saved</th></tr></thead>
      <tbody data-attendance-room-rows>
      <?php foreach($roomSummaries as $summary):
          $submitted=$summary['submission_status']==='submitted';
          $status=$submitted?($summary['submitted_by']?'Teacher locked':'Automatically locked'):((int)$summary['revision']?'In progress':'Not started');
      ?>
        <tr>
          <td><strong><?= e($summary['cycle_name']) ?></strong><small><?= e($summary['exam_date'].' · '.$summary['shift_name']) ?></small></td>
          <td><a href="<?= e(url('attendance/'.$summary['allocation_id'].'#attendance-room-'.$summary['room_id'])) ?>"><?= e($summary['room_code']) ?></a><small><a href="<?= e(url('attendance/'.$summary['allocation_id'].'/rooms/'.$summary['room_id'].'/export.xlsx')) ?>">Room Excel</a></small></td>
          <td><?= e($summary['teachers']?:'Teachers awaiting allocation') ?></td>
          <?php foreach(['students','present','absent','ufm','unmarked'] as $count): ?><td><?= (int)$summary[$count] ?></td><?php endforeach; ?>
          <td><strong><?= e($status) ?></strong><?php if($submitted): ?><small><?= e($summary['locked_by'].' · '.$summary['submitted_at']) ?></small><?php endif; ?></td>
          <td><?= e($summary['updated_by']?:'No teacher update') ?><small><?= e($summary['updated_at']??'') ?></small></td>
        </tr>
      <?php endforeach; ?>
      <?php if(!$roomSummaries): ?><tr><td colspan="10">No published room attendance sheets yet.</td></tr><?php endif; ?>
      </tbody>
    </table>
  </div>
</section>
<script src="<?= e(url('assets/js/attendance-live.js?v='.(string)filemtime(BASE_PATH.'/public/assets/js/attendance-live.js'))) ?>" defer></script>
