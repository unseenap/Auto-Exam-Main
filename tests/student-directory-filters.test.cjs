const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
class Select {
  constructor(value = '') { this.value = value; this.options = []; this.listeners = {}; }
  replaceChildren(...options) { this.options = options; this.value = ''; }
  add(option) { this.options.push(option); }
  addEventListener(type, fn) { this.listeners[type] = fn; }
  change(value) { this.value = value; this.listeners.change(); }
}
const school = new Select('1'), programme = new Select('10'), batch = new Select('100');
const selectors = {'[name="school_id"]':school, '[name="programme_id"]':programme, '[name="batch_id"]':batch};
const data = {programmes:[{id:10,schoolId:1,label:'UCS'},{id:11,schoolId:1,label:'UAI'},{id:20,schoolId:2,label:'OTHER'}],batches:[{id:100,programmeId:10,label:'UCS 2023-2027'},{id:110,programmeId:11,label:'UAI 2023-2027'}]};
vm.runInNewContext(fs.readFileSync(require('node:path').join(__dirname,'../public/assets/js/student-directory-filters.js'),'utf8'),{
  document:{getElementById:id=>id==='student-directory-filters'?{querySelector:s=>selectors[s]}:{textContent:JSON.stringify(data)}},
  Option: function(text,value){this.text=text;this.value=value;},window:{addEventListener(){}}
});
assert.equal(programme.value,'10');assert.equal(batch.value,'100');
assert.deepEqual(programme.options.map(o=>o.value),['','10','11']);
programme.change('11');assert.equal(batch.value,'');assert.deepEqual(batch.options.map(o=>o.value),['','110']);
school.change('2');assert.equal(programme.value,'');assert.equal(batch.value,'');assert.equal(batch.disabled,true);
programme.change('20');assert.equal(batch.options[0].text,'No batches available');assert.equal(batch.disabled,true);
school.change('3');assert.equal(programme.options[0].text,'No programmes available');assert.equal(programme.disabled,true);
school.change('');assert.equal(programme.options[0].text,'Select school first');assert.equal(batch.disabled,true);
console.log('Student filter interactions: PASS (restored selection, school/programme changes, incompatible resets, empty options).');
