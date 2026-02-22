CREATE OR REPLACE VIEW experiencelib AS
SELECT
    e.idexperience,
    e.entreprise,
    e.debut,
    e.fin,
    e.description,
    e.etat,
    e.idprofil,
    e.idposte,
    p.libelle AS postelib,
    pr.idutilisateur
FROM experience e
LEFT JOIN poste p   ON p.idposte     = e.idposte
LEFT JOIN profil pr ON pr.idprofil   = e.idprofil;

COMMENT ON VIEW experiencelib IS 'Vue experience avec libelle du poste et idutilisateur du profil';

