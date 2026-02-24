alter table signalementpublication
add column heure VARCHAR(20)  NOT NULL;

create or REPLACE view signalementpublicationlib AS
SELECT
    s.idsignalementpublication AS idsignalement,
    s.idpublication,
    s.idutilisateur AS idsignalant,
    pub.idutilisateur AS idsignale,
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