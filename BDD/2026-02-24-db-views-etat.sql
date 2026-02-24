-- Mise à jour de la vue historiqueactiflib pour les états détaillés
CREATE OR REPLACE VIEW public.historiqueactiflib AS
 SELECT id,
    idutilisateur,
    estactif,
    daty,
        CASE
            WHEN (estactif = 0) THEN 'Banni'::text
            WHEN (estactif = 1) THEN 'Créé'::text
            WHEN (estactif = 11) THEN 'Validé'::text
            WHEN (estactif = 100) THEN 'Actif'::text
            ELSE 'Inconnu'::text
        END AS estactiflib,
    description
   FROM public.historiqueactif ha;

-- Mise à jour de la vue profillib pour inclure le dernier état détaillé
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
    -- Dernière photo de profil (type=1)
    (
        SELECT image
        FROM photo
        WHERE photo.idprofil = pr.idprofil
            AND type = 1
        ORDER BY daty DESC, heure DESC
        LIMIT 1
    ) AS photoprofil,
    -- Dernière photo de couverture (type=0)
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
    -- Dernier état détaillé depuis historiqueactif
    COALESCE(
        (SELECT ha.estactif FROM historiqueactif ha
         WHERE ha.idutilisateur = CAST(u.refuser AS varchar)
         ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE WHEN u.estactif = 1 THEN 11 ELSE 0 END
    ) AS etatdetail,
    COALESCE(
        (SELECT
            CASE
                WHEN ha.estactif = 0 THEN 'Banni'
                WHEN ha.estactif = 1 THEN 'Créé'
                WHEN ha.estactif = 11 THEN 'Validé'
                WHEN ha.estactif = 100 THEN 'Actif'
                ELSE 'Inconnu'
            END
         FROM historiqueactif ha
         WHERE ha.idutilisateur = CAST(u.refuser AS varchar)
         ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE WHEN u.estactif = 1 THEN 'Validé' ELSE 'Banni' END
    ) AS etatlib
FROM utilisateur u
    LEFT JOIN profil pr   ON pr.idutilisateur = u.refuser
    LEFT JOIN promotion p ON p.idpromotion    = pr.idpromotion
    LEFT JOIN parcours parc ON parc.idparcours = pr.idparcours;
