-- création de la vue profillib
CREATE OR REPLACE VIEW profillib AS
SELECT pr.idprofil,
       u.loginuser                     AS email,
       split_part(pr.nom,' ',1)        AS nom,
       split_part(pr.nom,' ',2)        AS prenom,
       pr.dtn                          AS dtn,
       pr.telephone                    AS telephone,
       pr.idutilisateur,
       p.idpromotion,
       p.libelle                       AS promotionlib,
       p.annee                         AS promotionannee,
       parc.idparcours,
       parc.libelle                    AS parcourslib,
       ( SELECT image
         FROM photo
         WHERE idprofil = pr.idprofil
           AND type = 1
         ORDER BY daty DESC, heure DESC
         LIMIT 1
       )                               AS photoprofil,
       ( SELECT image
         FROM photo
         WHERE idprofil = pr.idprofil
           AND type = 0
         ORDER BY daty DESC, heure DESC
         LIMIT 1
       )                               AS photocouverture,
       u.estactif,
       u.profile,
       u.idrole,
       u.refuser
FROM profil pr
LEFT JOIN utilisateur u
       ON u.refuser = pr.idutilisateur
LEFT JOIN promotion p
       ON p.idpromotion = pr.idpromotion
LEFT JOIN parcours parc
       ON parc.idparcours = pr.idparcours;

COMMENT ON VIEW profillib IS
  'Vue des profils utilisateur avec photos (profil et couverture) '
  'et informations de promotion/parcours';

-- test
SELECT * FROM profillib LIMIT 5;