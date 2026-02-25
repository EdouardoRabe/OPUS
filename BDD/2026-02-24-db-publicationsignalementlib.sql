alter table signalementpublication
add column heure VARCHAR(20)  NOT NULL;

create or REPLACE view signalementpublicationlib AS
SELECT
    s.idsignalementpublication AS idsignalement,
    s.idpublication,
    s.idutilisateur AS idsignalant,
    COALESCE(prsignalant.prenom || ' ' || prsignalant.nom, 'Utilisateur #' || s.idutilisateur) AS nomsignalant,
    pub.idutilisateur AS idsignale,
    COALESCE(prsignale.prenom || ' ' || prsignale.nom, 'Utilisateur #' || pub.idutilisateur) AS nomsignale,
    s.typesignalement,
    s.daty,
    s.heure,
    s.descritpion AS motifdesc,
    sp.libelle AS motiflibelle
FROM signalementpublication s
    JOIN publication pub ON pub.idpublication = s.idpublication
    JOIN typesignalement sp ON sp.idtypesignalement = s.typesignalement
    LEFT JOIN profil prsignalant ON prsignalant.idutilisateur = s.idutilisateur
    LEFT JOIN profil prsignale ON prsignale.idutilisateur = pub.idutilisateur;


select * from signalementpublicationlib;