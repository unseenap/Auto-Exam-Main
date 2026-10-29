const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({headless:true,channel:process.env.PLAYWRIGHT_CHANNEL || 'chrome'});
  try {
    const page = await browser.newPage({viewport:{width:1280,height:900}});
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    const root = path.resolve(__dirname,'..');
    // Rendered by PairedSeatingTest using its isolated, synthetic database.
    const html = fs.readFileSync(path.join(root,'outputs/seating-redesign-20261024/sample-generator.html'),'utf8');
    await page.route('**/*',route=>{
      const url=new URL(route.request().url());
      if(route.request().isNavigationRequest())return route.fulfill({status:200,contentType:'text/html',body:'<!doctype html><title>Seating test</title>'});
      const asset=url.pathname.match(/\/assets\/(.+\.(?:css|woff2?|png|svg))$/);
      if(asset){const file=path.join(root,'public/assets',asset[1]),type={'.css':'text/css','.woff':'font/woff','.woff2':'font/woff2','.png':'image/png','.svg':'image/svg+xml'}[path.extname(file)];if(fs.existsSync(file))return route.fulfill({contentType:type,body:fs.readFileSync(file)});}
      return route.abort();
    });
    await page.goto('http://seating.test/');
    await page.setContent(html.replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,''));
    await page.addScriptTag({content:fs.readFileSync(path.join(root,'public/assets/js/seating-pairings.js'),'utf8')});
    const session=page.locator('#session-select');
    const values=await session.locator('option').evaluateAll(options=>options.map(o=>o.value).filter(Boolean));
    await session.selectOption(values[0]);
    assert.equal(await page.locator('.pairing-card').count(),0,'Same-branch-only session offered a pair');
    assert.equal(await page.locator('#suggest-pairings').isDisabled(),true);
    assert.equal(await page.locator('#seat-remaining').inputValue(),'2','No-pair fallback was not the default');
    assert.equal(await page.locator('#generate-button').isDisabled(),false,'No-pair session could not generate spaced seating');
    assert.match(await page.locator('#pairing-summary').innerText(),/^48 of 70/);
    assert.equal(await page.locator('#preview-empty-columns').innerText(),'8');
    await page.locator('#seat-remaining').selectOption('0');
    assert.equal(await page.locator('#generate-button').isDisabled(),true,'Review-only mode generated without pairs');
    await page.locator('#seat-remaining').selectOption('2');
    await session.selectOption(values[1]);
    assert.equal(await page.locator('#pairing-pattern').count(),0,'Obsolete year restriction is still visible');
    assert.equal(await page.locator('#suggest-pairings').isDisabled(),false);
    // Bulk suggestions remain reviewable and can be undone without losing manual work.
    await page.locator('#suggest-pairings').click();
    assert.equal(await page.locator('.pairing-card').count(),1);
    assert.equal(await page.locator('#pairing-count').innerText(),'1 pair ready');
    assert.equal(await page.locator('.pairing-room-settings[open]').count(),0);
    await page.locator('#undo-pairings').click();
    assert.equal(await page.locator('.pairing-card').count(),1);
    assert.equal(await page.locator('select[name="pairings[0][left]"]').inputValue(),'');
    await page.locator('#pairing-search').fill('no matching group');
    assert.equal(await page.locator('select[name="pairings[0][left]"] option').count(),1);
    await page.locator('#pairing-search').fill('');
    await page.locator('select[name="pairings[0][left]"]').selectOption('1:1:1');
    await page.locator('select[name="pairings[0][right]"]').focus();
    await page.locator('select[name="pairings[0][right]"]').selectOption('2:3:5');
    assert.equal(await page.locator('select[name="pairings[0][right]"]').evaluate(n=>n===document.activeElement),true,'Selection lost keyboard focus');
    assert.equal(await page.locator('#suggest-pairings').isDisabled(),true,'Suggested another same-branch pair');
    assert.equal(await page.locator('select[name="pairings[0][right]"] option[value="1:2:5"]').evaluate(n=>n.disabled),true,'Same branch across years was selectable');
    await page.locator('#seat-remaining').selectOption('1');
    assert.match(await page.locator('#pairing-summary').innerText(),/^10 of 76/);
    assert.equal(await page.locator('#generate-button').isDisabled(),false);
    // Preferred room order still works with the branch-separation rule.
    await page.locator('.pairing-card').nth(0).locator('.pairing-room-settings summary').click();
    await page.locator('.pairing-card').nth(0).locator('input[type="checkbox"]').first().check();
    await page.locator('.pairing-card').nth(0).locator('input[type="checkbox"]').nth(1).check();
    const before=await page.locator('input[name="pairings[0][room_ids][]"]').evaluateAll(nodes=>nodes.map(n=>n.value));
    await page.getByRole('button',{name:'Raise IL-102 priority for pairing 1',exact:true}).click();
    const after=await page.locator('input[name="pairings[0][room_ids][]"]').evaluateAll(nodes=>nodes.map(n=>n.value));
    assert.deepEqual(after,[...before].reverse());
    assert.equal(await page.locator('#preview-assigned').innerText(),'10');
    assert.equal(await page.locator('#preview-unallocated').innerText(),'66');
    assert.equal(await page.locator('#shortage-details').isVisible(),true);
    await page.locator('.pairing-card').nth(0).locator('.pairing-room-settings summary').click();
    await page.evaluate(()=>window.scrollTo(0,0));
    await page.screenshot({path:path.join(root,'outputs/seating-redesign-20261024/automatic-pairing-desktop.png'),fullPage:true});
    await page.setViewportSize({width:390,height:844});
    await page.evaluate(()=>Promise.all(document.getAnimations().map(animation=>animation.finished.catch(()=>{}))));
    await page.screenshot({path:path.join(root,'outputs/seating-redesign-20261024/automatic-pairing-mobile.png'),fullPage:true});
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth),true,'Pairing editor overflows mobile viewport: '+JSON.stringify(await page.locator('#paired-seating-form *').evaluateAll(nodes=>nodes.filter(n=>n.getBoundingClientRect().right>window.innerWidth).map(n=>({tag:n.tagName,cls:n.className,width:n.getBoundingClientRect().width})).slice(0,12))));
    for(const width of [768,1024]){
      await page.setViewportSize({width,height:900});
      await page.evaluate(()=>Promise.all(document.getAnimations().map(animation=>animation.finished.catch(()=>{}))));
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth),true,'Overflow at '+width+'px');
    }
    // Restore a same-branch selection saved by an older page, then initialise fresh JS.
    await page.setContent(html.replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi,''));
    await page.evaluate(sessionValue=>{
      const element=document.getElementById('paired-seating-data'),data=JSON.parse(element.textContent);
      data.old={session:sessionValue,pairings:[{left:'1:1:1',right:'1:2:5',room_ids:[]}],alternate_unmatched:true};
      element.textContent=JSON.stringify(data);document.getElementById('session-select').value=sessionValue;document.getElementById('seat-remaining').value='2';
    },values[0]);
    await page.addScriptTag({content:fs.readFileSync(path.join(root,'public/assets/js/seating-pairings.js'),'utf8')});
    assert.equal(await page.locator('.pairing-card').count(),0,'Restored same-branch pairing remained in the form');
    assert.equal(await page.locator('#generate-button').isDisabled(),false,'Restored same-branch pairing blocked fallback');
    assert.match(await page.locator('#pairing-status').innerText(),/alternating columns/);
    assert.deepEqual(errors,[]);
    console.log('Pairing browser: PASS (selectors, remaining counts, both choices, shared rooms, room and pair priority controls, mobile rendering, no JS errors)');
  } finally { await browser.close(); }
})().catch(error=>{console.error(error);process.exitCode=1;});
