const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
 const root=path.resolve(__dirname,'..'),out=path.join(root,'outputs/attendance-workflow');
 const browser=await chromium.launch({headless:true,channel:'chrome'});
 const model=JSON.parse(fs.readFileSync(path.join(out,'teacher-open.json'),'utf8'));
 const lockedRooms=JSON.parse(fs.readFileSync(path.join(out,'rooms-locked.json'),'utf8'));
 const errors=[];
 const load=async(name,{deadline=false,dirty=false}={})=>{
  const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'});
  page.on('pageerror',error=>errors.push(error.message));
  let html=fs.readFileSync(path.join(out,name+'.html'),'utf8');
  if(deadline)html=html.replace(/data-lock-seconds="[^"]*"/,'data-lock-seconds="0.05"');
  if(dirty)html=html.replace('<textarea data-remarks maxlength="255"></textarea>','<textarea data-remarks maxlength="255">Unsaved note</textarea>');
  await page.route('**/*',route=>{
   const request=route.request(),url=new URL(request.url());
   if(url.pathname.endsWith('/snapshot')){
    let response;
    if(url.pathname.includes('/faculty-panel/')){
     response=structuredClone(model);
     if(deadline){
      response.state.status='submitted';response.state.lock_reason='automatic';response.state.submitted_by=null;
      response.state.submitted_at='2026-12-01 12:00:00';response.revision++;
      response.window.allowed=false;response.window.remaining_seconds=0;
     }
    }else response=lockedRooms;
    return route.fulfill({contentType:'application/json',body:JSON.stringify(response)});
   }
   if(request.isNavigationRequest())return route.fulfill({contentType:'text/html',body:html});
   const match=url.pathname.match(/\/assets\/(.+)$/);
   if(match){
    const file=path.join(root,'public/assets',match[1]);
    if(fs.existsSync(file))return route.fulfill({body:fs.readFileSync(file),contentType:{'.css':'text/css','.js':'text/javascript','.png':'image/png','.woff2':'font/woff2'}[path.extname(file)]||'application/octet-stream'});
   }
   return route.abort();
  });
  await page.goto('http://attendance.test/'+name);
  return page;
 };
 try{
  let page=await load('teacher-open');
  assert.equal(await page.locator('[data-mark="present"]').first().isEnabled(),true);
  assert.equal(await page.locator('a[href$="/duties/1/export.xlsx"]').count(),1);
  assert.match(await page.locator('#fp-lock-countdown').innerText(),/Automatic lock in/);
  await page.locator('#fp-student-1 details summary').click();
  await page.locator('#fp-student-1 [data-exception]').selectOption('withheld');
  assert.equal(await page.locator('#fp-submit-form button').isDisabled(),true,'Unsaved attendance selection allowed locking');
  await page.locator('#fp-student-1 [data-exception]').selectOption('unmarked');
  assert.equal(await page.locator('#fp-submit-form button').isEnabled(),true);
  await page.locator('#fp-student-1 details summary').click();
  await page.evaluate(()=>scrollTo(0,0));
  await page.screenshot({path:path.join(out,'teacher-open-desktop.png'),fullPage:true});
  await page.setViewportSize({width:390,height:1000});
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Teacher page overflows mobile');
  await page.screenshot({path:path.join(out,'teacher-open-mobile.png'),fullPage:true});
  await page.close();
  page=await load('teacher-open',{deadline:true});
  await page.waitForFunction(()=>document.getElementById('fp-submission-status').textContent==='Automatically locked');
  assert.equal(await page.locator('[data-mark="present"]').first().isDisabled(),true);
  assert.equal(await page.locator('#fp-submit-form button').isDisabled(),true);
  assert.equal(await page.locator('[data-request-correction]').isEnabled(),true);
  await page.close();
  page=await load('teacher-open',{deadline:true,dirty:true});
  await page.waitForFunction(()=>!document.getElementById('fp-save-error').hidden);
  assert.match(await page.locator('#fp-save-error').innerText(),/Unsaved changes/);
  assert.equal(await page.locator('[data-mark="present"]').first().isDisabled(),true);
  assert.equal(await page.locator('[data-remarks]').first().inputValue(),'Unsaved note');
  await page.close();
  page=await load('teacher-locked');
  assert.match(await page.locator('#fp-submission-status').innerText(),/Automatically locked/);
  assert.equal(await page.locator('.fp-mark-controls:not([disabled])').count(),0);
  assert.equal(await page.locator('#fp-count-unmarked').innerText(),'1');
  assert.equal(await page.locator('#fp-report-form button').isDisabled(),true);
  await page.close();
  page=await load('admin');
  assert.equal(await page.locator('a[href*="/rooms/"][href$="/export.xlsx"]').count(),2);
  assert.ok(await page.locator('a[href*="/attendance/cycles/"][href$="/export.xlsx"]').count()>0);
  await page.evaluate(()=>dispatchEvent(new Event('focus')));
  await page.waitForFunction(()=>document.querySelector('[data-attendance-refresh]').textContent.startsWith('Updated'));
  const table=page.locator('[data-attendance-room-rows]');
  assert.match(await table.innerText(),/Teacher One, Teacher Two/);
  assert.match(await table.innerText(),/Automatically locked/);
  assert.equal(await page.locator('[data-attendance-metric="unmarked"]').first().innerText(),'1');
  await page.screenshot({path:path.join(out,'admin-desktop.png'),fullPage:true});
  await page.setViewportSize({width:390,height:1000});
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Admin page overflows mobile');
  await page.screenshot({path:path.join(out,'admin-mobile.png'),fullPage:true});
  await page.close();
  assert.deepEqual(errors,[]);
  console.log('Attendance workflow UI: PASS (teacher deadline countdown, automatic locking, unsaved-change handling, correction access, admin live updates, room/master download links and responsive layouts)');
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
