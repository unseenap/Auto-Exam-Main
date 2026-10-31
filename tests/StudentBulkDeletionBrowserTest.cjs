const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
 const root=path.resolve(__dirname,'..'),output=path.join(root,'outputs/student-bulk-delete');
 const browser=await chromium.launch({headless:true,channel:process.env.PLAYWRIGHT_CHANNEL||'chrome'});
 try{
  const page=await browser.newPage({viewport:{width:1280,height:900},reducedMotion:'reduce'}),errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.route('**/*',route=>{
   if(route.request().isNavigationRequest())return route.fulfill({contentType:'text/html',body:'<!doctype html><title>Bulk deletion UI test</title>'});
   const match=new URL(route.request().url()).pathname.match(/\/assets\/(.+\.(?:css|png|woff2?|svg))$/);
   if(match){const file=path.join(root,'public/assets',match[1]),type={'.css':'text/css','.png':'image/png','.woff':'font/woff','.woff2':'font/woff2','.svg':'image/svg+xml'}[path.extname(file)];if(fs.existsSync(file))return route.fulfill({contentType:type,body:fs.readFileSync(file)});}return route.abort();
  });
  await page.goto('http://bulk-delete.test/');
  const load=async(name,script)=>{
   await page.setContent(fs.readFileSync(path.join(output,name),'utf8').replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,''));
   if(script)await page.addScriptTag({content:fs.readFileSync(path.join(root,'public/assets/js/student-bulk-delete.js'),'utf8')});
  };
  await load('form.html',true);
  const scope=page.locator('#student-bulk-scope'),target=page.locator('#student-bulk-target');
  assert.equal(await target.isDisabled(),true);
  await scope.selectOption('school');assert.equal(await target.isDisabled(),false);assert.equal(await target.locator('option').count(),3);
  await target.selectOption('1');await scope.selectOption('department');assert.equal(await target.inputValue(),'');assert.ok(await target.locator('option[value="id:1"]').count());assert.ok(await target.locator('option[value="name:Computing"]').count());
  await scope.selectOption('branch');assert.ok(await target.locator('option[value="id:2"]').count());assert.ok(await target.locator('option[value^="name:"]').count());
  await scope.selectOption('all');assert.equal(await target.isDisabled(),true);assert.equal(await target.inputValue(),'');
  assert.match(await page.locator('#student-bulk-scope-help').innerText(),/every student/);
  await scope.selectOption('review');assert.equal(await target.isDisabled(),true);assert.equal(await target.inputValue(),'');assert.equal(await target.getAttribute('required'),null);
  assert.match(await page.locator('#student-bulk-scope-help').innerText(),/parsing status Review/);
  assert.equal(await page.locator('#student-bulk-scope-form').evaluate(n=>n.checkValidity()),true,'Review scope requires an unnecessary group');
  assert.equal(await page.locator('#student-bulk-scope-form').getAttribute('method'),'post');
  assert.match(await page.locator('#student-bulk-scope-form').getAttribute('action'),/\/preview$/);
  await scope.selectOption('school');await target.selectOption('1');await page.evaluate(()=>window.scrollTo(0,0));
  await page.screenshot({path:path.join(output,'bulk-delete-form.png'),fullPage:true});
  await load('review.html',false);
  assert.equal(await page.locator('.student-bulk-badge.protected').count(),2);assert.equal(await page.locator('.student-bulk-badge.delete').count(),1);
  assert.deepEqual(await page.locator('.student-bulk-counts dd').allTextContents(),['3','1','2']);
  const confirmation=page.locator('#student-bulk-confirmation');await confirmation.fill('DELETE 999');assert.equal(await confirmation.evaluate(n=>n.checkValidity()),false);await confirmation.fill('DELETE 1');assert.equal(await confirmation.evaluate(n=>n.checkValidity()),true);
  assert.equal(await page.locator('.student-bulk-confirm input[name="preview_token"]').count(),1);
  assert.equal(await page.locator('.student-bulk-confirm input[name="scope"]').count(),0,'Scope should come from the server snapshot');
  await page.evaluate(()=>window.scrollTo(0,0));await page.screenshot({path:path.join(output,'bulk-delete-review.png'),fullPage:true});
  for(const width of [390,768]){await page.setViewportSize({width,height:900});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth),true,'Review overflow at '+width);if(width===390)await page.screenshot({path:path.join(output,'bulk-delete-mobile.png'),fullPage:true});}
  assert.deepEqual(errors,[]);console.log('Student bulk deletion UI: PASS (scope options, filtered targets, all-students scope, protected counts, typed confirmation, responsive layout)');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
