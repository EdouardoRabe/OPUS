-- Création de la vue profillib
CREATE OR REPLACE VIEW profillib AS
SELECT u.id AS idprofil,
    u.loginuser AS email,
    SPLIT_PART(u.nomuser, ' ', 1) AS nom,
    SPLIT_PART(u.nomuser, ' ', 2) AS prenom,
    NULL::date AS dtn,
    u.teluser AS telephone,
    u.id AS idutilisateur,
    p.idpromotion,
    p.libelle AS promotionlib,
    p.annee AS promotionannee,
    parc.idparcours,
    parc.libelle AS parcourslib,
    -- Dernière photo de profil (type=1)
    (
        SELECT image
        FROM photo
        WHERE idprofil = u.id
            AND type = 1
        ORDER BY daty DESC,
            heure DESC
        LIMIT 1
    ) AS photoprofil,
    -- Dernière photo de couverture (type=0)  
    (
        SELECT image
        FROM photo
        WHERE idprofil = u.id
            AND type = 0
        ORDER BY daty DESC,
            heure DESC
        LIMIT 1
    ) AS photocouverture,
    u.estactif,
    u.profile,
    u.idrole,
    u.refuser
FROM utilisateur u
    LEFT JOIN promotion p ON p.idpromotion = p.idpromotion
    LEFT JOIN parcours parc ON parc.idparcours = parc.idparcours;
-- Commentaire sur la vue
COMMENT ON VIEW profillib IS 'Vue des profils utilisateur avec photos (profil et couverture) et informations de promotion/parcours';
-- Test de la vue
SELECT *
FROM profillib;