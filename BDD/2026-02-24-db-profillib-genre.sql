-- ================================================================
-- 2026-02-24 : Mise a jour vue profillib avec genre (idgenre + genrelib)
--              + etatdetail / etatlib depuis historiqueactif
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
    u.loginuser,
    -- Dernier etat detaille depuis historiqueactif
    COALESCE(
        (SELECT ha.estactif FROM historiqueactif ha
         WHERE ha.idutilisateur = CAST(u.refuser AS varchar)
         ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE WHEN u.estactif = 1 THEN 1 ELSE 0 END
    ) AS etatdetail,
    COALESCE(
        (SELECT
            CASE
                WHEN ha.estactif = 0 THEN 'Banni'
                WHEN ha.estactif = 1 THEN 'Cree'
                WHEN ha.estactif = 11 THEN 'Valide'
                WHEN ha.estactif = 100 THEN 'Actif'
                ELSE 'Inconnu'
            END
         FROM historiqueactif ha
         WHERE ha.idutilisateur = CAST(u.refuser AS varchar)
         ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE WHEN u.estactif = 1 THEN 'Cree' ELSE 'Banni' END
    ) AS etatlib
FROM utilisateur u
    LEFT JOIN profil pr    ON pr.idutilisateur = u.refuser
    LEFT JOIN promotion p  ON p.idpromotion    = pr.idpromotion
    LEFT JOIN parcours parc ON parc.idparcours = pr.idparcours
    LEFT JOIN genre g      ON g.idgenre        = pr.idgenre;

-- Test
SELECT idprofil, nom, prenom, idgenre, genrelib, etatdetail, etatlib FROM profillib LIMIT 5;
