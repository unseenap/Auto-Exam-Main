(() => {
  'use strict';
  const root=document.querySelector('[data-attendance-live]');
  if(!root)return;
  const base=root.dataset.base.replace(/\/$/,'');
  const body=root.querySelector('[data-attendance-room-rows]');
  const refreshed=root.querySelector('[data-attendance-refresh]');
  const cell=(value,detail)=>{
    const node=document.createElement('td');
    node.textContent=value??'';
    if(detail){
      const small=document.createElement('small');
      small.textContent=detail;
      node.append(small);
    }
    return node;
  };
  const linkCell=(label,path)=>{
    const node=document.createElement('td'),link=document.createElement('a');
    link.href=base+'/'+path;
    link.textContent=label;
    node.append(link);
    return node;
  };
  const render=rooms=>{
    const fragment=document.createDocumentFragment();
    for(const room of rooms){
      const locked=room.submission_status==='submitted';
      const status=locked?(room.submitted_by?'Teacher locked':'Automatically locked'):(Number(room.revision)?'In progress':'Not started');
      const row=document.createElement('tr');
      row.append(cell(room.cycle_name,room.exam_date+' · '+room.shift_name));
      const roomCell=linkCell(room.room_code,'attendance/'+room.allocation_id+'#attendance-room-'+room.room_id);
      const download=document.createElement('a'),downloadLine=document.createElement('small');
      download.href=base+'/attendance/'+room.allocation_id+'/rooms/'+room.room_id+'/export.xlsx';
      download.textContent='Room Excel';downloadLine.append(download);roomCell.append(downloadLine);
      row.append(roomCell);
      row.append(cell(room.teachers||'Teachers awaiting allocation'));
      for(const key of ['students','present','absent','ufm','unmarked'])row.append(cell(String(Number(room[key]||0))));
      row.append(cell(status,locked?room.locked_by+' · '+room.submitted_at:''));
      row.append(cell(room.updated_by||'No teacher update',room.updated_at));
      fragment.append(row);
      if(locked){
        const form=document.getElementById('attendance-room-'+room.room_id);
        form?.querySelectorAll('select,input:not([type="hidden"]),button').forEach(control=>control.disabled=true);
      }
    }
    if(!rooms.length){
      const row=document.createElement('tr'),empty=cell('No published room attendance sheets yet.');
      empty.colSpan=10;row.append(empty);fragment.append(row);
    }
    body.replaceChildren(fragment);
    const totals={students:0,present:0,absent:0,unmarked:0};
    for(const room of rooms)for(const key of Object.keys(totals))totals[key]+=Number(room[key]||0);
    document.querySelectorAll('[data-attendance-metric]').forEach(node=>{
      const value=totals[node.dataset.attendanceMetric];
      if(value!==undefined)node.textContent=value.toLocaleString();
    });
    document.querySelector('[data-attendance-present-percent]')?.replaceChildren(
      document.createTextNode((totals.students?Math.round(totals.present/totals.students*100):0)+'% of records'));
    const completion=document.querySelector('[data-attendance-completion]');
    if(completion){
      completion.textContent=totals.unmarked?'Attendance is incomplete':'All records completed';
      completion.parentElement.classList.toggle('attention',totals.unmarked>0);
    }
    const sessions=new Map();
    for(const room of rooms){
      const key=String(room.allocation_id);
      if(!sessions.has(key))sessions.set(key,{students:0,present:0,absent:0,unmarked:0,rooms:0});
      const session=sessions.get(key);
      for(const field of ['students','present','absent','unmarked'])session[field]+=Number(room[field]||0);
      session.rooms++;
    }
    document.querySelectorAll('.attendance-session[data-allocation-id]').forEach(card=>{
      const session=sessions.get(card.dataset.allocationId);
      if(!session)return;
      const counts=card.querySelectorAll('dl dd');
      for(const [index,key] of ['students','present','absent'].entries())counts[index].textContent=session[key].toLocaleString();
      const percent=session.students?Math.round((session.students-session.unmarked)/session.students*100):0;
      card.querySelector('.attendance-progress span b').textContent=percent+'%';
      card.querySelector('.attendance-progress i b').style.setProperty('--progress',percent+'%');
      card.querySelector('.attendance-progress small').textContent=session.unmarked.toLocaleString()+' unmarked';
      const count=card.querySelector('[data-room-count]');
      if(count)count.textContent=session.rooms+' room sheets';
    });
  };
  let loading=false;
  const refresh=async()=>{
    if(loading)return;
    loading=true;
    try{
      const response=await fetch(root.dataset.snapshot,{headers:{Accept:'application/json'},cache:'no-store'});
      if(!response.ok)throw Error('Room updates could not be refreshed.');
      const data=await response.json();
      render(data.rooms);
      refreshed.textContent='Updated '+data.refreshed_at;
    }catch(error){
      refreshed.textContent='Live refresh unavailable. Reload to see the latest attendance.';
    }finally{loading=false;}
  };
  setInterval(refresh,15000);
  addEventListener('focus',refresh);
})();
