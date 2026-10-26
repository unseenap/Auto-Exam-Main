(() => {
  const form = document.getElementById('student-directory-filters');
  if (!form) return;
  const school = form.querySelector('[name="school_id"]');
  const programme = form.querySelector('[name="programme_id"]');
  const batch = form.querySelector('[name="batch_id"]');
  const data = JSON.parse(document.getElementById('student-directory-options').textContent);
  const populate = (select, options, enabled, placeholder, emptyLabel) => {
    const previous = select.value;
    select.replaceChildren(new Option(enabled ? (options.length ? placeholder : emptyLabel) : placeholder, ''));
    for (const option of options) select.add(new Option(option.label, String(option.id)));
    select.disabled = !enabled || options.length === 0;
    select.value = options.some(option => String(option.id) === previous) ? previous : '';
  };
  const syncBatch = () => populate(batch, data.batches.filter(item => String(item.programmeId) === programme.value), Boolean(programme.value), programme.value ? 'All batches' : 'Select programme first', 'No batches available');
  const sync = () => {
    populate(programme, data.programmes.filter(item => String(item.schoolId) === school.value), Boolean(school.value), school.value ? 'All programmes' : 'Select school first', 'No programmes available');
    syncBatch();
  };
  school.addEventListener('change', sync);
  programme.addEventListener('change', syncBatch);
  window.addEventListener('pageshow', sync);
  sync();
})();
