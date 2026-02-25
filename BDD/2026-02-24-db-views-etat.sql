-- Mise a jour de la vue historiqueactiflib pour les etats detailles
CREATE OR REPLACE VIEW public.historiqueactiflib AS
 SELECT id,
    idutilisateur,
    estactif,
    daty,
        CASE
            WHEN (estactif = 0) THEN 'Banni'::text
            WHEN (estactif = 1) THEN 'Cree'::text
            WHEN (estactif = 11) THEN 'Valide'::text
            WHEN (estactif = 100) THEN 'Actif'::text
            ELSE 'Inconnu'::text 
        END AS estactiflib,
    description
   FROM public.historiqueactif ha;
