<?php
$pageTitle='Rooms';
$roomTotals=['all'=>count($rooms),'active'=>0,'inactive'=>0,'maintenance'=>0];
foreach($rooms as $room)if(isset($roomTotals[$room['status']]))$roomTotals[$room['status']]++;
$availableRoomSeats=static fn(array $room):int=>$room['status']==='active'&&!empty($room['school_id'])&&($room['school_status']??'')==='active'?max(0,min((int)$room['usable_capacity'],(int)($room['unblocked_seats']??0))):0;
$availableTotal=array_sum(array_map($availableRoomSeats,$rooms));
?>
<link rel="stylesheet" href="<?= e(url('assets/css/rooms-dashboard.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/rooms-dashboard.css'))) ?>">
<div class="rooms-dashboard">
<header class="rooms-heading"><div><p class="rooms-eyebrow">Examination infrastructure</p><h1>Rooms & seat maps</h1><p>Find a room, check its availability, and manage its seating layout.</p></div><div class="rooms-heading-actions"><a class="secondary-button" href="<?= e(url('rooms/import')) ?>"><i class="ti ti-upload" aria-hidden="true"></i>Bulk import</a><a class="primary-button" href="<?= e(url('rooms/create')) ?>"><span aria-hidden="true">＋</span>Add room</a></div></header>
<?php if($success):?><div class="alert success" role="status"><?= e($success) ?></div><?php endif;?>
<?php if($error):?><div class="alert error" role="alert"><?= e($error) ?></div><?php endif;?>
<nav class="rooms-status-filters" aria-label="Filter rooms by operational status">
<?php foreach(['all'=>'All rooms','active'=>'Active','inactive'=>'Inactive','maintenance'=>'Maintenance'] as $status=>$label):?><button type="button" data-room-filter="<?= e($status) ?>" aria-pressed="<?= $status==='all'?'true':'false' ?>" disabled><span><i class="ti <?= ['all'=>'ti-building','active'=>'ti-circle-check','inactive'=>'ti-circle-off','maintenance'=>'ti-tool'][$status] ?>" aria-hidden="true"></i><?= e($label) ?></span><strong><?= number_format($roomTotals[$status]) ?></strong><small><?= ['all'=>'In the selected school scope','active'=>'Room enabled','inactive'=>'Excluded from seating','maintenance'=>'Temporarily unavailable'][$status] ?></small></button><?php endforeach;?>
</nav>
<section class="rooms-seat-summary" aria-label="Seat availability"><div><i class="ti ti-armchair" aria-hidden="true"></i><strong id="rooms-available-total"><?= number_format($availableTotal) ?></strong><span>seats available for allocation</span></div><p>For rooms matching your filters. Blocked seats and unavailable rooms or schools are excluded.</p></section>
<section class="rooms-toolbar" aria-label="Find rooms">
<label class="rooms-search-label" for="room-search">Find a room<div class="rooms-search-field"><i class="ti ti-search" aria-hidden="true"></i><input type="search" id="room-search" placeholder="Search room, building or school…" disabled></div></label>
<form method="get" class="rooms-school-filter"><label for="rooms-school">School<select id="rooms-school" name="school_id"><option value="0">All schools</option><?php foreach($schools as $school):?><option value="<?= (int)$school['id'] ?>" <?= $schoolId===(int)$school['id']?'selected':'' ?>><?= e($school['code'].' — '.$school['name']) ?></option><?php endforeach;?></select></label><button class="secondary-button" type="submit">Apply school</button></form>
</section>
<div class="rooms-register-heading"><div><h2>Room directory</h2><p id="room-results" role="status"><?= count($rooms) ?> rooms in this school scope</p></div><span><i class="ti ti-info-circle" aria-hidden="true"></i>Inactive and maintenance rooms are excluded from automatic seating.</span></div>
<section class="rooms-directory" aria-label="Room directory">
<?php foreach($rooms as $room): $status=$room['status']; ?>
<article class="rooms-directory-card" data-room-status="<?= e($status) ?>" data-room-available="<?= $availableRoomSeats($room) ?>" data-room-search="<?= e($room['code'].' '.$room['building'].' '.($room['school_code']??'School unassigned').' '.($room['school_name']??'')) ?>">
<header><div class="rooms-card-identity"><span class="rooms-door-icon"><i class="ti ti-door" aria-hidden="true"></i></span><div><p><?= e($room['school_code']??'School unassigned') ?></p><h3><a href="<?= e(url('rooms/'.$room['id'].'/layout')) ?>"><?= e($room['code']) ?></a></h3></div></div><span class="room-operational-status <?= e($status) ?>"><i aria-hidden="true"></i><?= e(ucfirst($status)) ?></span></header>
<p class="rooms-location"><i class="ti ti-map-pin" aria-hidden="true"></i><?= e($room['building']) ?><?= !empty($room['floor'])?' · '.e($room['floor']):'' ?></p>
<?php if(empty($room['school_id'])):?><p class="rooms-school-warning">Assign a school before using this room for seating.</p><?php endif;?>
<div class="rooms-card-capacity"><div><strong><?= number_format($availableRoomSeats($room)) ?></strong><span>available seats</span></div><span><?= number_format((int)$room['usable_capacity']) ?> configured usable<br><?= number_format((int)$room['physical_capacity']) ?> physical positions</span></div>
<dl class="rooms-card-facts"><div><dt>Geometry</dt><dd><?= (int)$room['rows_count'] ?> × <?= (int)$room['columns_count'] ?><small>rows × columns</small></dd></div><div><dt>Blocked seats</dt><dd><?= (int)$room['blocked_seats'] ?></dd></div><div><dt>Priority</dt><dd><?= (int)$room['priority'] ?></dd></div></dl>
<div class="rooms-fill-order"><i class="ti ti-layout-grid" aria-hidden="true"></i><?= e(ucfirst(str_replace('_',' ',$room['seat_order']))) ?> fill order</div>
<footer><div class="rooms-main-actions"><a class="rooms-layout-action" href="<?= e(url('rooms/'.$room['id'].'/layout')) ?>" aria-label="View layout for <?= e($room['code']) ?>"><i class="ti ti-layout-grid" aria-hidden="true"></i>View layout</a><a href="<?= e(url('rooms/'.$room['id'].'/layout.xlsx')) ?>" aria-label="Download layout Excel for <?= e($room['code']) ?>"><i class="ti ti-file-spreadsheet" aria-hidden="true"></i>Excel</a><a href="<?= e(url('rooms/'.$room['id'].'/edit')) ?>" aria-label="Edit room <?= e($room['code']) ?>"><i class="ti ti-edit" aria-hidden="true"></i>Edit</a></div><details class="rooms-more"><summary aria-label="More actions for <?= e($room['code']) ?>">More</summary><form method="post" action="<?= e(url('rooms/'.$room['id'].'/delete')) ?>" data-confirm="<?= e('Delete room '.$room['code'].' and its seat layout? This will be blocked if seating or invigilation records use it.') ?>" onsubmit="return window.confirm(this.dataset.confirm)"><?= csrf_field() ?><button type="submit"><i class="ti ti-trash" aria-hidden="true"></i>Delete room</button></form></details></footer>
</article>
<?php endforeach;?>
</section>
<?php if(!$rooms):?><section class="rooms-empty"><i class="ti ti-building" aria-hidden="true"></i><h2><?= $schoolId?'No rooms in this school':'No rooms configured yet' ?></h2><p>Add a room or import room details to build your seat maps.</p><a class="primary-button" href="<?= e(url('rooms/create')) ?>">Add room</a><?php if($schoolId):?><a class="secondary-button" href="<?= e(url('rooms')) ?>">View all schools</a><?php endif;?></section><?php endif;?>
<section class="rooms-empty" id="room-filter-empty" hidden><i class="ti ti-search" aria-hidden="true"></i><h2>No matching rooms</h2><p>Try another room name or operational status.</p><button type="button" class="secondary-button" id="room-reset-filters">Clear search and status</button></section>
</div>
<script src="<?= e(url('assets/js/rooms-dashboard.js?v=' . (string) filemtime(BASE_PATH . '/public/assets/js/rooms-dashboard.js'))) ?>" defer></script>
