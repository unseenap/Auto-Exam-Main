<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d3b31">
  <title>Sign in | GBU Examination Operations</title>
  <link rel="stylesheet" href="<?= e(url('assets/css/app.css')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/vendor/tabler-icons/tabler-icons.min.css?v=3.46.0')) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/icon-system.css?v='.(string)filemtime(BASE_PATH.'/public/assets/css/icon-system.css'))) ?>">
  <link rel="stylesheet" href="<?= e(url('assets/css/login.css?v='.(string)filemtime(BASE_PATH.'/public/assets/css/login.css'))) ?>">
</head>
<body class="login-page">
  <a class="skip-link" href="#login-form">Skip to sign in</a>
  <main class="login-shell">
    <section class="login-context" aria-labelledby="portal-title">
      <header class="login-university">
        <div class="login-university-mark"><img src="<?= e(url('assets/images/gbu-emblem.png')) ?>" alt="" width="68" height="68"><div><strong>Gautam Buddha University</strong><small>Greater Noida, Uttar Pradesh</small></div></div>
        <span>Examination Cell</span>
      </header>
      <div class="login-message">
        <p class="login-kicker">Examination Operations Portal</p>
        <h1 id="portal-title">The right access for every examination duty.</h1>
        <p>Role-governed planning for date sheets, curriculum, rooms, seating, attendance, invigilation, and compliance.</p>
        <div class="login-role-strip" aria-label="Role governed access"><span>Academic</span><span>Examinations</span><span>Seating</span><span>Invigilation</span><span>Audit</span></div>
      </div>
      <footer class="login-assurance">
        <strong>Restricted university system</strong>
        <span>Access is monitored and changes are retained in the audit trail.</span>
      </footer>
    </section>

    <section class="login-panel" aria-labelledby="login-title">
      <div class="login-form-wrap">
        <div class="login-form-brand"><img src="<?= e(url('assets/images/gbu-full-logo.png')) ?>" alt="Gautam Buddha University" width="330" height="122"></div>
        <div class="login-heading">
          <p>Authorized access</p>
          <h2 id="login-title">Welcome back</h2>
          <span>Enter your Examination Cell credentials to continue.</span>
        </div>
        <?php $oldUsername=(string)app()->session()->pullFlash('login_username','');if ($message=app()->session()->pullFlash('error')): ?>
          <div class="login-alert" role="alert"><strong>Sign-in unsuccessful</strong><span><?= e($message) ?></span></div>
        <?php endif; ?>
        <form id="login-form" method="post" action="<?= e(url('login')) ?>" class="login-form">
          <?= csrf_field() ?>
          <label for="username">Username</label>
          <input id="username" name="username" type="text" autocomplete="username" autocapitalize="none" spellcheck="false" placeholder="Enter your username" value="<?= e($oldUsername) ?>" required autofocus>
          <div class="password-label"><label for="password">Password</label><button id="password-toggle" type="button" aria-controls="password" aria-pressed="false"><i class="ti ti-eye" aria-hidden="true"></i><span>Show password</span></button></div>
          <div class="password-control"><input id="password" name="password" type="password" autocomplete="current-password" placeholder="Enter your password" required><span id="caps-warning" role="status" hidden>Caps Lock is on</span></div>
          <button class="login-submit" type="submit"><span><i class="ti ti-login-2" aria-hidden="true"></i> Sign in securely</span><i class="ti ti-arrow-right" aria-hidden="true"></i></button>
        </form>
        <div class="login-security"><span><b aria-hidden="true"></b>Role-based access enabled</span><span>Protected session · Audited changes</span></div><div class="login-help"><strong>Having trouble signing in?</strong><span>Contact the Examination Cell administrator. Do not share credentials by email or messaging applications.</span></div>
      </div>
      <footer class="login-legal">Gautam Buddha University, Greater Noida, Uttar Pradesh</footer>
    </section>
  </main>
  <script>
    (()=>{const button=document.getElementById('password-toggle'),input=document.getElementById('password'),warning=document.getElementById('caps-warning'),form=document.getElementById('login-form'),submit=form?.querySelector('.login-submit');button?.addEventListener('click',()=>{const visible=input.type==='text';input.type=visible?'password':'text';button.querySelector('span').textContent=visible?'Show password':'Hide password';button.querySelector('i').className=visible?'ti ti-eye':'ti ti-eye-off';button.setAttribute('aria-pressed',String(!visible));input.focus();});input?.addEventListener('keyup',event=>{warning.hidden=!event.getModifierState('CapsLock');});form?.addEventListener('submit',()=>{submit.disabled=true;submit.querySelector('span').textContent='Verifying access...';});})();
  </script>
</body>
</html>
