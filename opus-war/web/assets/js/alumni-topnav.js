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
    var userDropdown = nav.querySelector('.topnav-user-dropdown');

    if (!primaryLinks || !overflowMenu || !moreBtn) {
      return;
    }

    var overflowItems = Array.prototype.slice.call(primaryLinks.querySelectorAll('[data-overflow-item="true"]'));
    var isMobile = function () {
      return window.matchMedia('(max-width: 768px)').matches;
    };

    // Function to get all submenu groups (including those in overflow)
    function getAllSubmenuGroups() {
      return Array.prototype.slice.call(nav.querySelectorAll('.topnav-link-group'));
    }

    function closeOverflowMenu() {
      overflowMenu.classList.remove('is-open');
      moreBtn.classList.remove('is-open');
      moreBtn.setAttribute('aria-expanded', 'false');
    }

    function closeSubmenus(exceptionGroup) {
      getAllSubmenuGroups().forEach(function (group) {
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

    // Adjust submenu position if it overflows to the right
    function adjustSubmenuPosition(submenu) {
      if (!submenu) return;

      // Reset position first
      submenu.classList.remove('topnav-submenu-right');
      submenu.style.right = '';
      submenu.style.left = '';

      // Small delay to allow rendering
      setTimeout(function () {
        var rect = submenu.getBoundingClientRect();
        var viewportWidth = window.innerWidth;

        // If submenu overflows to the right, reposition to the left
        if (rect.right > viewportWidth - 10) {
          submenu.classList.add('topnav-submenu-right');
        }
      }, 10);
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

    // Use event delegation for submenu groups (works even after DOM moves)
    nav.addEventListener('click', function(event) {
      var trigger = event.target.closest('.topnav-link-group > .topnav-link');
      if (!trigger) return;

      var group = trigger.closest('.topnav-link-group');
      if (!group) return;

      // Don't handle if it's in mobile links (they have their own handler)
      if (group.closest('.topnav-mobile-links')) return;

      event.preventDefault();
      event.stopPropagation();

      var willOpen = !group.classList.contains('is-open');

      // Close other submenus but keep overflow open
      closeSubmenus(group);
      closeUserDropdown();

      if (willOpen) {
        group.classList.add('is-open');
        trigger.setAttribute('aria-expanded', 'true');
        // Adjust submenu position for overflow
        var submenu = group.querySelector('.topnav-submenu');
        adjustSubmenuPosition(submenu);
      } else {
        group.classList.remove('is-open');
        trigger.setAttribute('aria-expanded', 'false');
      }
    });

    // Mobile submenu groups
    var mobileLinks = nav.querySelector('.topnav-mobile-links');
    if (mobileLinks) {
      mobileLinks.addEventListener('click', function(event) {
        var trigger = event.target.closest('.topnav-link-group > .topnav-link');
        if (!trigger) return;

        var group = trigger.closest('.topnav-link-group');
        if (!group) return;

        event.preventDefault();
        event.stopPropagation();

        var willOpen = !group.classList.contains('is-open');

        // Close other mobile submenus
        var mobileGroups = mobileLinks.querySelectorAll('.topnav-link-group');
        mobileGroups.forEach(function(g) {
          if (g !== group) {
            g.classList.remove('is-open');
            var t = g.querySelector('.topnav-link');
            if (t) t.setAttribute('aria-expanded', 'false');
          }
        });

        if (willOpen) {
          group.classList.add('is-open');
          trigger.setAttribute('aria-expanded', 'true');
          // Adjust submenu position for overflow on mobile
          var submenu = group.querySelector('.topnav-submenu');
          adjustSubmenuPosition(submenu);
        } else {
          group.classList.remove('is-open');
          trigger.setAttribute('aria-expanded', 'false');
        }
      });
    }

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

    window.addEventListener('resize', function () {
      recomputeOverflow();
      // Re-adjust all open submenus on resize
      var openGroups = nav.querySelectorAll('.topnav-link-group.is-open');
      openGroups.forEach(function (group) {
        var submenu = group.querySelector('.topnav-submenu');
        adjustSubmenuPosition(submenu);
      });
    });
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

