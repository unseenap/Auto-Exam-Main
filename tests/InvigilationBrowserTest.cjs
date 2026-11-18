const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
 const root=path.resolve(__dirname,'..'),out=path.join(root,'outputs/invigilation');
 const browser=await chromium.launch({headless:true,channel:'chrome'});
 try{
  const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'});
  const errors=[];page.on('pageerror',error=>errors.push(error.message));
  await page.route('**/*',async route=>{
   const request=route.request(),url=new URL(request.url());
   if(request.isNavigationRequest())return route.fulfill({contentType:'text/html',body:fs.readFileSync(path.join(out,url.pathname.endsWith('/replacements')?'replacements.html':'index.html'),'utf8')});
   const match=url.pathname.match(/\/assets\/(.+)$/);
   if(match){
    const file=path.join(root,'public/assets',match[1]);
    if(fs.existsSync(file))return route.fulfill({body:fs.readFileSync(file),contentType:{'.css':'text/css','.png':'image/png','.js':'text/javascript','.woff2':'font/woff2'}[path.extname(file)]||'application/octet-stream'});
   }
   return route.abort();
  });
  await page.goto('http://invigilation.test/invigilation');
  assert.ok(await page.getByText('All rooms covered',{exact:true}).count()>0);
  assert.ok(await page.getByRole('button',{name:'Auto-allocate',exact:true}).count()>0);
  const cards=page.locator('.session-allocation');
  for(let i=0;i<await cards.count();i++){
   const card=cards.nth(i),complete=(await card.getAttribute('class')).includes('complete');
   assert.equal(await card.locator('form').count(),complete?0:1);
   assert.equal(await card.locator('a[href*="/attendance/"]').count(),1);
  }
  for(const width of [1440,768,390]){
   await page.setViewportSize({width,height:1000});
   assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Invigilation page overflows at '+width);
   assert.equal(await cards.evaluateAll(nodes=>nodes.every(node=>{
    const card=node.getBoundingClientRect(),actions=node.querySelector('.heading-actions').getBoundingClientRect();
    return actions.width>=100&&actions.left>=card.left&&actions.right<=card.right;
   })),true,'Room actions do not fit their cards at '+width);
   await page.screenshot({path:path.join(out,'invigilation-'+width+'.png'),fullPage:true});
  }
  await page.goto('http://invigilation.test/replacements');
  const pending=page.locator('[data-replacement-status="pending"]');
  assert.ok(await pending.count()>0);
  assert.equal(await pending.first().locator('select[name="replacement_faculty_id"]').getAttribute('required'),'');
  await page.getByRole('button',{name:/Rejected/}).click();
  assert.equal(await pending.first().isVisible(),false);
  await page.getByRole('button',{name:/Pending/}).click();
  assert.equal(await pending.first().isVisible(),true);
  for(const width of [1440,390]){
   await page.setViewportSize({width,height:1000});
   assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'Replacement page overflows at '+width);
   await page.screenshot({path:path.join(out,'replacements-'+width+'.png'),fullPage:true});
  }
  assert.deepEqual(errors,[]);
  console.log('Invigilation UI: PASS (coverage states, allocation buttons, attendance links, replacement selection, filters and responsive layouts)');
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
