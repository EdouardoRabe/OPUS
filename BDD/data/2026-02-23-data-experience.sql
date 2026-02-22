-- Donnees : postes
INSERT INTO poste (idposte, libelle) VALUES
    ('PST000001', 'Developpeur Full Stack'),
    ('PST000002', 'Chef de Projet Informatique');

-- Donnees : experiences pour PRF000001 (Rakoto Jean)
INSERT INTO experience (
    idexperience, entreprise, debut, fin, description,
    etat, idprofil, idposte
) VALUES
    ('EXP000001', 'Orange Madagascar', '2022-06-01', '2023-12-31',
     'Developpement d''applications web et mobiles pour la direction digitale.',
     1, 'PRF000001', 'PST000001'),
    ('EXP000002', 'ITU Innovation Lab', '2024-01-15', '2025-12-31',
     'Pilotage de projets logiciels en methode Agile/Scrum.',
     1, 'PRF000001', 'PST000002');