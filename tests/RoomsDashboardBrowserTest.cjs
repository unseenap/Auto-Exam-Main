const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');

(async () => {
  const root=path.resolve(__dirname,'..'), output=path.join(root,'outputs/seating-redesign-20261024');
  const browser=await chromium.launch({headless:true,channel:process.env.PLAYWRIGHT_CHANNEL||'chrome'});
  try {
    const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'}), errors=[];
    page.on('pageerror',error=>errors.push(error.message));
    await page.route('**/*',route=>{
      if(route.request().isNavigationRequest())return route.fulfill({contentType:'text/html',body:'<!doctype html><title>Rooms test</title>'});
      const match=new URL(route.request().url()).pathname.match(/\/assets\/(.+\.(?:css|png|woff2?|svg))$/);
      if(match){const file=path.join(root,'public/assets',match[1]),type={'.css':'text/css','.png':'image/png','.woff':'font/woff','.woff2':'font/woff2','.svg':'image/svg+xml'}[path.extname(file)];if(fs.existsSync(file))return route.fulfill({contentType:type,body:fs.readFileSync(file)});}
      return route.abort();
    });
    await page.goto('http://rooms.test/');
    const load=async name=>{
      const html=fs.readFileSync(path.join(output,name),'utf8').replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,'');
      await page.setContent(html);
      await page.addScriptTag({content:fs.readFileSync(path.join(root,'public/assets/js/rooms-dashboard.js'),'utf8')});
    };
    await load('sample-rooms.html');
    const visible=()=>page.locator('.rooms-directory-card:visible');
    assert.equal(await visible().count(),3);
    assert.equal(await page.locator('#rooms-available-total').innerText(),'48','Available seats included inactive or maintenance rooms');
    for(const status of ['active','inactive','maintenance']){
      await page.locator(`[data-room-filter="${status}"]`).click();
      assert.equal(await visible().count(),1);
      assert.equal(await visible().getAttribute('data-room-status'),status);
      assert.match(await visible().locator('.room-operational-status').innerText(),new RegExp(status,'i'));
      assert.equal(await page.locator(`[data-room-filter="${status}"]`).getAttribute('aria-pressed'),'true');
      assert.equal(await page.locator('#rooms-available-total').innerText(),status==='active'?'48':'0');
      assert.match(await visible().locator('.rooms-card-capacity').innerText(),new RegExp((status==='active'?'48':'0')+'\\s+available seats'));
    }
    await page.locator('[data-room-filter="all"]').click();
    await page.locator('#room-search').fill('IL-101');
    assert.equal(await visible().count(),1);
    assert.match(await page.locator('#room-results').innerText(),/Showing 1 of 3/);
    await page.locator('[data-room-filter="inactive"]').click();
    assert.equal(await visible().count(),0);
    assert.equal(await page.locator('#room-filter-empty').isVisible(),true);
    await page.locator('#room-reset-filters').click();
    assert.equal(await visible().count(),3);
    assert.equal(await page.locator('#room-search').evaluate(n=>n===document.activeElement),true);
    assert.match(await visible().first().getByRole('link',{name:/Download layout Excel/}).getAttribute('href'),/\/rooms\/\d+\/layout\.xlsx$/);
    assert.match(await visible().first().getByRole('link',{name:/Edit room/}).getAttribute('href'),/\/edit$/);
    assert.equal(await page.locator('.rooms-school-filter').getAttribute('method'),'get');
    assert.equal(await page.locator('.rooms-more[open]').count(),0);
    await visible().first().locator('.rooms-more summary').click();
    assert.equal(await visible().first().getByRole('button',{name:'Delete room'}).isVisible(),true);
    await visible().first().locator('.rooms-more summary').click();
    await page.locator('#room-search').fill('SOE');
    assert.equal(await visible().count(),1,'School-code search did not work');
    await page.locator('#room-search').fill('');
    await page.evaluate(()=>window.scrollTo(0,0));
    await page.screenshot({path:path.join(output,'rooms-dashboard-desktop.png'),fullPage:true});
    for(const width of [390,768,1024]){
      await page.setViewportSize({width,height:900});
      await page.evaluate(()=>Promise.all(document.getAnimations().map(a=>a.finished.catch(()=>{}))));
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth),true,'Room directory overflows at '+width+'px');
      if(width===390)await page.screenshot({path:path.join(output,'rooms-dashboard-mobile.png'),fullPage:true});
    }
    await load('sample-rooms-empty.html');
    assert.equal(await page.getByRole('heading',{name:'No rooms configured yet'}).isVisible(),true);
    assert.equal(await page.locator('#room-filter-empty').isVisible(),false);
    assert.deepEqual(errors,[]);
    console.log('Rooms dashboard: PASS (all statuses, combined search/filter, reset, room actions, school form, empty state, responsive layouts)');
  } finally {await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
