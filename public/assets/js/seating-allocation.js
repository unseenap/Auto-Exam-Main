(() => {
  'use strict';
  const root = document.querySelector('.allocation-dashboard');
  if (!root) return;
  root.querySelector('#print-room-plans')?.addEventListener('click', () => window.print());

  const picker = root.querySelector('#allocation-room-select');
  const rooms = [...root.querySelectorAll('[data-allocation-room]')];
  if (picker && rooms.length) {
    const previous = root.querySelector('#allocation-room-prev');
    const next = root.querySelector('#allocation-room-next');
    const update = () => {
      const all = picker.value === 'all';
      const index = Number(picker.value);
      rooms.forEach(room => { room.hidden = !all && room.dataset.allocationRoom !== picker.value; });
      previous.disabled = all || index === 0;
      next.disabled = all || index === rooms.length - 1;
      root.querySelector('#allocation-room-position').textContent = all ? rooms.length + ' rooms' : (index + 1) + ' of ' + rooms.length;
    };
    picker.value = rooms[0].dataset.allocationRoom;
    picker.addEventListener('change', update);
    previous.addEventListener('click', () => { picker.value = String(Number(picker.value) - 1); update(); });
    next.addEventListener('click', () => { picker.value = String(Number(picker.value) + 1); update(); });
    update();
  }

  // Keep the existing school and saved-pair restrictions on manual corrections.
  const student = root.querySelector('select[name="assignment_id"]');
  if (student) {
    const seats = student.closest('form').querySelector('select[name="seat_id"]');
    const update = () => {
      const selected = student.selectedOptions[0];
      seats.value = '';
      for (const option of seats.options) {
        if (!option.value) continue;
        option.hidden = !selected?.dataset.school || option.dataset.school !== selected.dataset.school || (option.dataset.group !== '' && option.dataset.group !== selected.dataset.group);
        option.disabled = option.hidden;
      }
    };
    student.addEventListener('change', update);
    update();
  }
})();
