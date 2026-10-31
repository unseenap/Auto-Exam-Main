const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
  const root=path.resolve(__dirname,'..'),output=path.join(root,'outputs/scheduler-validation-highlights');
  const browser=await chromium.launch({headless:true,channel:'chrome'});
  try{
    const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),errors=[];
    page.on('pageerror',e=>errors.push(e.message));
    await page.route('**/*',route=>{
      if(route.request().isNavigationRequest())return route.fulfill({body:'<!doctype html>'});
      const match=new URL(route.request().url()).pathname.match(/\/assets\/(.+\.(?:css|png|woff2?|svg))$/);
      if(match){const file=path.join(root,'public/assets',match[1]);if(fs.existsSync(file))return route.fulfill({contentType:path.extname(file)==='.css'?'text/css':'application/octet-stream',body:fs.readFileSync(file)});}
      return route.abort();
    });
    await page.goto('http://scheduler.test/');
    await page.setContent(fs.readFileSync(path.join(output,'planner.html'),'utf8').replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,''));
    await page.addScriptTag({content:fs.readFileSync(path.join(root,'public/assets/js/scheduler-validation-highlights.js'),'utf8')});
    const paper=page.locator('[name="programme_course_ids[]"][value="1"]');
    assert.equal(await paper.getAttribute('aria-invalid'),'true');
    assert.equal(await paper.locator('..').getAttribute('data-validation-severity'),'blocked');
    assert.equal(await page.locator('#scheduler-cycle-session').getAttribute('data-validation-severity'),'warning');
    assert.equal(await page.locator('[data-programme-card].scheduler-selection-issue').count(),0,'Unrelated branch highlighted');
    assert.equal(await page.getByText('Inactive paper',{exact:true}).count(),1);
    const checked=await paper.isChecked();
    await page.locator('[data-validation-code="priority.invalid"] .scheduler-show-selection').click();
    assert.equal(await paper.evaluate(n=>n===document.activeElement),true);
    assert.equal(await paper.isChecked(),checked,'Jump changed selection');
    await paper.locator('..').evaluate(n=>n.hidden=true);
    await page.locator('[data-validation-code="courses.inactive"] .scheduler-show-selection').click();
    assert.equal(await paper.isVisible(),true,'Jump did not reveal filtered paper');
    await page.screenshot({path:path.join(output,'validation-desktop.png'),fullPage:true});
    await page.setViewportSize({width:390,height:900});
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Mobile overflow');
    await page.screenshot({path:path.join(output,'validation-mobile.png'),fullPage:true});
    await page.evaluate(()=>{
      document.getElementById('saved-validation').hidden=true;
      const live=document.getElementById('live-validation');live.hidden=false;
      live.innerHTML='<article class="validation-check pass" data-validation-code="curriculum.complete"><div><p>All ready</p></div></article>';
    });
    await page.waitForFunction(()=>!document.querySelector('.scheduler-selection-issue'));
    assert.equal(await paper.getAttribute('aria-invalid'),null,'Stale accessibility error');
    assert.equal(await page.locator('.scheduler-show-selection').count(),0);
    await page.evaluate(()=>{
      document.querySelector('[name="programme_course_ids[]"]').checked=false;
      document.getElementById('live-validation').innerHTML='<div class="validation-empty"><p>Select at least one paper</p></div>';
    });
    await page.waitForFunction(()=>document.querySelector('#subjects-heading').closest('.scheduler-section').dataset.validationSeverity==='blocked');
    assert.deepEqual(errors,[]);
    console.log('Scheduler validation UI: PASS (exact errors, warnings, inactive papers, jump/focus, reveal, selection preservation, stale-state clearing, mobile layout)');
  }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
