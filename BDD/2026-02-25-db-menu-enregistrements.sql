-- Menu: Publications enregistrees (sous Mon Profil)
INSERT INTO MENUDYNAMIQUE (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYN000025', 'Enregistrements', 'bi-bookmarks-fill', 'module.jsp?but=alumni/publications-enregistrees.jsp', 3, 1, 'MENDYN000004');

-- Droits role etu
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000037', 'MENDYN000025', '*', 0, 'etu');

-- Droits role md
INSERT INTO USERMENU (id, idmenu, refuser, interdit, idrole) VALUES
('USRM000038', 'MENDYN000025', '*', 0, 'md');
