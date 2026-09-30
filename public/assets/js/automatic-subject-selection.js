document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('scheduler-form');
  if (!form) return;

  const subjects = [...form.querySelectorAll('input[name="programme_course_ids[]"]')];
  // This map is the authoritative selection state. Filters may hide or disable
  // inputs, but they must never change a user's checked/unchecked choice.
  const rememberedChoices = new Map(subjects.map((input) => [input.value, input.checked]));
  const rememberVisibleChoices = () => {
    subjects.forEach((input) => {
      if (!input.closest('label').hidden) rememberedChoices.set(input.value, input.checked);
    });
  };
  const restoreRememberedChoices = () => {
    rememberedChoices.forEach((checked, id) => {
      const input = subjects.find((candidate) => candidate.value === id);
      if (input) input.checked = checked;
    });
    const selected = subjects.filter((input) => !input.disabled && input.checked).length;
    const counter = document.getElementById('selected-subject-count');
    if (counter) counter.textContent = String(selected);
  };

  form.addEventListener('change', (event) => {
    if (event.target.matches('input[name="programme_course_ids[]"]')) {
      rememberedChoices.set(event.target.value, event.target.checked);
      return;
    }
    queueMicrotask(restoreRememberedChoices);
  });
  document.getElementById('select-visible-subjects')?.addEventListener('click', () => queueMicrotask(rememberVisibleChoices));
  document.getElementById('clear-visible-subjects')?.addEventListener('click', () => queueMicrotask(rememberVisibleChoices));

  const semesterScope = JSON.parse(document.getElementById('regular-semester-scope')?.dataset.semesters || '[]').map(String);
  let semesterTrigger = null;
  if (semesterScope.length) {
    const allowed = new Set(semesterScope);
    const semesterInputs = [...form.querySelectorAll('input[name="semesters[]"]')];
    let selectionChanged = false;
    semesterInputs.forEach((input) => {
      const available = allowed.has(input.value);
      input.closest('label').hidden = !available;
      input.disabled = !available;
      if (!available && input.checked) { input.checked = false; selectionChanged = true; }
    });
    if (!semesterInputs.some((input) => !input.disabled && input.checked)) {
      semesterInputs.forEach((input) => { if (!input.disabled) { input.checked = true; selectionChanged = true; } });
    }
    if (selectionChanged) semesterTrigger = semesterInputs.find((input) => !input.disabled) || null;
  }
  // Refresh visibility and totals without changing any subject checkbox.
  if (semesterTrigger) {
    semesterTrigger.dispatchEvent(new Event('change', { bubbles: true }));
  }
});
