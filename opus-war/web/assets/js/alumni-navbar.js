/* ═══════════════════════════════════════════════════
   OPUS ALUMNI — NAVBAR (LinkedIn-style)
   Responsive navbar with overflow management
═══════════════════════════════════════════════════ */

(function() {
  'use strict';

  function initNavbar() {
    const nav = document.querySelector('.alumni-topnav');
    const mainRow = nav.querySelector('.topnav-main-row');
    const primaryLinks = nav.querySelector('.topnav-primary-links');
    const overflowMenu = nav.querySelector('.topnav-overflow-menu');
    const moreBtn = nav.querySelector('.topnav-more-btn');
    const searchToggle = nav.querySelector('.topnav-search-toggle');
    const searchWrap = nav.querySelector('.topnav-search-wrap');
    const searchInput = nav.querySelector('.topnav-search-input');

    if (!nav || !mainRow || !primaryLinks) return;

    // ── Store overflow items ──
    const overflowItems = Array.from(primaryLinks.querySelectorAll('[data-overflow-item="true"]'));

    // ── Check if mobile ──
    const isMobile = () => window.matchMedia('(max-width: 768px)').matches;
    const isTablet = () => window.matchMedia('(max-width: 1100px)').matches;

    // ── Move item to overflow menu ──
    function moveItemToOverflow(item) {
      if (overflowMenu && !overflowMenu.contains(item)) {
        overflowMenu.appendChild(item.cloneNode(true));
        item.style.display = 'none';
      }
    }

    // ── Move item back to primary ──
    function moveItemToPrimary(item) {
      item.style.display = '';
      const overflow = overflowMenu.querySelector(`[data-overflow-item="${item.dataset.overflowItem}"]`);
      if (overflow) overflow.remove();
    }

    // ── Close menus ──
    function closeAllMenus() {
      if (overflowMenu) overflowMenu.classList.remove('is-open');
      if (moreBtn) moreBtn.classList.remove('is-open');
      nav.classList.remove('search-open');
    }

    // ── Recompute overflow ──
    function recomputeOverflow() {
      // Show all first
      overflowItems.forEach(item => moveItemToPrimary(item));

      if (isMobile()) {
        // Hide primary links on mobile
        if (primaryLinks) primaryLinks.style.display = 'none';
        if (moreBtn) moreBtn.style.display = 'none';
        return;
      }

      if (moreBtn) moreBtn.style.display = 'none';
      if (primaryLinks) primaryLinks.style.display = 'flex';

      // Check if overflow needed
      const mainRowWidth = mainRow.offsetWidth;
      const usedWidth = Array.from(mainRow.children).reduce((sum, el) => {
        return sum + el.offsetWidth + 8; // +8 for gap
      }, 0);

      if (usedWidth > mainRowWidth * 0.9) {
        // Move last items to overflow
        for (let i = overflowItems.length - 1; i >= 0; i--) {
          const item = overflowItems[i];
          if (primaryLinks.contains(item)) {
            moveItemToOverflow(item);
            if (moreBtn) moreBtn.style.display = 'inline-flex';
          }
        }
      }
    }

    // ── More button click ──
    if (moreBtn) {
      moreBtn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (overflowMenu) {
          overflowMenu.classList.toggle('is-open');
          moreBtn.classList.toggle('is-open');
        }
      });
    }

    // ── Search toggle (mobile) ──
    if (searchToggle && searchInput) {
      searchToggle.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        nav.classList.toggle('search-open');
        if (nav.classList.contains('search-open')) {
          setTimeout(() => searchInput.focus(), 100);
        }
      });

      searchInput.addEventListener('focus', () => {
        nav.classList.add('search-open');
      });
    }

    // ── Close on outside click ──
    document.addEventListener('click', (e) => {
      if (!nav.contains(e.target)) {
        closeAllMenus();
      }
    });

    // ── Close on Escape ──
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeAllMenus();
    });

    // ── Resize listener ──
    let resizeTimeout;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(recomputeOverflow, 250);
    });

    // ── Initial computation ──
    setTimeout(recomputeOverflow, 100);
  }

  // Initialize when DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initNavbar);
  } else {
    initNavbar();
  }
})();

