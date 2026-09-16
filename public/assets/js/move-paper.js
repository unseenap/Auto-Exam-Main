(() => {
    let active = null;
    const close = (restoreFocus = false) => {
        if (!active) return;
        const { details, trigger, panel } = active;
        panel.hidden = true;
        details.append(panel);
        details.open = false;
        trigger.setAttribute('aria-expanded', 'false');
        active = null;
        if (restoreFocus) trigger.focus();
    };
    const position = () => {
        if (!active) return;
        const { trigger, panel } = active;
        const anchor = trigger.getBoundingClientRect();
        const width = panel.offsetWidth;
        const height = panel.offsetHeight;
        const left = Math.max(12, Math.min(anchor.right - width, innerWidth - width - 12));
        const below = anchor.bottom + 8;
        const top = below + height <= innerHeight - 12 ? below : Math.max(12, anchor.top - height - 8);
        panel.style.left = `${left}px`;
        panel.style.top = `${top}px`;
    };
    document.querySelectorAll('.paper-controls details').forEach((details, index) => {
        const trigger = details.querySelector('summary');
        const panel = details.querySelector('.move-paper-form');
        if (!trigger || !panel) return;
        panel.id = `move-paper-panel-${index}`;
        panel.hidden = true;
        trigger.setAttribute('aria-controls', panel.id);
        trigger.setAttribute('aria-expanded', 'false');
        trigger.addEventListener('click', event => {
            event.preventDefault();
            const wasOpen = active?.trigger === trigger;
            close();
            if (wasOpen) return;
            // Escape the scrolling table's clipping and stacking context.
            document.body.append(panel);
            panel.hidden = false;
            active = { details, trigger, panel };
            trigger.setAttribute('aria-expanded', 'true');
            position();
            panel.querySelector('select')?.focus({ preventScroll: true });
        });
    });
    document.addEventListener('pointerdown', event => {
        if (active && !active.panel.contains(event.target) && !active.trigger.contains(event.target)) close();
    });
    document.addEventListener('keydown', event => {
        if (event.key === 'Escape' && active) { event.preventDefault(); close(true); }
    });
    document.addEventListener('focusin', event => {
        if (active && !active.panel.contains(event.target) && !active.trigger.contains(event.target)) close();
    });
    document.addEventListener('scroll', event => {
        if (active && !active.panel.contains(event.target)) close();
    }, true);
    window.addEventListener('resize', position);
})();
