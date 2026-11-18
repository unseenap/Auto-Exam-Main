(() => {
  'use strict';
  document.querySelectorAll('[data-duty-filter]').forEach(button=>button.addEventListener('click',()=>{
    document.querySelectorAll('[data-duty-filter]').forEach(b=>b.setAttribute('aria-pressed',String(b===button)));
    let shown=0;document.querySelectorAll('[data-duty-category]').forEach(row=>{const filter=button.dataset.dutyFilter;row.hidden=!(filter==='all'||row.dataset.dutyCategory===filter||(filter==='pending'&&row.dataset.dutyPending==='1'));if(!row.hidden)shown++;});
    const empty=document.querySelector('.fp-filter-empty');if(empty)empty.hidden=shown>0;
  }));
  const root=document.getElementById('fp-room');if(!root)return;
  let revision=Number(root.dataset.revision),editable=root.dataset.editable==='1',working=false,conflict=false;
  const records=new Map(JSON.parse(document.getElementById('fp-initial-records').textContent).map(r=>[String(r.id),r]));
  const queue=[],failed=[],base=root.dataset.url,token=document.getElementById('fp-token').value;
  const saveStatus=document.getElementById('fp-save-status'),errorBox=document.getElementById('fp-save-error'),search=document.getElementById('fp-search'),filter=document.getElementById('fp-status-filter');
  const card=id=>document.getElementById('fp-student-'+id);
  const fieldKey=input=>input.dataset.ufmSerial||'remarks';
  const fields='[data-remarks], [data-ufm-serial]';
  const clean=()=>{
    const fieldsSaved=[...root.querySelectorAll(fields)].every(input=>
      input.value===(records.get(input.closest('[data-record]').dataset.record)[fieldKey(input)]||''));
    const statusesSaved=[...root.querySelectorAll('[data-record]')].every(node=>{
      const status=records.get(node.dataset.record).status;
      const expected=['unfair_means','withheld','other'].includes(status)?status:'unmarked';
      return node.querySelector('[data-exception]').value===expected;
    });
    return !working&&!queue.length&&!failed.length&&fieldsSaved&&statusesSaved;
  };
  const showUfmFields=node=>{node.querySelector('[data-ufm-fields]').hidden=node.querySelector('[data-exception]').value!=='unfair_means';};
  const syncFields=(node,r)=>{
    node.querySelectorAll(fields).forEach(input=>input.value=r[fieldKey(input)]||'');
    node.querySelector('[data-exception]').value=['unfair_means','withheld','other'].includes(r.status)?r.status:'unmarked';
    showUfmFields(node);
  };
  const setRevision=value=>{revision=Number(value);root.dataset.revision=String(revision);root.querySelectorAll('input[name="revision"]').forEach(n=>n.value=String(revision));};
  const controls=()=>{
    root.querySelectorAll('.fp-mark-controls').forEach(n=>n.disabled=!editable||conflict);
    document.querySelector('#fp-submit-form button').disabled=!editable||conflict||!clean();
  };
  const showError=(message,isConflict=false)=>{conflict=isConflict;errorBox.hidden=false;errorBox.querySelector('span').textContent=message;document.getElementById('fp-retry').hidden=isConflict;controls();};
  const matches=r=>{
    const term=search.value.toLowerCase().trim(),wanted=filter.value;
    return (!term||card(r.id).dataset.search.includes(term))&&(!wanted||r.status===wanted||(wanted==='exceptions'&&!['unmarked','present','absent'].includes(r.status)));
  };
  const applyFilters=()=>{
    let shown=0;for(const r of records.values()){const visible=matches(r);card(r.id).hidden=!visible;if(visible)shown++;const seat=root.querySelector(`[data-seat-record="${r.id}"]`);if(seat)seat.style.opacity=visible?'1':'.3';}
    document.getElementById('fp-student-empty').hidden=shown>0;
  };
  const render=()=>{
    const counts={present:0,absent:0,unmarked:0,exceptions:0};const review=document.getElementById('fp-review-list');review.replaceChildren();
    for(const r of records.values()){
      const node=card(r.id);node.dataset.status=r.status;node.querySelector('[data-status-label]').textContent=r.status.replaceAll('_',' ');
      node.querySelector('[data-marked-by]').textContent=r.marked_at?(r.marked_name||'Invigilator')+' · '+r.marked_at:'Not marked';
      node.querySelectorAll('[data-mark]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.mark===r.status)));
      const seat=root.querySelector(`[data-seat-status="${r.id}"]`);if(seat)seat.textContent=r.status.replaceAll('_',' ');
      if(Object.hasOwn(counts,r.status))counts[r.status]++;else counts.exceptions++;
      if(r.status!=='present'){const li=document.createElement('li');li.textContent=r.roll_no_original+' · '+r.seat_label+' · '+r.status.replaceAll('_',' ');review.append(li);}
    }
    for(const [key,value] of Object.entries(counts))document.getElementById('fp-count-'+key).textContent=String(value);
    if(!review.children.length){const li=document.createElement('li');li.textContent='All allocated students are marked Present.';review.append(li);}
    applyFilters();controls();
  };
  let deadlineTimer,countdownTimer;
  const scheduleLock=seconds=>{
    clearTimeout(deadlineTimer);
    clearInterval(countdownTimer);
    const countdown=document.getElementById('fp-lock-countdown');
    if(!editable){
      if(countdown)countdown.textContent='Attendance entry is closed';
      return;
    }
    if(!Number.isFinite(Number(seconds)))return;
    const deadline=performance.now()+Math.max(0,Number(seconds)*1000);
    const updateCountdown=()=>{
      if(!countdown)return;
      const remaining=Math.max(0,Math.ceil((deadline-performance.now())/1000));
      const hours=Math.floor(remaining/3600),minutes=Math.floor(remaining%3600/60),seconds=remaining%60;
      countdown.textContent='Automatic lock in '+[hours,minutes,seconds].map(value=>String(value).padStart(2,'0')).join(':');
    };
    updateCountdown();
    countdownTimer=setInterval(updateCountdown,1000);
    deadlineTimer=setTimeout(()=>{
      clearInterval(countdownTimer);
      if(countdown)countdown.textContent='Attendance deadline reached';
      editable=false;
      document.getElementById('fp-submission-status').textContent='Time locked';
      const correction=root.querySelector('[data-request-correction]');if(correction)correction.disabled=false;
      document.getElementById('fp-window-note').textContent='The attendance deadline has passed. Saved attendance is locked. Request coordinator approval for corrections.';
      controls();
      if(!clean())showError('The deadline has passed. Unsaved changes need a coordinator-approved correction.');
      else snapshot().catch(error=>showError(error.message,true));
    },Math.min(2147483647,Math.max(0,Number(seconds)*1000)));
  };
  const snapshot=async(discard=false)=>{
    if(!discard&&!clean())return;
    const response=await fetch(base+'/snapshot',{headers:{Accept:'application/json'},cache:'no-store'});
    const data=await response.json();if(!response.ok)throw Error(data.error||'Attendance could not be refreshed.');
    if(Number(data.revision)<revision)return;
    // A save may have started while this snapshot was in flight.
    if(!discard&&!clean())return;
    if(discard){queue.length=0;failed.length=0;conflict=false;errorBox.hidden=true;}
    setRevision(data.revision);
    for(const r of data.records){records.set(String(r.id),r);const node=card(r.id);if(node)syncFields(node,r);}
    editable=data.state.status!=='submitted'&&data.window.allowed&&root.dataset.dutyCompleted!=='1';
    document.getElementById('fp-submission-status').textContent=data.state.status==='submitted'?(data.state.lock_reason==='automatic'?'Automatically locked':'Teacher locked'):(data.revision?'In progress':'Not started');
    saveStatus.textContent=data.state.edited_at?'Last saved '+data.state.edited_at+' by '+data.state.editor_name:'No attendance changes yet';
    if(data.state.status==='submitted')document.getElementById('fp-window-note').textContent=
      (data.state.lock_reason==='automatic'?'Attendance automatically locked at the deadline on ':'Attendance locked by '+data.state.submitter_name+' on ')+data.state.submitted_at+'. Request coordinator approval for corrections. Reload to review the closing report.';
    const correction=root.querySelector('[data-request-correction]');if(correction)correction.disabled=data.state.status!=='submitted';
    scheduleLock(data.window.remaining_seconds);
    render();
  };
  const process=async()=>{
    if(working||conflict||failed.length)return;working=true;controls();
    while(queue.length&&!conflict){
      const item=queue.shift();saveStatus.textContent='Saving '+records.get(item.id).roll_no_original+'…';
      try{
        const body=new URLSearchParams({_token:token,record_id:item.id,status:item.status,remarks:item.remarks,revision:String(revision)});
        Object.entries(item.serials).forEach(([key,value])=>body.set('ufm['+key+']',value));
        const response=await fetch(base+'/mark',{method:'POST',headers:{Accept:'application/json'},body});let data;try{data=await response.json();}catch{throw Error('The server did not confirm this save. Your change is still pending.');}
        if(!response.ok){const e=Error(data.error||'Save failed.');e.conflict=response.status===409||response.status===403;throw e;}
        setRevision(data.revision);const r=records.get(item.id);r.status=item.status;r.remarks=item.remarks;r.marked_at=data.saved_at;r.marked_name='You';
        for(const key of ['first_copy_serial','second_copy_serial'])r[key]=item.serials[key]||'';
        const node=card(item.id);
        if([...node.querySelectorAll(fields)].every(input=>input.value===item.original[fieldKey(input)])&&node.querySelector('[data-exception]').value===item.selection)syncFields(node,r);
        saveStatus.textContent='Saved at '+data.saved_at;render();
      }catch(error){failed.push(item,...queue.splice(0));saveStatus.textContent='Changes not saved';showError(error.message,!!error.conflict);break;}
    }
    working=false;controls();
  };
  const mark=(node,status,quick=false)=>{
    if(!editable||conflict)return;
    const id=node.dataset.record;
    const original=Object.fromEntries([...node.querySelectorAll(fields)].map(input=>[fieldKey(input),input.value]));
    const selection=node.querySelector('[data-exception]').value;
    const remarks=quick&&records.get(id).status==='unfair_means'?'':original.remarks.trim();
    if(['unfair_means','withheld','other'].includes(status)&&!remarks.trim()){showError('Enter remarks explaining this exceptional attendance status.');return;}
    const serials=status==='unfair_means'?{first_copy_serial:original.first_copy_serial.trim(),second_copy_serial:original.second_copy_serial.trim()}:{};
    queue.push({id,status,remarks,serials,original,selection});errorBox.hidden=true;process();
  };
  root.querySelectorAll('[data-record]').forEach(node=>{
    const exception=node.querySelector('[data-exception]');
    exception.addEventListener('change',()=>{showUfmFields(node);controls();});
    node.querySelectorAll(fields).forEach(input=>input.addEventListener('input',controls));
    node.querySelectorAll('[data-mark]').forEach(button=>button.addEventListener('click',()=>mark(node,button.dataset.mark,true)));
    node.querySelector('[data-save-exception]').addEventListener('click',()=>mark(node,exception.value));
  });
  document.getElementById('fp-retry').addEventListener('click',()=>{if(conflict)return;queue.unshift(...failed.splice(0));errorBox.hidden=true;process();});
  document.getElementById('fp-reload').addEventListener('click',async()=>{
    if(working)return;
    if(!clean()&&!confirm('Discard unsaved changes and load the latest attendance?'))return;
    try{await snapshot(true);}catch(e){showError(e.message,true);}
  });
  search.addEventListener('input',applyFilters);filter.addEventListener('change',applyFilters);
  const view=name=>{document.getElementById('fp-layout').hidden=name!=='layout';document.getElementById('fp-records').hidden=name!=='list';root.querySelectorAll('[data-room-view]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.roomView===name)));};
  root.querySelectorAll('[data-room-view]').forEach(b=>b.addEventListener('click',()=>view(b.dataset.roomView)));
  root.querySelectorAll('[data-seat-record]').forEach(b=>b.addEventListener('click',()=>{search.value='';filter.value='';applyFilters();view('list');card(b.dataset.seatRecord).scrollIntoView({block:'center',behavior:'auto'});card(b.dataset.seatRecord).focus({preventScroll:true});}));
  document.getElementById('fp-submit-form').addEventListener('submit',event=>{
    if(!clean()){event.preventDefault();showError('Finish saving or resolve pending changes before submitting.');return;}
    const missing=[...records.values()].filter(r=>r.status==='unmarked');
    if(missing.length){event.preventDefault();showError(missing.length+' students remain unmarked: '+missing.map(r=>r.roll_no_original+' at '+r.seat_label).join('; ')+'. Mark them before submitting.');return;}
    if(!confirm('Submit and lock attendance for this room? Further changes require coordinator approval.'))event.preventDefault();
  });
  let printFilters=null;
  root.querySelectorAll('[data-print]').forEach(b=>b.addEventListener('click',()=>{
    printFilters={search:search.value,filter:filter.value};search.value='';filter.value='';applyFilters();view('list');
    root.dataset.printMode=b.dataset.print;window.print();
  }));
  addEventListener('afterprint',()=>{delete root.dataset.printMode;if(printFilters){search.value=printFilters.search;filter.value=printFilters.filter;applyFilters();printFilters=null;}});
  addEventListener('beforeunload',event=>{if(!clean()){event.preventDefault();event.returnValue='';}});
  setInterval(()=>snapshot().catch(e=>{if(clean())saveStatus.textContent='Live refresh unavailable: '+e.message;}),15000);
  addEventListener('online',()=>{if(failed.length&&!conflict)saveStatus.textContent='Connection restored. Use Retry save to send pending changes.';});
  render();
  if(root.hasAttribute('data-lock-seconds'))scheduleLock(root.dataset.lockSeconds);
})();
