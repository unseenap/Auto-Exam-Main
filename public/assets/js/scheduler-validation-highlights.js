(() => {
  'use strict';
  const root=document.querySelector('.automatic-planner'),form=document.getElementById('scheduler-form');
  if(!root||!form)return;
  const live=document.getElementById('live-validation'),saved=document.getElementById('saved-validation');
  const originals=new Map(),hosts=new Set();
  const section=id=>document.getElementById(id)?.closest('.scheduler-section');
  const branchGroup=()=>document.getElementById('scheduler-programmes')?.closest('fieldset');
  const input=(name,id)=>[...form.querySelectorAll(`[name="${name}[]"]`)].find(n=>n.value===String(id));
  const host=node=>node?.matches('input[name="programme_ids[]"]')?node.closest('[data-programme-card]'):node?.matches('input,select')?node.closest('label'):node;
  const clear=()=>{
    for(const node of hosts){node.classList.remove('scheduler-selection-issue');delete node.dataset.validationSeverity;delete node.dataset.validationLabel;}
    hosts.clear();
    for(const [node,attrs] of originals)for(const [name,value] of Object.entries(attrs))value===null?node.removeAttribute(name):node.setAttribute(name,value);
    originals.clear();
    root.querySelectorAll('.scheduler-show-selection').forEach(node=>node.remove());
  };
  const targets=check=>{
    const details=check.details||{},result=[];
    for(const [field,name] of [['programme_ids','programme_ids'],['batch_ids','batch_ids'],['programme_course_ids','programme_course_ids']])for(const id of details[field]||[]){const node=input(name,id);if(node)result.push(node);}
    if(check.code==='scope.programmes')result.push(document.getElementById('scheduler-school'));
    if(result.length)return [...new Set(result.filter(Boolean))];
    if(check.code==='cycle.academic_session')return [document.getElementById('scheduler-cycle-session')].filter(Boolean);
    if(check.code.startsWith('scope.'))return [branchGroup()].filter(Boolean);
    if(check.code.startsWith('curriculum.')||check.code==='priority.invalid'||check.code==='courses.inactive'||check.code==='registration.required')return [section('subjects-heading')].filter(Boolean);
    if(check.code.startsWith('calendar.')||check.code==='slots.capacity')return [document.getElementById('scheduler-calendar-link')].filter(Boolean);
    if(check.code==='gap.window')return [form.querySelector('[name="minimum_gap_days"]')].filter(Boolean);
    return [];
  };
  const visible=node=>node&&node.getClientRects().length&&!node.closest('[hidden]');
  const jump=nodes=>{
    if(nodes.some(node=>node.matches?.('input[name="programme_course_ids[]"]'))){
      for(const id of ['subject-branch-filter','subject-batch-filter']){const filter=document.getElementById(id);if(filter){filter.value='';filter.dispatchEvent(new Event('change'));}}
    }
    const node=nodes.find(item=>visible(host(item))&&!item.disabled)||branchGroup()||form;
    const target=host(node)||node;
    target.scrollIntoView({behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth',block:'center'});
    const control=node.matches?.('input,select,a,button')&&!node.disabled?node:target;
    if(!control.matches('input,select,a,button')&&!control.hasAttribute('tabindex'))control.setAttribute('tabindex','-1');
    control.focus({preventScroll:true});
  };
  const mark=(node,state,messageId)=>{
    const box=host(node);if(!box)return;
    box.classList.add('scheduler-selection-issue');hosts.add(box);
    if(box.dataset.validationSeverity!=='blocked')box.dataset.validationSeverity=state;
    box.dataset.validationLabel=box.dataset.validationSeverity==='blocked'?'Needs attention — blocked':'Review warning';
    if(node.matches('input,select')){
      if(!originals.has(node))originals.set(node,{'aria-invalid':node.getAttribute('aria-invalid'),'aria-describedby':node.getAttribute('aria-describedby')});
      if(state==='blocked')node.setAttribute('aria-invalid','true');
      const ids=new Set((node.getAttribute('aria-describedby')||'').split(/\s+/).filter(Boolean));ids.add(messageId);node.setAttribute('aria-describedby',[...ids].join(' '));
    }
  };
  const apply=()=>{
    clear();
    const container=!live.hidden?live:!saved.hidden?saved:null;if(!container)return;
    const checks=container.querySelectorAll('.validation-check[data-validation-code]');
    checks.forEach((article,index)=>{
      const state=article.classList.contains('blocked')?'blocked':article.classList.contains('warning')?'warning':null;if(!state)return;
      let details={};try{details=JSON.parse(article.dataset.validationDetails||'{}');}catch{}
      const nodes=targets({code:article.dataset.validationCode,details});if(!nodes.length)return;
      const message=article.querySelector('p');if(!message)return;message.id=container.id+'-selection-message-'+index;
      nodes.forEach(node=>mark(node,state,message.id));
      const button=document.createElement('button');button.type='button';button.className='scheduler-show-selection';button.textContent='Show selection →';button.setAttribute('aria-describedby',message.id);button.addEventListener('click',()=>jump(nodes));article.querySelector('div')?.append(button);
    });
    if(!checks.length&&container===live&&container.querySelector('.validation-empty p')){
      let missing=null;
      if(!form.querySelector('#scheduler-school').value)missing=form.querySelector('#scheduler-school');
      else if(!form.querySelector('[name="programme_ids[]"]:checked'))missing=branchGroup();
      else if(!form.querySelector('[name="semesters[]"]:checked'))missing=form.querySelector('[name="semesters[]"]')?.closest('fieldset');
      else if(!form.querySelector('[name="programme_course_ids[]"]:checked:not(:disabled)'))missing=section('subjects-heading');
      if(missing){const message=container.querySelector('.validation-empty p');message.id='scheduler-missing-selection';mark(missing,'blocked',message.id);const button=document.createElement('button');button.type='button';button.className='scheduler-show-selection';button.textContent='Show selection →';button.addEventListener('click',()=>jump([missing]));message.parentElement.append(button);}
    }
  };
  let pending=false;
  const observer=new MutationObserver(records=>{
    const meaningful=records.some(record=>record.type==='attributes'||[...record.addedNodes,...record.removedNodes].some(node=>!(node.nodeType===1&&node.classList.contains('scheduler-show-selection'))));
    if(meaningful&&!pending){pending=true;queueMicrotask(()=>{pending=false;apply();});}
  });
  for(const container of [live,saved])observer.observe(container,{childList:true,subtree:true,attributes:true,attributeFilter:['hidden']});
  form.addEventListener('change',event=>{if(!event.target.matches('#subject-branch-filter,#subject-batch-filter'))clear();});
  apply();
})();
