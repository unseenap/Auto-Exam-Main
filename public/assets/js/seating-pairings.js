(() => {
'use strict';
const branch=g=>String(g.programme_id??g.programme_code??g.key);
const papers=g=>g.paper_ids||[];
const compatible=(a,b)=>a.key!==b.key&&a.school_id===b.school_id&&branch(a)!==branch(b)&&!papers(a).some(p=>papers(b).includes(p));
const reservePairs=(groups,pairs)=>{
 const remaining=Object.fromEntries(groups.map(g=>[g.key,Number(g.count)]));
 const steps=pairs.map(p=>{
  const before={...remaining},a=groups.find(g=>g.key===p.left),b=groups.find(g=>g.key===p.right);
  const valid=!!a&&!!b&&compatible(a,b);
  const count=valid?Math.min(remaining[a.key],remaining[b.key]):0;
  if(count){remaining[a.key]-=count;remaining[b.key]-=count;}
  return {before,count,valid:valid&&count>0};
 });
 return {steps,remaining};
};
const previewAllocation=(groups,rooms,seats,pairs,solo,alternate=false)=>{
 const reservation=reservePairs(groups,pairs),used=new Set(),roomUsed=new Set(),slots={},neighbours={},occupied={},roomAssigned={};
 const missing=Object.fromEntries(groups.map(g=>[g.key,Number(g.count)]));
 const key=(id,s)=>[id,s[0],s[1]].join(':');
 const connect=(a,b)=>{(neighbours[a]??=new Set()).add(b);(neighbours[b]??=new Set()).add(a);};
 for(const r of rooms){
  const pool=seats[r.id]||[],cols=[...new Set(pool.map(s=>s[1]))].sort((a,b)=>a-b);slots[r.id]=[];
  for(let i=0;i+1<cols.length;i+=2)for(const a of pool.filter(s=>s[1]===cols[i]).sort((a,b)=>a[0]-b[0])){
   const b=pool.find(s=>s[1]===cols[i+1]&&s[0]===a[0]);if(b){slots[r.id].push([a,b]);connect(key(r.id,a),key(r.id,b));}
  }
  const total=Number(r.columns_count)||Math.max(0,...cols),aisle=Math.min(total-1,Math.max(1,2*Math.ceil(total/4))),positions=new Set(pool.map(s=>key(r.id,s)));
  for(const s of pool)if(s[1]!==aisle){const other=key(r.id,[s[0],s[1]+1]);if(positions.has(other))connect(key(r.id,s),other);}
 }
 const safe=(g,id,s)=>[...(neighbours[key(id,s)]||[])].every(n=>!occupied[n]||compatible(groups.find(x=>x.key===g),occupied[n]));
 const place=(g,id,s)=>{used.add(key(id,s));occupied[key(id,s)]=groups.find(x=>x.key===g);roomUsed.add(Number(id));roomAssigned[id]=(roomAssigned[id]||0)+1;missing[g]--;};
 pairs.forEach((p,i)=>{
  const step=reservation.steps[i];if(!step.valid)return;
  const school=groups.find(g=>g.key===p.left).school_id,available=rooms.filter(r=>Number(r.school_id)===Number(school));
  const first=p.rooms.map(id=>available.find(r=>Number(r.id)===id)).filter(Boolean);
  const order=[...first,...available.filter(r=>!p.rooms.includes(Number(r.id)))];let n=0;
  for(const r of order)for(let [a,b] of slots[r.id]){
   if(n===step.count)break;if(used.has(key(r.id,a))||used.has(key(r.id,b)))continue;
   if(!safe(p.left,r.id,a)||!safe(p.right,r.id,b)){if(!safe(p.left,r.id,b)||!safe(p.right,r.id,a))continue;[a,b]=[b,a];}
   place(p.left,r.id,a);place(p.right,r.id,b);n++;
  }
 });
 const emptyPartnerColumns={};
 if(alternate){
  const fallback={};
  for(const r of rooms){
   const pool=seats[r.id]||[],cols=[...new Set(pool.map(s=>s[1]))].sort((a,b)=>a-b),occupiedColumns=new Set(pool.filter(s=>used.has(key(r.id,s))).map(s=>s[1]));fallback[r.id]=[];
   for(let i=0;i<cols.length;i+=2){const target=cols[i],partner=cols[i+1];if(occupiedColumns.has(target)||occupiedColumns.has(partner))continue;
    for(const seat of pool.filter(s=>s[1]===target).sort((a,b)=>a[0]-b[0]))fallback[r.id].push({seat,partner});
   }
  }
  for(const g of groups){
   let n=reservation.remaining[g.key];
   for(const r of rooms.filter(r=>Number(r.school_id)===Number(g.school_id)))for(const {seat,partner} of fallback[r.id]){
    if(!n)break;if(used.has(key(r.id,seat))||!safe(g.key,r.id,seat))continue;place(g.key,r.id,seat);n--;
    if(partner!==undefined)(emptyPartnerColumns[r.id]??=new Set()).add(partner);
   }
  }
 }else if(solo)for(const school of [...new Set(groups.map(g=>Number(g.school_id)))]){
  const last=groups.filter(g=>Number(g.school_id)===school&&reservation.remaining[g.key]>0);if(last.length!==1)continue;
  const g=last[0];let n=reservation.remaining[g.key];
  for(const r of rooms.filter(r=>Number(r.school_id)===school))for(const s of [...(seats[r.id]||[])].sort((a,b)=>a[1]-b[1]||a[0]-b[0])){
   if(!n)break;if(used.has(key(r.id,s))||!safe(g.key,r.id,s))continue;place(g.key,r.id,s);n--;
  }
 }
 const reservedByRoom=Object.fromEntries(rooms.map(r=>[r.id,(seats[r.id]||[]).filter(s=>emptyPartnerColumns[r.id]?.has(s[1])).length]));
 return {assigned:used.size,rooms:roomUsed.size,missing,reservation,emptyPartnerColumns,roomAssigned,reservedByRoom};
};
// Suggest balanced pairs within each school, always carrying surplus students forward.
const suggestPairs=(groups,existing=[])=>{
 const remaining=reservePairs(groups,existing).remaining,result=[];
 for(const school of [...new Set(groups.map(g=>g.school_id))]){
  const available=()=>groups.filter(g=>g.school_id===school&&remaining[g.key]>0).sort((a,b)=>remaining[b.key]-remaining[a.key]);
  let candidates=available();
  while(candidates.length>1){
   const a=candidates.find(g=>candidates.some(h=>compatible(g,h)));if(!a)break;
   const b=candidates.find(g=>compatible(a,g));
   const count=Math.min(remaining[a.key],remaining[b.key]);
   result.push({left:a.key,right:b.key,rooms:[]});remaining[a.key]-=count;remaining[b.key]-=count;candidates=available();
  }
 }
 return result;
};
if(typeof module!=='undefined')module.exports={reservePairs,previewAllocation,suggestPairs};
if(typeof document==='undefined')return;
const dataElement=document.getElementById('paired-seating-data');if(!dataElement)return;
const data=JSON.parse(dataElement.textContent),cycle=document.getElementById('cycle-select'),session=document.getElementById('session-select');
const list=document.getElementById('pairings-list'),add=document.getElementById('add-pairing'),submit=document.getElementById('generate-button'),solo=document.getElementById('seat-remaining');
const suggest=document.getElementById('suggest-pairings'),search=document.getElementById('pairing-search'),addBottom=document.getElementById('add-pairing-bottom'),status=document.getElementById('pairing-status'),undo=document.getElementById('undo-pairings');
let pairs=[],sequence=0,undoPairs=null;
const el=(tag,text,cls)=>{const n=document.createElement(tag);if(text!==undefined)n.textContent=text;if(cls)n.className=cls;return n;};
const groups=()=>data.sessions[session.value]||[],group=key=>groups().find(g=>g.key===key);
const move=(items,i,d)=>{undoPairs=null;status.textContent='';[items[i],items[i+d]]=[items[i+d],items[i]];render();};
const button=(text,label,disabled,action)=>{const b=el('button',text,'secondary-button');b.type='button';b.disabled=disabled;b.dataset.focusKey=label;b.setAttribute('aria-label',label);b.addEventListener('click',action);return b;};
const render=()=>{
 const focused=document.activeElement?.dataset.focusKey;
 if(solo.value==='2'){
  let converted=0;pairs=pairs.filter(p=>{const a=group(p.left),b=group(p.right);if(a&&b&&a.school_id===b.school_id&&!compatible(a,b)){converted++;return false;}return true;});
  if(converted)status.textContent='Incompatible saved pairings will use alternating columns with empty partners. Same-branch and shared-paper students stay apart.';
 }
 let state=reservePairs(groups(),[]);
 pairs.forEach((p,i)=>{
  for(const side of ['left','right'])if(!state.remaining[p[side]])p[side]='';
  if(p.left&&p.right&&group(p.left)?.school_id!==group(p.right)?.school_id)p.right='';
  const school=group(p.left||p.right)?.school_id;
  p.rooms=p.rooms.filter(id=>data.rooms.some(r=>Number(r.id)===id&&Number(r.school_id)===Number(school)&&(data.seats[id]||[]).length));
  state=reservePairs(groups(),pairs.slice(0,i+1));
 });
 const reservation=reservePairs(groups(),pairs);list.replaceChildren();
 pairs.forEach((p,i)=>{
  const step=reservation.steps[i],card=el('section',undefined,'panel pairing-card'),head=el('div',undefined,'pairing-card-heading'),actions=el('div',undefined,'pairing-priority-actions');
  card.id='pairing-'+p.id;card.dataset.ready=String(step.valid);
  const title=el('div',undefined,'pairing-card-title'),number=el('span',String(i+1).padStart(2,'0'),'pairing-number');number.setAttribute('aria-hidden','true');
  title.append(number,el('h3','Pair '+(i+1)),el('span',step.valid?'Ready':'Choose groups','pairing-card-status'));head.append(title);
  actions.append(button('↑','Move pairing '+(i+1)+' up',i===0,()=>move(pairs,i,-1)),button('↓','Move pairing '+(i+1)+' down',i===pairs.length-1,()=>move(pairs,i,1)),button('Remove','Remove pairing '+(i+1),false,()=>{undoPairs=null;status.textContent='';pairs=pairs.filter(x=>x.id!==p.id);render();}));
  head.append(actions);card.append(head);const fields=el('div',undefined,'form-grid two');
  for(const [side,label] of [['left','Group A'],['right','Group B']]){
   const field=el('label',label),select=el('select');select.name='pairings['+i+']['+side+']';select.dataset.focusKey=p.id+'-'+side;select.required=true;select.setAttribute('aria-label','Pair '+(i+1)+' '+label);select.append(new Option('Select branch, batch and year',''));
   const other=group(p[side==='left'?'right':'left']);
   for(const g of groups()){
    if(search.value.trim()&&!g.label.toLowerCase().includes(search.value.trim().toLowerCase())&&g.key!==p[side])continue;
    const reason=other&&g.key!==other.key?(branch(g)===branch(other)?' · same branch':papers(g).some(p=>papers(other).includes(p))?' · shared paper today':''):'';
    const n=step.before[g.key],option=new Option(g.label+' · '+n+' remaining'+(!n?' · fully paired':reason),g.key);
    option.disabled=!n||!!other&&!compatible(g,other);select.append(option);
   }
   select.value=p[side];select.addEventListener('change',()=>{undoPairs=null;status.textContent='';p[side]=select.value;render();});field.append(select);
   const selected=group(p[side]);field.append(el('small',selected?selected.label+' · '+step.before[selected.key]+' available':'Choose a branch, batch and year.','pairing-group-note'));fields.append(field);
  }
  card.append(fields);
  if(step.valid){const count=el('p',undefined,'pairing-count'),icon=el('i',undefined,'ti ti-circle-check');icon.setAttribute('aria-hidden','true');count.append(icon,el('span',step.count+' + '+step.count+' students paired · '+(step.before[p.left]-step.count+step.before[p.right]-step.count)+' left in these groups'));card.append(count);}
  else card.append(el('p','Choose different branches with no shared paper today. Any batch or year is allowed.','pairing-incomplete'));
  const roomDetails=el('details',undefined,'pairing-room-settings'),roomSummary=el('summary',p.rooms.length?p.rooms.length+' preferred room'+(p.rooms.length===1?'':'s'):'Rooms: automatic · change');roomDetails.open=!!p.roomsOpen;
  roomDetails.addEventListener('toggle',()=>{p.roomsOpen=roomDetails.open;});roomDetails.append(roomSummary);
  const choices=el('fieldset',undefined,'pairing-room-choices');choices.append(el('legend','Preferred rooms (optional)'));
  const a=group(p.left),b=group(p.right);
  if(!a||!b)choices.append(el('p','Choose both groups to set room preferences.'));
  else{
   choices.append(el('p','Selected rooms are tried first. Shared rooms and other rooms in this school are available automatically; lower saved room priority numbers come first.'));
   for(const r of data.rooms.filter(r=>Number(r.school_id)===Number(a.school_id)&&(data.seats[r.id]||[]).length)){
    const label=el('label'),check=el('input');check.type='checkbox';check.dataset.focusKey=p.id+'-room-'+r.id;check.checked=p.rooms.includes(Number(r.id));
    label.append(check,el('span',r.code+' · '+r.school_code+' · '+data.seats[r.id].length+' available seats · saved priority '+r.priority));
    check.addEventListener('change',()=>{undoPairs=null;status.textContent='';p.rooms=check.checked?[...p.rooms,Number(r.id)]:p.rooms.filter(id=>id!==Number(r.id));render();});choices.append(label);
   }
  }
  roomDetails.append(choices);const preferences=el('ol',undefined,'pairing-room-priorities');
  p.rooms.forEach((id,j)=>{
   const r=data.rooms.find(r=>Number(r.id)===id),row=el('li'),input=el('input');input.type='hidden';input.name='pairings['+i+'][room_ids][]';input.value=id;
   row.append(input,el('span',(j+1)+'. '+r.code),button('↑','Raise '+r.code+' priority for pairing '+(i+1),j===0,()=>move(p.rooms,j,-1)),button('↓','Lower '+r.code+' priority for pairing '+(i+1),j===p.rooms.length-1,()=>move(p.rooms,j,1)));preferences.append(row);
  });
  roomDetails.append(preferences);card.append(roomDetails);list.append(card);
 });
 document.getElementById('pairings-empty').hidden=pairs.length>0;
 const result=previewAllocation(groups(),data.rooms,data.seats,pairs,solo.value==='1',solo.value==='2'),required=groups().reduce((n,g)=>n+Number(g.count),0);
 const schools=new Set(groups().map(g=>Number(g.school_id))),availableRooms=data.rooms.filter(r=>!session.value||schools.has(Number(r.school_id)));
 const available=availableRooms.reduce((n,r)=>n+(data.seats[r.id]||[]).length,0),reserved=availableRooms.reduce((n,r)=>n+(result.reservedByRoom[r.id]||0),0);
 document.getElementById('available-seat-total').textContent=available.toLocaleString();
 document.getElementById('available-room-total').textContent=availableRooms.length+' active rooms';
 document.getElementById('preview-available-seats').textContent=available.toLocaleString();document.getElementById('preview-reserved-seats').textContent=reserved.toLocaleString();
 document.getElementById('availability-scope').textContent=session.value?'For the selected session’s schools. Blocked seats excluded; spacing and pairing rules can reduce allocation.':'Across active schools. Select a session to see its available rooms and seats.';
 const capacityBody=document.getElementById('room-capacity-rows');capacityBody.replaceChildren();
 for(const r of availableRooms){const row=el('tr');for(const value of [r.code,r.school_code,(data.seats[r.id]||[]).length,result.roomAssigned[r.id]||0,result.reservedByRoom[r.id]||0])row.append(el('td',String(value)));capacityBody.append(row);}
 if(!availableRooms.length){const row=el('tr'),cell=el('td','No active rooms available for this session.');cell.colSpan=5;row.append(cell);capacityBody.append(row);}
 document.getElementById('pairing-summary').textContent=result.assigned+' of '+required+' students can be seated in '+result.rooms+' rooms. '+(required-result.assigned)+' unallocated.';
 const percent=required?Math.round(result.assigned/required*100):0;
 document.getElementById('preview-assigned').textContent=result.assigned.toLocaleString();
 document.getElementById('preview-total').textContent=required.toLocaleString();
 document.getElementById('preview-rooms').textContent=result.rooms;
 document.getElementById('preview-empty-columns').textContent=Object.values(result.emptyPartnerColumns).reduce((n,columns)=>n+columns.size,0);
 const unallocated=document.getElementById('preview-unallocated');unallocated.textContent=(required-result.assigned).toLocaleString();unallocated.dataset.warning=String(required>result.assigned);
 document.getElementById('preview-progress').value=percent;document.getElementById('preview-percent').textContent=percent+'%';
 document.getElementById('shortage-details').hidden=required===result.assigned;
 document.getElementById('shortage-summary').textContent=(required-result.assigned)+' students need seats';
 const warnings=document.getElementById('pairing-shortages');warnings.replaceChildren();
 for(const g of groups())if(result.missing[g.key])warnings.append(el('p',g.label+': '+result.missing[g.key]+' still need seats.','pairing-shortage'));
 const canPair=groups().some(g=>reservation.remaining[g.key]>0&&groups().some(h=>compatible(g,h)&&reservation.remaining[h.key]>0));
 add.disabled=!canPair||reservation.steps.some(s=>!s.valid);
 addBottom.disabled=add.disabled;addBottom.hidden=!pairs.length;
 suggest.disabled=!session.value||!suggestPairs(groups(),pairs).length;undo.hidden=!undoPairs;
 document.getElementById('pairing-pattern-help').textContent=!session.value?'Choose a session, then auto-pair different branches.':suggest.disabled?'No more safe branch pairs. Unmatched groups can use alternating columns.':'One click pairs different branches across any batches or years. Rooms are allocated when you generate.';
 const ready=reservation.steps.filter(s=>s.valid).length;document.getElementById('pairing-count').textContent=ready+' pair'+(ready===1?'':'s')+' ready';
 const remainingList=document.getElementById('remaining-groups');remainingList.replaceChildren();
 for(const g of groups())if(reservation.remaining[g.key]>0)remainingList.append(el('li',g.label+' · '+reservation.remaining[g.key]+' remaining'));
 document.getElementById('remaining-count').textContent=groups().filter(g=>reservation.remaining[g.key]>0).length+' groups with students left';
 submit.disabled=(!pairs.length&&solo.value==='0')||reservation.steps.some(s=>!s.valid)||!result.assigned;
 const note=document.getElementById('pairing-review-note');note.dataset.ready=String(!submit.disabled&&required===result.assigned);
 note.textContent=!session.value?'Choose a session to start your seating plan.':reservation.steps.some(s=>!s.valid)?'Complete or remove unfinished pairs to generate a draft.':!required?'No eligible students in this session.':required===result.assigned?'All students have a seat. Your draft is ready to generate.':!result.assigned?'Add pairs or choose alternating columns for unmatched groups.':'You can generate a draft. Resolve unallocated students before publishing.';
 document.getElementById('pairings-empty-message').textContent=!session.value?'Choose a session above to get started.':!required?'No eligible students were found for this session.':solo.value==='2'?'No pair needed. Unmatched students use alternating columns; partner columns stay empty.':'No safe pairs available. Choose alternating columns to generate seating without a pair.';
 if(focused)Array.from(list.querySelectorAll('[data-focus-key]')).find(n=>n.dataset.focusKey===focused)?.focus({preventScroll:true});
};
const changeSession=restore=>{
 undoPairs=null;search.value='';status.textContent='';
 const [date,shift]=session.value.split('|');document.getElementById('exam-date').value=date||'';document.getElementById('shift-id').value=shift||'';
 pairs=restore&&data.old?.session===session.value?Object.values(data.old.pairings||{}).map(p=>({id:sequence++,left:String(p.left||''),right:String(p.right||''),rooms:Object.values(p.room_ids||{}).map(Number)})):[];
 if(!pairs.length&&groups().some(g=>groups().some(h=>compatible(g,h))))pairs.push({id:sequence++,left:'',right:'',rooms:[]});render();
};
cycle.addEventListener('change',()=>{if(cycle.value)location.href=cycle.dataset.url+encodeURIComponent(cycle.value);});
session.addEventListener('change',()=>changeSession(false));solo.addEventListener('change',render);
const addPair=()=>{undoPairs=null;status.textContent='';const p={id:sequence++,left:'',right:'',rooms:[]};pairs.push(p);render();document.getElementById('pairing-'+p.id).querySelector('select').focus();};
add.addEventListener('click',addPair);addBottom.addEventListener('click',addPair);
search.addEventListener('input',render);
suggest.addEventListener('click',()=>{
 undoPairs=pairs.map(p=>({...p,rooms:[...p.rooms]}));
 const reservation=reservePairs(groups(),pairs);pairs=pairs.filter((p,i)=>reservation.steps[i].valid);
 const suggested=suggestPairs(groups(),pairs);pairs.push(...suggested.map(p=>({...p,id:sequence++})));
 search.value='';render();status.textContent='Added '+suggested.length+' suggested pairs. Review the groups and allocation preview before generating.';undo.focus();
});
undo.addEventListener('click',()=>{pairs=undoPairs;undoPairs=null;render();status.textContent='Suggested pairs undone.';suggest.focus();});
changeSession(true);
})();
