create VIEW promotionvue AS
SELECT p.idpromotion, p.annee, p.libelle, p.idparcours,
       pr.libelle AS libelleparcours
FROM promotion p
JOIN parcours pr ON p.idparcours = pr.idparcours;