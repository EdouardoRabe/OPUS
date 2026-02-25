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
    ( SELECT photo.image
           FROM photo
          WHERE (((photo.idprofil)::text = (pr.idprofil)::text) AND (photo.type = 1))
          ORDER BY photo.daty DESC, photo.heure DESC
         LIMIT 1) AS photoprofil,
    ( SELECT photo.image
           FROM photo
          WHERE (((photo.idprofil)::text = (pr.idprofil)::text) AND (photo.type = 0))
          ORDER BY photo.daty DESC, photo.heure DESC
         LIMIT 1) AS photocouverture,
    u.estactif,
    u.profile,
    u.idrole,
    u.refuser,
    u.loginuser,
    COALESCE(( SELECT ha.estactif
           FROM historiqueactif ha
          WHERE ((ha.idutilisateur)::text = ((u.refuser)::character varying)::text)
          ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE
            WHEN (u.estactif = 1) THEN 1
            ELSE 0
        END) AS etatdetail,
    COALESCE(( SELECT
                CASE
                    WHEN (ha.estactif = 0) THEN 'Banni'::text
                    WHEN (ha.estactif = 1) THEN 'Créé'::text
                    WHEN (ha.estactif = 11) THEN 'Validé'::text
                    WHEN (ha.estactif = 100) THEN 'Actif'::text
                    ELSE 'Inconnu'::text
                END AS "case"
           FROM historiqueactif ha
          WHERE ((ha.idutilisateur)::text = ((u.refuser)::character varying)::text)
          ORDER BY ha.daty DESC, ha.id DESC
         LIMIT 1),
        CASE
            WHEN (u.estactif = 1) THEN 'Créé'::text
            ELSE 'Banni'::text
        END) AS etatlib,
        pr.idgenre,
    g.libelle AS genrelib
   FROM (((utilisateur u
     LEFT JOIN profil pr ON ((pr.idutilisateur = u.refuser)))
     LEFT JOIN promotion p ON (((p.idpromotion)::text = (pr.idpromotion)::text)))
     LEFT JOIN parcours parc ON (((parc.idparcours)::text = (pr.idparcours)::text)))
     LEFT JOIN genre g ON (((g.idgenre)::text = (pr.idgenre)::text));

select * from profillib;