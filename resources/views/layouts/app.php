<?php $user = app()->auth()->user();$can=static fn(string $permission):bool=>app()->auth()->can($permission); $path = rtrim(parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?: '', '/'); ?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#173f35">
  <title><?= e($pageTitle ?? 'Dashboard') ?> | <?= e((string) config('app.name')) ?></title>
  <link rel="stylesheet" href="<?= e(url('assets/css/app.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/app.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/vendor/tabler-icons/tabler-icons.min.css?v=3.46.0')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/icon-system.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/icon-system.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/forms.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/imports.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/rooms.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/rooms.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/exams.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/exams.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/seating.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/seating.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/attendance.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/attendance.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/invigilation.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/invigilation.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/corrections.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/student-profile.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/brand.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/dashboard.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/dashboard.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/exam-cycles.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/master-governance.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/master-governance.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/legacy-modern.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/legacy-modern.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/navigation-slider.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/navigation-slider.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/rbac.css?v=' . (string) filemtime(BASE_PATH . '/public/assets/css/rbac.css'))) ?>">
</head>
<body class="admin-body">
  <a class="skip-link" href="#main-content">Skip to content</a>
  <aside id="app-sidebar" class="sidebar" aria-label="Primary navigation">
    <div class="brand">
      <span class="brand-mark"><img src="<?= e(url('assets/images/gbu-emblem.png')) ?>" alt="Gautam Buddha University"></span>
      <div class="brand-copy"><strong>Examination Cell</strong><small>Gautam Buddha University</small></div>
      <button id="sidebar-collapse" class="sidebar-collapse" type="button" aria-label="Collapse navigation" aria-controls="app-sidebar" aria-expanded="true"><span aria-hidden="true"></span></button>
    </div>
    <nav class="nav-groups">
      <p>Operations</p>
      <?php if($can('dashboard.view')):?><a aria-label="Dashboard" data-nav-short="DB" class="<?= str_ends_with($path, '/dashboard') ? 'active' : '' ?>" href="<?= e(url('dashboard')) ?>">Dashboard</a><?php endif;?>
      <?php if($can('exams.manage')):?>
      <a aria-label="Exam cycles" data-nav-short="EC" class="<?= str_contains($path, '/exam-cycles') ? 'active' : '' ?>" href="<?= e(url('exam-cycles')) ?>">Exam cycles</a>
      <a aria-label="Date sheets" data-nav-short="DS" class="<?= str_contains($path, '/date-sheets') ? 'active' : '' ?>" href="<?= e(url('exam-cycles')) ?>">Date sheets</a>
      <?php endif;?>
      <?php if($can('seating.manage')):?><a aria-label="Seating plans" data-nav-short="SP" class="<?= str_contains($path, '/seating') ? 'active' : '' ?>" href="<?= e(url('seating')) ?>">Seating plans</a><?php endif;?>
      <?php if($can('invigilation.manage')):?>
      <a aria-label="Invigilation" data-nav-short="IN" class="<?= str_contains($path, '/invigilation') ? 'active' : '' ?>" href="<?= e(url('invigilation')) ?>">Invigilation</a>
      <a aria-label="Replacements" data-nav-short="RP" class="<?= str_contains($path, '/replacements') ? 'active' : '' ?>" href="<?= e(url('replacements')) ?>">Replacements</a>
      <?php endif;?>
      <?php if($can('attendance.manage')):?><a aria-label="Attendance" data-nav-short="AT" class="<?= str_contains($path, '/attendance') ? 'active' : '' ?>" href="<?= e(url('attendance')) ?>">Attendance</a><?php endif;?>
      <?php if($can('reports.view')):?><a aria-label="Reports" data-nav-short="RE" class="<?= str_contains($path, '/reports') ? 'active' : '' ?>" href="<?= e(url('reports')) ?>">Reports</a><?php endif;?>
      <?php if($can('audit.view')):?><a aria-label="Audit logs" data-nav-short="AL" class="<?= str_contains($path, '/audit-logs') ? 'active' : '' ?>" href="<?= e(url('audit-logs')) ?>">Audit logs</a><?php endif;?>
      <?php if($can('academic.manage')||$can('students.manage')||$can('faculty.manage')||$can('rooms.manage')):?><p>Academic masters</p><?php endif;?>
      <?php if($can('academic.manage')):?>
      <a aria-label="Schools" data-nav-short="SC" class="<?= str_ends_with($path, '/masters/schools') ? 'active' : '' ?>" href="<?= e(url('masters/schools')) ?>">Schools</a>
      <a aria-label="Programmes" data-nav-short="PR" class="<?= str_ends_with($path, '/masters/programmes') ? 'active' : '' ?>" href="<?= e(url('masters/programmes')) ?>">Programmes</a>
      <a aria-label="Courses" data-nav-short="CO" class="<?= str_contains($path, '/courses') ? 'active' : '' ?>" href="<?= e(url('courses')) ?>">Courses</a>
      <?php endif;?>
      <?php if($can('students.manage')):?><a aria-label="Students" data-nav-short="ST" class="<?= str_contains($path, '/students') ? 'active' : '' ?>" href="<?= e(url('students')) ?>">Students</a><?php endif;?>
      <?php if($can('faculty.manage')):?><a aria-label="Faculty" data-nav-short="FA" class="<?= str_contains($path, '/faculty') ? 'active' : '' ?>" href="<?= e(url('faculty')) ?>">Faculty</a><?php endif;?>
      <?php if($can('rooms.manage')):?><a aria-label="Rooms" data-nav-short="RO" class="<?= str_contains($path, '/rooms') ? 'active' : '' ?>" href="<?= e(url('rooms')) ?>">Rooms</a><?php endif;?>
      <?php if($can('users.manage')):?><p>Administration</p><a aria-label="Users and roles" data-nav-short="UR" class="<?= str_contains($path, '/users') ? 'active' : '' ?>" href="<?= e(url('users')) ?>">Users &amp; roles</a><?php endif;?>
    </nav>
    <div class="sidebar-user">
      <div class="avatar"><?= e(strtoupper(substr($user['name'] ?? 'U', 0, 1))) ?></div>
      <div class="sidebar-user-copy"><strong><?= e($user['name'] ?? '') ?></strong><small><?= e($user['role_name'] ?? '') ?></small></div>
      <form method="post" action="<?= e(url('logout')) ?>"><?= csrf_field() ?><button type="submit">Sign out</button></form>
    </div>
  </aside><button id="sidebar-backdrop" class="sidebar-backdrop" type="button" aria-label="Close navigation" tabindex="-1"></button>
  <div class="app-frame">
    <header class="topbar">
      <div class="topbar-title"><button id="sidebar-toggle" class="sidebar-toggle" type="button" aria-label="Toggle navigation" aria-controls="app-sidebar" aria-expanded="true"><span aria-hidden="true"></span></button><div><p>Examination operations</p><strong><?= e($pageTitle ?? 'Dashboard') ?></strong></div></div>
      <div class="topbar-meta"><span><?= e(date('l, d F Y')) ?></span><b>Asia/Kolkata</b></div>
    </header>
    <main id="main-content" class="content"><?= $content ?></main>
  </div><script src="<?= e(url('assets/js/icon-system.js?v='.(string)filemtime(BASE_PATH.'/public/assets/js/icon-system.js'))) ?>"></script><script>(()=>{const body=document.body,sidebar=document.getElementById('app-sidebar'),toggle=document.getElementById('sidebar-toggle'),collapse=document.getElementById('sidebar-collapse'),backdrop=document.getElementById('sidebar-backdrop'),mobile=()=>matchMedia('(max-width:760px)').matches;const sync=()=>{const open=mobile()?body.classList.contains('nav-open'):!body.classList.contains('nav-collapsed');toggle.setAttribute('aria-expanded',String(open));collapse.setAttribute('aria-expanded',String(open));collapse.setAttribute('aria-label',open?'Collapse navigation':'Expand navigation');};const desktopToggle=()=>{body.classList.toggle('nav-collapsed');localStorage.setItem('gbu-nav-collapsed',body.classList.contains('nav-collapsed')?'1':'0');sync();};const mobileToggle=()=>{body.classList.toggle('nav-open');sync();if(body.classList.contains('nav-open'))sidebar.querySelector('a.active')?.focus();};if(!mobile()&&localStorage.getItem('gbu-nav-collapsed')==='1')body.classList.add('nav-collapsed');toggle.addEventListener('click',()=>mobile()?mobileToggle():desktopToggle());collapse.addEventListener('click',()=>mobile()?mobileToggle():desktopToggle());backdrop.addEventListener('click',mobileToggle);sidebar.querySelectorAll('a').forEach(link=>link.addEventListener('click',()=>{if(mobile())body.classList.remove('nav-open');}));addEventListener('keydown',event=>{if(event.key==='Escape'&&body.classList.contains('nav-open'))mobileToggle();});addEventListener('resize',()=>{if(!mobile())body.classList.remove('nav-open');sync();},{passive:true});sync();})();</script>
</body>
</html>
