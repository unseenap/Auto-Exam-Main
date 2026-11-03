const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
 const root=path.resolve(__dirname,'..'),out=path.join(root,'outputs/faculty-panel');
 const browser=await chromium.launch({headless:true,channel:'chrome'});
 try{
  const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));let model=JSON.parse(fs.readFileSync(path.join(out,'snapshot.json'),'utf8')),fail='',posts=0;
  await page.route('**/*',async route=>{
   const request=route.request(),url=new URL(request.url());
   if(url.pathname.endsWith('/mark')){
    posts++;const data=new URLSearchParams(request.postData());
    if(fail==='network'){fail='';return route.fulfill({status:503,contentType:'application/json',body:JSON.stringify({error:'Temporary save failure'})});}
    if(fail==='conflict'){fail='';model.revision++;model.state.revision=model.revision;return route.fulfill({status:409,contentType:'application/json',body:JSON.stringify({error:'Another invigilator updated room IL-202. Reload the latest attendance.'})});}
    assert.equal(Number(data.get('revision')),model.revision,'Wrong revision sent');
    const record=model.records.find(r=>String(r.id)===data.get('record_id'));record.status=data.get('status');record.remarks=data.get('remarks');record.marked_at='2026-11-03 10:01:00';record.marked_name='Dr Aditi Sharma';
    model.revision++;model.state.revision=model.revision;model.state.edited_at=record.marked_at;model.state.editor_name=record.marked_name;
    return route.fulfill({contentType:'application/json',body:JSON.stringify({ok:true,revision:model.revision,saved_at:record.marked_at})});
   }
   if(url.pathname.endsWith('/snapshot'))return route.fulfill({contentType:'application/json',body:JSON.stringify(model)});
   if(request.isNavigationRequest())return route.fulfill({contentType:'text/html',body:'<!doctype html><title>Faculty test</title>'});
   const match=url.pathname.match(/\/assets\/(.+\.(?:css|png|woff2?|svg))$/);
   if(match){const file=path.join(root,'public/assets',match[1]);if(fs.existsSync(file))return route.fulfill({contentType:{'.css':'text/css','.png':'image/png','.woff2':'font/woff2','.svg':'image/svg+xml'}[path.extname(file)]||'application/octet-stream',body:fs.readFileSync(file)});}
   return route.abort();
  });
  const load=async(name,script=true)=>{await page.goto('http://faculty.test/'+name);await page.setContent(fs.readFileSync(path.join(out,name+'.html'),'utf8').replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,''));if(script)await page.addScriptTag({content:fs.readFileSync(path.join(root,'public/assets/js/faculty-panel.js'),'utf8')});};
  await load('home');assert.equal(await page.getByRole('link',{name:/Open room & attendance/}).count(),1);
  assert.equal(await page.locator('.sidebar a[href$="/users"]').count(),0,'Admin navigation leaked');
  assert.equal(await page.locator('.sidebar a[href*="faculty-panel"]').count(),5);
  await page.getByRole('button',{name:'Upcoming',exact:true}).click();assert.equal(await page.locator('.fp-duty-row:visible').count(),0);
  await page.getByRole('button',{name:'Today',exact:true}).click();assert.equal(await page.locator('.fp-duty-row:visible').count(),1);
  await page.screenshot({path:path.join(out,'faculty-home-desktop.png'),fullPage:true});
  for(const width of [390,768]){await page.setViewportSize({width,height:900});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Home overflow '+width);if(width===390)await page.screenshot({path:path.join(out,'faculty-home-mobile.png'),fullPage:true});}
  await page.setViewportSize({width:1440,height:1000});await load('room');
  assert.equal(await page.locator('[data-record]').count(),3);assert.match(await page.locator('#fp-student-2').innerText(),/245LCS001/);assert.match(await page.locator('#fp-student-2').innerText(),/0000100002/);
  await page.getByRole('button',{name:'Seat layout',exact:true}).click();assert.equal(await page.locator('.fp-seat').count(),6);assert.equal(await page.locator('.fp-seat-blocked').count(),1);
  await page.locator('[data-seat-record="2"]').click();assert.equal(await page.locator('#fp-student-2').evaluate(n=>n===document.activeElement),true);
  await page.locator('#fp-search').fill('0000100003');assert.equal(await page.locator('[data-record]:visible').count(),1);await page.locator('#fp-search').fill('');
  await page.locator('#fp-submit-form button').click();assert.match(await page.locator('#fp-save-error').innerText(),/3 students remain unmarked/);assert.equal(posts,0);
  await page.screenshot({path:path.join(out,'faculty-room-desktop.png'),fullPage:true});
  await page.locator('#fp-student-1 [data-mark="present"]').click();await page.waitForFunction(()=>document.getElementById('fp-count-present').textContent==='1');assert.equal(await page.locator('#fp-room').getAttribute('data-revision'),'1');
  fail='network';await page.locator('#fp-student-2 [data-mark="absent"]').click();await page.waitForFunction(()=>!document.getElementById('fp-save-error').hidden);assert.equal(await page.locator('#fp-count-absent').innerText(),'0','Unconfirmed change shown as saved');
  await page.locator('#fp-retry').click();await page.waitForFunction(()=>document.getElementById('fp-count-absent').textContent==='1');
  await page.locator('#fp-student-3 details summary').click();await page.locator('#fp-student-3 [data-exception]').selectOption('withheld');await page.locator('#fp-student-3 [data-save-exception]').click();assert.match(await page.locator('#fp-save-error').innerText(),/remarks/);
  await page.locator('#fp-student-3 [data-remarks]').fill('Answer book held for review');await page.locator('#fp-student-3 [data-save-exception]').click();await page.waitForFunction(()=>document.getElementById('fp-count-exceptions').textContent==='1');
  fail='conflict';await page.locator('#fp-student-1 [data-mark="absent"]').click();await page.waitForFunction(()=>!document.getElementById('fp-save-error').hidden);assert.equal(await page.locator('#fp-retry').isVisible(),false);assert.equal(await page.locator('#fp-student-1 [data-mark="present"]').isDisabled(),true);
  page.once('dialog',d=>d.accept());await page.locator('#fp-reload').click();await page.waitForFunction(()=>document.getElementById('fp-save-error').hidden);assert.equal(await page.locator('#fp-count-present').innerText(),'1');
  await page.setViewportSize({width:390,height:900});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Room overflow');await page.screenshot({path:path.join(out,'faculty-room-mobile.png'),fullPage:true});
  await load('submitted');assert.equal(await page.locator('.fp-mark-controls:not([disabled])').count(),0);assert.equal(await page.locator('#fp-submit-form button').isDisabled(),true);assert.match(await page.locator('.fp-report-section').innerText(),/1 collected · 1 expected/);
  await load('users',false);assert.ok(await page.locator('select[name="faculty_id"]').count()>1,'Account linking controls missing');
  assert.deepEqual(errors,[]);console.log('Faculty UI: PASS (personal navigation, duty filters, geometry, seat selection, roll/enrollment search, autosave/retry, conflict recovery, final locks, account linking, responsive layouts)');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
