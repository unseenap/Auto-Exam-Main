(() => {
  'use strict';
  const scope=document.getElementById('student-bulk-scope');
  if(!scope)return;
  const target=document.getElementById('student-bulk-target');
  const options=JSON.parse(document.getElementById('student-bulk-options').textContent);
  const update=()=>{
    const all=scope.value==='all',review=scope.value==='review',noTarget=all||review,items=options[scope.value]||[];
    target.replaceChildren(new Option(all?'All students':review?'All students marked Review':items.length?'Select a group':'No groups available',''));
    for(const item of items)target.add(new Option(item.label,item.value));
    target.disabled=noTarget||!scope.value||!items.length;
    target.required=!noTarget;
    document.getElementById('student-bulk-scope-help').textContent=review?'Selects only students with parsing status Review, across all schools, including students without a programme mapping. Verified students are kept. Preview the matching count before confirming.':all?'This selects every student in the database. The next page shows how many can be deleted and how many are protected.':'Student-record name options match that exact saved name across all schools. Review the target and count on the next page.';
  };
  scope.addEventListener('change',update);
  window.addEventListener('pageshow',update);
  update();
})();
