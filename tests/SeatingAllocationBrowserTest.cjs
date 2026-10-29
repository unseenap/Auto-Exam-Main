const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');

(async () => {
  const root = path.resolve(__dirname, '..');
  const output = path.join(root, 'outputs/seating-redesign-20261024');
  const browser = await chromium.launch({headless:true, channel:process.env.PLAYWRIGHT_CHANNEL || 'chrome'});
  try {
    const page = await browser.newPage({viewport:{width:1440, height:1000}, reducedMotion:'reduce'});
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.route('**/*', route => {
      if (route.request().isNavigationRequest()) return route.fulfill({contentType:'text/html', body:'<!doctype html><title>Seating workspace test</title>'});
      const match = new URL(route.request().url()).pathname.match(/\/assets\/(.+\.(?:css|png|woff2?|svg))$/);
      if (match) {
        const file = path.join(root, 'public/assets', match[1]);
        const type = {'.css':'text/css','.png':'image/png','.woff':'font/woff','.woff2':'font/woff2','.svg':'image/svg+xml'}[path.extname(file)];
        if (fs.existsSync(file)) return route.fulfill({contentType:type, body:fs.readFileSync(file)});
      }
      return route.abort();
    });
    await page.goto('http://seating.test/');
    const html = fs.readFileSync(path.join(output, 'sample-preview.html'), 'utf8').replace(/<script\b[^>]*\bsrc=[^>]*><\/script>/gi, '');
    await page.setContent(html);
    await page.addScriptTag({content:fs.readFileSync(path.join(root, 'public/assets/js/seating-allocation.js'), 'utf8')});
    const rooms = page.locator('[data-allocation-room]');
    const count = await rooms.count();
    assert.ok(count > 1, 'Fixture needs multiple rooms');
    assert.equal(await page.locator('[data-allocation-room]:visible').count(), 1);
    assert.equal(await page.locator('#allocation-room-prev').isDisabled(), true);
    await page.locator('#allocation-room-next').click();
    assert.equal(await page.locator('#allocation-room-select').inputValue(), '1');
    assert.equal(await page.locator('[data-allocation-room="0"]').isVisible(), false);
    await page.locator('#allocation-room-select').selectOption('all');
    assert.equal(await page.locator('[data-allocation-room]:visible').count(), count);
    await page.locator('#allocation-room-select').selectOption('0');
    await page.emulateMedia({media:'print'});
    assert.equal(await page.locator('[data-allocation-room]:visible').count(), count, 'Room filtering hid sheets from print');
    assert.equal(await page.locator('.allocation-dashboard-heading').isVisible(), false);
    assert.equal(await page.locator('#allocation-tools').isVisible(), false);
    await page.emulateMedia({media:'screen'});
    assert.equal(await page.locator('[data-allocation-room]:visible').count(), 1);
    const move = page.locator('#move-student');
    if (await move.count()) {
      assert.equal(await move.getAttribute('open'), null);
      await move.locator('summary').click();
      const student = move.locator('select[name="assignment_id"]');
      const first = await student.locator('option[value]:not([value=""])').first().getAttribute('value');
      await student.selectOption(first);
      assert.equal(await move.locator('select[name="seat_id"] option').evaluateAll(options => {
        const selected = document.querySelector('select[name="assignment_id"]').selectedOptions[0];
        return options.every(option => !option.value || option.disabled || (option.dataset.school === selected.dataset.school && (!option.dataset.group || option.dataset.group === selected.dataset.group)));
      }), true, 'Manual correction offered an incompatible seat');
      await move.locator('summary').click();
    }
    assert.equal(await page.locator('.allocation-more').getAttribute('open'), null, 'Destructive action should be tucked away');
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({path:path.join(output, 'allocation-dashboard-desktop.png'), fullPage:true});
    for (const width of [390, 768, 1024]) {
      await page.setViewportSize({width, height:900});
      await page.evaluate(() => Promise.all(document.getAnimations().map(a => a.finished.catch(() => {}))));
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true, 'Workspace overflows at '+width+'px');
      if (width === 390) await page.screenshot({path:path.join(output, 'allocation-dashboard-mobile.png'), fullPage:true});
    }
    assert.deepEqual(errors, []);
    console.log('Seating allocation workspace: PASS (room browsing, all-room print, correction restrictions, grouped tools, mobile/tablet layouts)');
  } finally { await browser.close(); }
})().catch(error => {console.error(error);process.exitCode=1;});
