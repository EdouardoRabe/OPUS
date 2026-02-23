/**
 * ITU Alumni - Adaptive Navbar JavaScript
 * Handles responsive navigation, overflow menus, and submenus
 */
(function () {
  function initAdaptiveNavbar(nav) {
    var primaryLinks = nav.querySelector('.topnav-primary-links');
    var overflowMenu = nav.querySelector('.topnav-overflow-menu');
    var moreBtn = nav.querySelector('.topnav-more-btn');
    var searchToggle = nav.querySelector('.topnav-search-toggle');
    var searchInput = nav.querySelector('.topnav-search');
    var submenuGroups = Array.prototype.slice.call(nav.querySelectorAll('.topnav-link-group'));
    var userDropdown = nav.querySelector('.topnav-user-dropdown');

    if (!primaryLinks || !overflowMenu || !moreBtn) {
      return;
    }

    var overflowItems = Array.prototype.slice.call(primaryLinks.querySelectorAll('[data-overflow-item="true"]'));
    var isMobile = function () {
      return window.matchMedia('(max-width: 768px)').matches;
    };

    function closeOverflowMenu() {
      overflowMenu.classList.remove('is-open');
      moreBtn.classList.remove('is-open');
      moreBtn.setAttribute('aria-expanded', 'false');
    }

    function closeSubmenus(exceptionGroup) {
      submenuGroups.forEach(function (group) {
        if (exceptionGroup && group === exceptionGroup) {
          return;
        }
        group.classList.remove('is-open');

        var trigger = group.querySelector('.topnav-link');
        if (trigger) {
          trigger.setAttribute('aria-expanded', 'false');
        }
      });
    }

    function closeUserDropdown() {
      if (userDropdown) {
        userDropdown.classList.remove('is-open');
        var btn = userDropdown.querySelector('.topnav-user-btn');
        if (btn) {
          btn.setAttribute('aria-expanded', 'false');
        }
      }
    }

    function openOverflowMenu() {
      if (overflowMenu.children.length === 0) {
        return;
      }
      overflowMenu.classList.add('is-open');
      moreBtn.classList.add('is-open');
      moreBtn.setAttribute('aria-expanded', 'true');
    }

    function moveAllToPrimary() {
      overflowItems.forEach(function (item) {
        primaryLinks.appendChild(item);
      });
    }

    function recomputeOverflow() {
      moveAllToPrimary();
      closeOverflowMenu();

      if (isMobile()) {
        moreBtn.style.display = 'none';
        return;
      }

      moreBtn.style.display = 'none';

      while (primaryLinks.scrollWidth > primaryLinks.clientWidth && primaryLinks.children.length > 0) {
        var lastItem = primaryLinks.lastElementChild;
        if (!lastItem || lastItem.getAttribute('data-overflow-item') !== 'true') {
          break;
        }
        overflowMenu.prepend(lastItem);
        moreBtn.style.display = 'inline-flex';
      }

      if (overflowMenu.children.length === 0) {
        moreBtn.style.display = 'none';
      }
    }

    moreBtn.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();

      closeSubmenus();
      closeUserDropdown();

      if (overflowMenu.classList.contains('is-open')) {
        closeOverflowMenu();
      } else {
        openOverflowMenu();
      }
    });

    submenuGroups.forEach(function (group) {
      var trigger = group.querySelector('.topnav-link');
      if (!trigger) {
        return;
      }

      trigger.addEventListener('click', function (event) {
        event.preventDefault();
        event.stopPropagation();

        var willOpen = !group.classList.contains('is-open');
        closeSubmenus(group);
        closeUserDropdown();

        if (willOpen) {
          group.classList.add('is-open');
          trigger.setAttribute('aria-expanded', 'true');
        } else {
          group.classList.remove('is-open');
          trigger.setAttribute('aria-expanded', 'false');
        }
      });
    });

    // User dropdown toggle
    if (userDropdown) {
      var userBtn = userDropdown.querySelector('.topnav-user-btn');
      if (userBtn) {
        userBtn.addEventListener('click', function (event) {
          event.preventDefault();
          event.stopPropagation();

          closeSubmenus();
          closeOverflowMenu();

          var willOpen = !userDropdown.classList.contains('is-open');
          if (willOpen) {
            userDropdown.classList.add('is-open');
            userBtn.setAttribute('aria-expanded', 'true');
          } else {
            userDropdown.classList.remove('is-open');
            userBtn.setAttribute('aria-expanded', 'false');
          }
        });
      }
    }

    if (searchToggle && searchInput) {
      searchToggle.addEventListener('click', function () {
        nav.classList.toggle('search-open');
        if (nav.classList.contains('search-open')) {
          window.setTimeout(function () {
            searchInput.focus();
          }, 70);
        }
      });
    }

    document.addEventListener('click', function (event) {
      if (!nav.contains(event.target)) {
        closeOverflowMenu();
        closeSubmenus();
        closeUserDropdown();
        nav.classList.remove('search-open');
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') {
        closeOverflowMenu();
        closeSubmenus();
        closeUserDropdown();
        nav.classList.remove('search-open');
      }
    });

    window.addEventListener('resize', recomputeOverflow);
    recomputeOverflow();
  }

  function initAll() {
    var navbars = document.querySelectorAll('.alumni-topnav');
    navbars.forEach(initAdaptiveNavbar);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAll);
  } else {
    initAll();
  }
})();

