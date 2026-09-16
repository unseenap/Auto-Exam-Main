<?php $pageTitle='Delete examination cycle'; ?>
<section class="page-heading"><div><p class="eyebrow">Confirmation <?= (int)$step ?> of 2</p><h1>Delete examination cycle</h1><p><?= e($preview['cycle']['name']) ?></p></div><a class="secondary-button" href="<?= e(url('exam-cycles')) ?>">Cancel and keep cycle</a></section>
<section class="panel quick-form">
<div class="alert error" role="alert">Permanent deletion. Recovery requires a database backup. No records are removed until both confirmation steps are completed.</div>
<?php if($preview['cycle']['status']==='published'):?><div class="alert error">You are deleting a published date sheet and its entire examination cycle, not just unpublishing it. Previously downloaded or printed copies will not be recalled.</div><?php endif;?>
<h2>Records that will be removed</h2><ul><?php foreach($preview['counts'] as $label=>$count):?><li><?= e($label) ?>: <?= (int)$count ?></li><?php endforeach;?></ul>
<p>This also removes their cohort links, eligibility, draft seat assignments, scheduling rules/conflicts and shift-specific faculty availability. Students, courses, faculty, rooms and audit history are retained.</p>
<?php if($step===1):?>
<form method="post" action="<?= e(url('exam-cycles/'.$preview['cycle']['id'].'/delete/confirm')) ?>"><?= csrf_field() ?><label><input type="checkbox" name="acknowledge" value="1" required> I have reviewed the records above and understand that deletion is permanent.</label><button class="secondary-button" type="submit">Continue to final confirmation</button></form>
<?php else:?>
<form method="post" action="<?= e(url('exam-cycles/'.$preview['cycle']['id'].'/delete')) ?>"><?= csrf_field() ?><input type="hidden" name="deletion_token" value="<?= e($token) ?>"><label>Type the exact cycle name to confirm<input name="confirmation_name" autocomplete="off" required></label><p>Enter: <strong><?= e($preview['cycle']['name']) ?></strong></p><button class="secondary-button" type="submit">Permanently delete this cycle</button></form>
<?php endif;?>
</section>
