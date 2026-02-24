-- ================================================================
-- 2026-02-24 : Mise a jour vue profillib avec genre (idgenre + genrelib)
-- ================================================================

DROP VIEW IF EXISTS profillib;

CREATE OR REPLACE VIEW profillib AS
SELECT
    pr.idprofil,
    pr.email,
    pr.nom,
    pr.prenom,
    pr.dtn,
    pr.telephone,
    u.refuser AS idutilisateur,
    p.idpromotion,
    p.libelle AS promotionlib,
    p.annee AS promotionannee,
    parc.idparcours,
    parc.libelle AS parcourslib,
    -- Genre
    g.idgenre,
    g.libelle AS genrelib,
    -- Derniere photo de profil (type=1)
    (
        SELECT image
        FROM photo
        WHERE photo.idprofil = pr.idprofil
            AND type = 1
        ORDER BY daty DESC, heure DESC
        LIMIT 1
    ) AS photoprofil,
    -- Derniere photo de couverture (type=0)
    (
        SELECT image
        FROM photo
        WHERE photo.idprofil = pr.idprofil
            AND type = 0
        ORDER BY daty DESC, heure DESC
        LIMIT 1
    ) AS photocouverture,
    u.estactif,
    u.profile,
    u.idrole,
    u.refuser,
    u.loginuser
FROM utilisateur u
    LEFT JOIN profil pr    ON pr.idutilisateur = u.refuser
    LEFT JOIN promotion p  ON p.idpromotion    = pr.idpromotion
    LEFT JOIN parcours parc ON parc.idparcours = pr.idparcours
    LEFT JOIN genre g      ON g.idgenre        = pr.idgenre;

-- Test
SELECT idprofil, nom, prenom, idgenre, genrelib FROM profillib LIMIT 5;
