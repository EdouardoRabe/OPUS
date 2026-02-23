/* ═══════════════════════════════════════════════════
   OPUS ALUMNI — SIDEBAR MENU INTERACTIONS
   Gère les sous-menus et animations du menu dynamique
═══════════════════════════════════════════════════ */

(function() {
  'use strict';

  /**
   * Initialise les interactions du menu dynamique
   */
  function initMenuInteractions() {
    const sidebar = document.querySelector('.main-sidebar');
    const sidebarToggle = document.querySelector('.sidebar-toggle');
    const wrapper = document.querySelector('.wrapper');

    if (!sidebar || !sidebarToggle) return;

    // ── Gestion du toggle du sidebar ──
    sidebarToggle.addEventListener('click', function(e) {
      e.preventDefault();
      if (wrapper) {
        wrapper.classList.toggle('sidebar-open');
      }
      sidebar.classList.toggle('open');
    });

    // ── Gestion des sous-menus (clic sur l'icône de flèche) ──
    const menuItems = sidebar.querySelectorAll('.sidebar-menu li');

    menuItems.forEach(function(li) {
      const link = li.querySelector('> a');
      const submenu = li.querySelector('.treeview-menu');

      if (!link || !submenu) return;

      // Vérifie s'il y a des enfants
      const arrow = link.querySelector('.fa-angle-left');
      if (!arrow) return;

      // Ajoute un gestionnaire de clic sur le lien principal
      link.addEventListener('click', function(e) {
        // Si c'est un menu avec sous-éléments, empêcher la navigation
        if (submenu && submenu.children.length > 0) {
          e.preventDefault();
          e.stopPropagation();

          // Toggle du sous-menu
          li.classList.toggle('menu-open');
          submenu.classList.toggle('menu-open');
        }
      });

      // Accorde l'icône à l'état actuel
      if (li.classList.contains('currentMenu') || submenu.classList.contains('menu-open')) {
        li.classList.add('menu-open');
        submenu.classList.add('menu-open');
      }
    });

    // ── Fermeture du sidebar sur mobile au clic d'un lien ──
    const links = sidebar.querySelectorAll('a[href]');
    if (window.innerWidth < 991) {
      links.forEach(function(link) {
        link.addEventListener('click', function() {
          // Ne pas fermer si c'est un menu avec enfants
          const li = link.closest('li');
          const submenu = li ? li.querySelector('.treeview-menu') : null;

          if (!submenu || submenu.children.length === 0) {
            sidebar.classList.remove('open');
            if (wrapper) wrapper.classList.remove('sidebar-open');
          }
        });
      });
    }

    // ── Fermeture au redimensionnement ──
    window.addEventListener('resize', function() {
      if (window.innerWidth >= 991) {
        sidebar.classList.remove('open');
        if (wrapper) wrapper.classList.remove('sidebar-open');
      }
    });
  }

  // Initialiser au chargement du DOM
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMenuInteractions);
  } else {
    initMenuInteractions();
  }
})();

