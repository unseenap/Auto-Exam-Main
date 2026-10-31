const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {chromium}=require('playwright');
(async()=>{
  const root=path.resolve(__dirname,'..'),out=path.join(root,'outputs/draft-date-sheet-deletion');
  const browser=await chromium.launch({headless:true,channel:'chrome'});
  try{
    const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
    page.on('pageerror',e=>errors.push(e.message));
    await page.route('**/*',route=>{
      if(route.request().isNavigationRequest())return route.fulfill({body:'<!doctype html>'});
      const match=new URL(route.request().url()).pathname.match(/\/assets\/(.+\.(?:css|png|woff2?|svg))$/);
      if(match){const file=path.join(root,'public/assets',match[1]);if(fs.existsSync(file))return route.fulfill({contentType:path.extname(file)==='.css'?'text/css':'application/octet-stream',body:fs.readFileSync(file)});}
      return route.abort();
    });
    await page.goto('http://draft.test/');
    for(const name of ['date-sheet','review']){
      await page.setContent(fs.readFileSync(path.join(out,name+'.html'),'utf8').replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,''));
      const button=page.getByRole('button',{name:/Delete draft #/});assert.equal(await button.count(),1);
      const form=button.locator('..');assert.equal(await form.getAttribute('method'),'post');
      assert.match(await form.getAttribute('action'),/\/automatic\/runs\/\d+\/delete$/);
      assert.ok(await form.locator('[name="_token"]').inputValue(),'CSRF token missing');
      await form.evaluate(n=>{window.deleteSubmissions=0;n.addEventListener('submit',e=>{if(!e.defaultPrevented)window.deleteSubmissions++;e.preventDefault();});});
      page.once('dialog',dialog=>dialog.dismiss());await button.click();
      assert.equal(await page.evaluate(()=>window.deleteSubmissions),0,'Cancel submitted deletion');
      page.once('dialog',dialog=>dialog.accept());await button.click();
      assert.equal(await page.evaluate(()=>window.deleteSubmissions),1,'Confirm did not submit deletion');
      if(name==='date-sheet')await page.screenshot({path:path.join(out,'draft-delete-desktop.png'),fullPage:true});
      await page.setViewportSize({width:390,height:900});assert.equal(await button.isVisible(),true);
      await page.setViewportSize({width:1440,height:1000});
    }
    assert.deepEqual(errors,[]);console.log('Draft deletion UI: PASS (list/review actions, POST, CSRF, cancel/confirm, mobile access)');
  }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
