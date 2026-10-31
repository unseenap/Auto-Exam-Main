(() => {
  'use strict';
  const root = document.querySelector('.rooms-dashboard');
  if (!root) return;
  const cards = [...root.querySelectorAll('[data-room-status]')];
  const filters = [...root.querySelectorAll('[data-room-filter]')];
  const search = root.querySelector('#room-search');
  let status = 'all';
  const update = () => {
    const query = search.value.trim().toLocaleLowerCase();
    let count = 0, available = 0;
    for (const card of cards) {
      const visible = (status === 'all' || card.dataset.roomStatus === status) && card.dataset.roomSearch.toLocaleLowerCase().includes(query);
      card.hidden = !visible;
      if (visible) { count++; available += Number(card.dataset.roomAvailable) || 0; }
      else card.querySelector('.rooms-more')?.removeAttribute('open');
    }
    filters.forEach(button => button.setAttribute('aria-pressed', String(button.dataset.roomFilter === status)));
    root.querySelector('#room-results').textContent = `Showing ${count} of ${cards.length} rooms` + (status === 'all' ? '' : ` · ${status}`);
    root.querySelector('#room-filter-empty').hidden = cards.length === 0 || count > 0;
    root.querySelector('#rooms-available-total').textContent = available.toLocaleString();
  };
  filters.forEach(button => {
    button.disabled = false;
    button.addEventListener('click', () => { status = button.dataset.roomFilter; update(); });
  });
  search.disabled = false;
  search.addEventListener('input', update);
  root.querySelector('#room-reset-filters').addEventListener('click', () => { status = 'all'; search.value = ''; update(); search.focus(); });
  update();
})();
