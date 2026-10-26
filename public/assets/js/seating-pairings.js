(() => {
  'use strict';
  const dataElement = document.getElementById('paired-seating-data');
  if (!dataElement) return;
  const data = JSON.parse(dataElement.textContent), cycle = document.getElementById('cycle-select'), session = document.getElementById('session-select');
  const list = document.getElementById('pairings-list'), add = document.getElementById('add-pairing'), submit = document.getElementById('generate-button');
  let pairs = [], sequence = 0;
  const el = (tag, text, className) => { const node = document.createElement(tag); if (text !== undefined) node.textContent = text; if (className) node.className = className; return node; };
  const groups = () => data.sessions[session.value] || [];
  const group = key => groups().find(item => item.key === key);
  const room = id => data.rooms.find(item => Number(item.id) === Number(id));
  const recount = () => {
    const remaining = Object.fromEntries(groups().map(item => [item.key, Number(item.count)]));
    let assigned = 0, selectedRooms = 0, valid = pairs.length > 0;
    for (const pair of pairs) {
      const left = group(pair.left), right = group(pair.right);
      if (!left || !right || left.key === right.key || left.school_id !== right.school_id || !pair.rooms.length) { valid = false; continue; }
      for (const id of pair.rooms) {
        selectedRooms++;
        const seats = [...(data.seats[id] || [])].sort((a, b) => a[1] - b[1] || a[0] - b[0]);
        const columns = [...new Set(seats.map(([, c]) => c))].sort((a, b) => a - b);
        for (const [, column] of seats) { const key = columns.indexOf(column) % 2 === 0 ? pair.left : pair.right; if (remaining[key] > 0) { remaining[key]--; assigned++; } }
      }
    }
    const required = groups().reduce((n, item) => n + Number(item.count), 0), missing = required - assigned;
    document.getElementById('pairing-summary').textContent = `${assigned} of ${required} students can be seated in ${selectedRooms} selected rooms. ${missing} unallocated.`;
    const warnings = document.getElementById('pairing-shortages'); warnings.replaceChildren();
    for (const item of groups()) if (remaining[item.key] > 0) warnings.append(el('p', `${item.label}: ${remaining[item.key]} still need seats.`, 'pairing-shortage'));
    submit.disabled = !valid || !assigned;
  };
  const render = () => {
    list.replaceChildren();
    const cohortGroups = groups();
    pairs.forEach((pair, index) => {
      const card = el('section', undefined, 'panel pairing-card'), header = el('div', undefined, 'pairing-card-heading');
      header.append(el('h3', `Pairing ${index + 1}`));
      const remove = el('button', 'Remove', 'text-button'); remove.type = 'button'; remove.addEventListener('click', () => { pairs = pairs.filter(item => item.id !== pair.id); render(); }); header.append(remove); card.append(header);
      const fields = el('div', undefined, 'form-grid two');
      for (const [side, label] of [['left', 'Group A · alternating columns'], ['right', 'Group B · interleaved columns']]) {
        const field = el('label', label), select = el('select'); select.name = `pairings[${index}][${side}]`; select.required = true; select.append(new Option('Select branch, batch and year', ''));
        const other = group(pair[side === 'left' ? 'right' : 'left']);
        for (const item of cohortGroups) { const option = new Option(`${item.label} · ${item.count} students`, item.key); option.disabled = !!other && (item.key === other.key || item.school_id !== other.school_id); select.append(option); }
        select.value = pair[side]; select.addEventListener('change', () => { pair[side] = select.value; pair.rooms = pair.rooms.filter(id => Number(room(id)?.school_id) === group(pair.left)?.school_id); render(); }); field.append(select); fields.append(field);
      }
      card.append(fields);
      const left = group(pair.left), right = group(pair.right), school = left?.school_id;
      const choices = el('fieldset', undefined, 'pairing-room-choices'); choices.append(el('legend', 'Rooms for this pairing'));
      if (!left || !right) choices.append(el('p', 'Choose both groups to see their school’s rooms.'));
      else for (const item of data.rooms.filter(item => Number(item.school_id) === school)) {
        const occupied = pairs.some(other => other.id !== pair.id && other.rooms.includes(Number(item.id)));
        const label = el('label', undefined, occupied ? 'room-used' : ''), checkbox = el('input'); checkbox.type = 'checkbox'; checkbox.name = `pairings[${index}][room_ids][]`; checkbox.value = item.id; checkbox.checked = pair.rooms.includes(Number(item.id)); checkbox.disabled = occupied;
        const seats = data.seats[item.id] || [], columns = [...new Set(seats.map(([, c]) => c))].sort((a, b) => a - b), odd = seats.filter(([, c]) => columns.indexOf(c) % 2 === 0).length;
        label.append(checkbox, el('span', `${item.code} · ${item.school_code} · A: ${odd} / B: ${seats.length - odd} seats${occupied ? ' · used by another pair' : ''}`));
        checkbox.addEventListener('change', () => { pair.rooms = checkbox.checked ? [...pair.rooms, Number(item.id)] : pair.rooms.filter(id => id !== Number(item.id)); render(); }); choices.append(label);
      }
      card.append(choices); list.append(card);
    });
    document.getElementById('pairings-empty').hidden = pairs.length > 0;
    recount();
  };
  const changeSession = restore => {
    const [date, shift] = session.value.split('|'); document.getElementById('exam-date').value = date || ''; document.getElementById('shift-id').value = shift || '';
    pairs = restore && data.old?.session === session.value ? Object.values(data.old.pairings || {}).map(pair => ({ id: sequence++, left: String(pair.left || ''), right: String(pair.right || ''), rooms: Object.values(pair.room_ids || {}).map(Number) })) : [];
    if (!pairs.length && groups().length) pairs.push({ id: sequence++, left: '', right: '', rooms: [] });
    add.disabled = !groups().length; render();
  };
  cycle.addEventListener('change', () => { if (cycle.value) location.href = cycle.dataset.url + encodeURIComponent(cycle.value); });
  session.addEventListener('change', () => changeSession(false));
  add.addEventListener('click', () => { pairs.push({ id: sequence++, left: '', right: '', rooms: [] }); render(); });
  changeSession(true);
})();
