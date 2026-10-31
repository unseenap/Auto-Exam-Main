<form method="post" action="<?= e(url('date-sheets/'.$draftCycleId.'/automatic/runs/'.$draftRunId.'/delete')) ?>" onsubmit="return confirm('Delete draft #<?= (int)$draftRunId ?> and its draft papers? This cannot be undone. Papers used by other runs and the exam cycle will be kept.')">
  <?= csrf_field() ?>
  <button class="secondary-button" style="color:#b33e36;border-color:#e0b0ab" type="submit" aria-label="Delete draft #<?= (int)$draftRunId ?>"><i class="ti ti-trash" aria-hidden="true"></i> Delete draft</button>
</form>
