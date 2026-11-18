const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
 const root=path.resolve(__dirname,'..'),output=path.join(root,'outputs/seating-publication');
 const browser=await chromium.launch({headless:true,channel:'chrome'});
 try{
  const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'});
  const errors=[];page.on('pageerror',error=>errors.push(error.message));
  await page.route('**/*',route=>{
   const request=route.request(),url=new URL(request.url());
   if(request.isNavigationRequest())return route.fulfill({contentType:'text/html',body:fs.readFileSync(path.join(output,url.pathname.endsWith('draft')?'draft.html':'published.html'),'utf8')});
   const match=url.pathname.match(/\/assets\/(.+)$/);
   if(match){
    const file=path.join(root,'public/assets',match[1]);
    if(fs.existsSync(file))return route.fulfill({body:fs.readFileSync(file),contentType:{'.css':'text/css','.js':'text/javascript','.png':'image/png','.woff2':'font/woff2'}[path.extname(file)]||'application/octet-stream'});
   }
   return route.abort();
  });
  await page.goto('http://seating.test/draft');
  assert.equal(await page.locator('form[action$="/publish"] button').isEnabled(),true,'Remaining students blocked the publish button');
  assert.match(await page.locator('#allocation-validation-note').innerText(),/Remaining students can be seated later/);
  assert.equal(await page.locator('#unallocated-students tbody tr').count(),4);
  assert.equal(await page.locator('form[action$="/allocate-remaining"]').count(),1);
  assert.equal(await page.getByRole('button',{name:'Allocate remaining students',exact:true}).isVisible(),true);
  for(const width of [1440,390]){
   await page.setViewportSize({width,height:1000});
   await page.screenshot({path:path.join(output,'partial-draft-'+width+'.png'),fullPage:true});
  }
  await page.goto('http://seating.test/published');
  assert.equal(await page.locator('form[action$="/publish"]').count(),0,'Published plan offered a publish button');
  assert.equal(await page.locator('form[action$="/allocate-remaining"] button').isEnabled(),true);
  assert.equal(await page.getByRole('button',{name:'Allocate remaining students',exact:true}).isVisible(),true);
  assert.equal(await page.locator('#unallocated-students tbody tr').count(),4);
  assert.match(await page.locator('#unallocated-students').innerText(),/Awaiting remaining allocation/);
  await page.screenshot({path:path.join(output,'published-remaining-mobile.png'),fullPage:true});
  assert.deepEqual(errors,[]);
  console.log('Partial seating UI: PASS (enabled publication, visible remaining queue, published-plan follow-up action, desktop and mobile rendering)');
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
