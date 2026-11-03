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
  const clean=()=>!working&&!queue.length&&!failed.length&&[...root.querySelectorAll('[data-remarks]')].every(n=>n.value===(records.get(n.closest('[data-record]').dataset.record).remarks||''));
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
  const snapshot=async(discard=false)=>{
    if(!discard&&!clean())return;
    const response=await fetch(base+'/snapshot',{headers:{Accept:'application/json'},cache:'no-store'});
    const data=await response.json();if(!response.ok)throw Error(data.error||'Attendance could not be refreshed.');
    if(Number(data.revision)<revision)return;
    // A save may have started while this snapshot was in flight.
    if(!discard&&!clean())return;
    if(discard){queue.length=0;failed.length=0;conflict=false;errorBox.hidden=true;}
    setRevision(data.revision);
    for(const r of data.records){records.set(String(r.id),r);const node=card(r.id);if(node){node.querySelector('[data-remarks]').value=r.remarks||'';if(['unmarked','unfair_means','withheld','other'].includes(r.status))node.querySelector('[data-exception]').value=r.status;}}
    editable=data.state.status!=='submitted'&&data.window.allowed&&root.dataset.dutyCompleted!=='1';
    document.getElementById('fp-submission-status').textContent=data.state.status==='submitted'?'Submitted · locked':(data.revision?'In progress':'Not started');
    saveStatus.textContent=data.state.edited_at?'Last saved '+data.state.edited_at+' by '+data.state.editor_name:'No attendance changes yet';
    if(data.state.status==='submitted')document.getElementById('fp-window-note').textContent='Attendance submitted by '+data.state.submitter_name+' at '+data.state.submitted_at+'. Reload the page to open its closing report.';
    render();
  };
  const process=async()=>{
    if(working||conflict||failed.length)return;working=true;controls();
    while(queue.length&&!conflict){
      const item=queue.shift();saveStatus.textContent='Saving '+records.get(item.id).roll_no_original+'…';
      try{
        const body=new URLSearchParams({_token:token,record_id:item.id,status:item.status,remarks:item.remarks,revision:String(revision)});
        const response=await fetch(base+'/mark',{method:'POST',headers:{Accept:'application/json'},body});let data;try{data=await response.json();}catch{throw Error('The server did not confirm this save. Your change is still pending.');}
        if(!response.ok){const e=Error(data.error||'Save failed.');e.conflict=response.status===409||response.status===403;throw e;}
        setRevision(data.revision);const r=records.get(item.id);r.status=item.status;r.remarks=item.remarks;r.marked_at=data.saved_at;r.marked_name='You';
        saveStatus.textContent='Saved at '+data.saved_at;render();
      }catch(error){failed.push(item,...queue.splice(0));saveStatus.textContent='Changes not saved';showError(error.message,!!error.conflict);break;}
    }
    working=false;controls();
  };
  const mark=(id,status,remarks='')=>{
    if(!editable||conflict)return;
    if(['unfair_means','withheld','other'].includes(status)&&!remarks.trim()){showError('Enter remarks explaining this exceptional attendance status.');return;}
    queue.push({id:String(id),status,remarks});errorBox.hidden=true;process();
  };
  root.querySelectorAll('[data-record]').forEach(node=>{
    node.querySelectorAll('[data-mark]').forEach(button=>button.addEventListener('click',()=>mark(node.dataset.record,button.dataset.mark,node.querySelector('[data-remarks]').value)));
    node.querySelector('[data-save-exception]').addEventListener('click',()=>mark(node.dataset.record,node.querySelector('[data-exception]').value,node.querySelector('[data-remarks]').value));
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
})();
