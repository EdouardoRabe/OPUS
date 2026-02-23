-- Active: 1736646695640@@127.0.0.1@5432@opus@public
CREATE TABLE poste(
   idposte VARCHAR(20) ,
   libelle VARCHAR(150)  NOT NULL,
   PRIMARY KEY(idposte)
);

CREATE TABLE parcours(
   idparcours VARCHAR(20) ,
   libelle VARCHAR(250)  NOT NULL,
   PRIMARY KEY(idparcours)
);

CREATE TABLE promotion(
   idpromotion VARCHAR(20) ,
   annee INTEGER NOT NULL,
   libelle VARCHAR(50)  NOT NULL,
   idparcours VARCHAR(20)  NOT NULL,
   FOREIGN KEY(idparcours) REFERENCES parcours(idparcours),
   PRIMARY KEY(idpromotion)
);

CREATE TABLE specialite(
   idspecialite VARCHAR(20) ,
   libelle VARCHAR(250)  NOT NULL,
   PRIMARY KEY(idspecialite)
);

CREATE TABLE diplome(
   iddiplome VARCHAR(20) ,
   libelle VARCHAR(250)  NOT NULL,
   PRIMARY KEY(iddiplome)
);

CREATE TABLE option(
   idoption VARCHAR(50) ,
   libelle VARCHAR(250)  NOT NULL,
   PRIMARY KEY(idoption)
);

CREATE TABLE mediatype(
   idmediatype VARCHAR(20) ,
   libelle VARCHAR(50)  NOT NULL,
   PRIMARY KEY(idmediatype)
);

CREATE TABLE typepublication(
   idtypepublication VARCHAR(20) ,
   libelle VARCHAR(250)  NOT NULL,
   PRIMARY KEY(idtypepublication)
);

CREATE TABLE reactiontype(
   idreactiontype VARCHAR(50) ,
   libelle VARCHAR(50)  NOT NULL,
   PRIMARY KEY(idreactiontype)
);

CREATE TABLE typesignalement(
   typesignalement VARCHAR(20) ,
   libelle VARCHAR(150)  NOT NULL,
   PRIMARY KEY(typesignalement)
);

CREATE TABLE profil(
   idprofil VARCHAR(20) ,
   email VARCHAR(250) ,
   nom VARCHAR(450)  NOT NULL,
   prenom VARCHAR(450)  NOT NULL,
   dtn DATE NOT NULL,
   telephone VARCHAR(250)  NOT NULL,
   idpromotion VARCHAR(20)  NOT NULL,
   idparcours VARCHAR(20)  NOT NULL,
   idutilisateur integer NOT NULL,
   PRIMARY KEY(idprofil),
   UNIQUE(idutilisateur),
   UNIQUE(email),
   FOREIGN KEY(idpromotion) REFERENCES promotion(idpromotion),
   FOREIGN KEY(idparcours) REFERENCES parcours(idparcours),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);

CREATE TABLE visibilite(
   idvisibilite VARCHAR(20) ,
   champ VARCHAR(50)  NOT NULL,
   status INTEGER NOT NULL,
   daty DATE,
   idprofil VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idvisibilite),
   FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);

CREATE TABLE experience(
   idexperience VARCHAR(20) ,
   entreprise VARCHAR(500)  NOT NULL,
   debut DATE NOT NULL,
   fin DATE NOT NULL,
   description TEXT,
   etat INTEGER NOT NULL,
   idprofil VARCHAR(20)  NOT NULL,
   idposte VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idexperience),
   FOREIGN KEY(idprofil) REFERENCES profil(idprofil),
   FOREIGN KEY(idposte) REFERENCES poste(idposte)
);

CREATE TABLE specialiteprofil(
   idspecialite VARCHAR(20) ,
   idprofil VARCHAR(20) ,
   specialiteprofil VARCHAR(20) ,
   etat INTEGER NOT NULL,
   niveau INTEGER NOT NULL,
   PRIMARY KEY(idspecialite, idprofil, specialiteprofil),
   FOREIGN KEY(idspecialite) REFERENCES specialite(idspecialite),
   FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);

CREATE TABLE profildiplome(
   idoption VARCHAR(50) ,
   idprofil VARCHAR(20) ,
   idprofildiplome VARCHAR(20) ,
   etat INTEGER NOT NULL,
   iddiplome VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idoption, idprofil, idprofildiplome),
   FOREIGN KEY(idoption) REFERENCES option(idoption),
   FOREIGN KEY(idprofil) REFERENCES profil(idprofil),
   FOREIGN KEY(iddiplome) REFERENCES diplome(iddiplome)
);

CREATE TABLE utilisateurhistoetat(
   idutilisateurhistoetat VARCHAR(20) ,
   daty DATE NOT NULL,
   etat INTEGER NOT NULL,
   remarque VARCHAR(250)  NOT NULL,
   idutilisateur integer NOT NULL,
   PRIMARY KEY(idutilisateurhistoetat),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);

CREATE TABLE photo(
   idphoto VARCHAR(20) ,
   image TEXT NOT NULL,
   type INTEGER NOT NULL,
   daty DATE NOT NULL,
   heure VARCHAR(50)  NOT NULL,
   idprofil VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idphoto),
   FOREIGN KEY(idprofil) REFERENCES profil(idprofil)
);

CREATE TABLE publication(
   idpublication VARCHAR(20) ,
   daty DATE NOT NULL,
   descritpion TEXT,
   etat INTEGER NOT NULL,
   idorigine VARCHAR(50) ,
   heure VARCHAR(50)  NOT NULL,
   idtypepublication VARCHAR(20)  NOT NULL,
   idutilisateur integer NOT NULL,
   PRIMARY KEY(idpublication),
   FOREIGN KEY(idtypepublication) REFERENCES typepublication(idtypepublication),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);

CREATE TABLE media(
   idmedia VARCHAR(20) ,
   mediaurl TEXT NOT NULL,
   idmediatype VARCHAR(20)  NOT NULL,
   idpublication VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idmedia),
   FOREIGN KEY(idmediatype) REFERENCES mediatype(idmediatype),
   FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);

CREATE TABLE notification(
   idnotification VARCHAR(20) ,
   objet VARCHAR(250)  NOT NULL,
   daty DATE NOT NULL,
   idorigine VARCHAR(50)  NOT NULL,
   lien TEXT NOT NULL,
   etat INTEGER NOT NULL,
   heure VARCHAR(50)  NOT NULL,
   idutilisateur integer NOT NULL,
   PRIMARY KEY(idnotification),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);

CREATE TABLE identification(
   ididentification VARCHAR(20) ,
   idutilisateur integer NOT NULL,
   idpublication VARCHAR(20)  NOT NULL,
   PRIMARY KEY(ididentification),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
   FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);

CREATE TABLE publicationreaction(
   idpublicationreaction VARCHAR(20) ,
   idreactiontype VARCHAR(50)  NOT NULL,
   idutilisateur integer NOT NULL,
   idpublication VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idpublicationreaction),
   FOREIGN KEY(idreactiontype) REFERENCES reactiontype(idreactiontype),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
   FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);

CREATE TABLE publicationcommentaire(
   idpublicationcommentaire VARCHAR(20) ,
   description VARCHAR(250)  NOT NULL,
   etat INTEGER NOT NULL,
   idutilisateur integer NOT NULL,
   idpublicationcommentaire_1 VARCHAR(20) ,
   idpublication VARCHAR(20)  NOT NULL,
   PRIMARY KEY(idpublicationcommentaire),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
   FOREIGN KEY(idpublicationcommentaire_1) REFERENCES publicationcommentaire(idpublicationcommentaire),
   FOREIGN KEY(idpublication) REFERENCES publication(idpublication)
);

CREATE TABLE commentairereaction(
   idcommentairereaction VARCHAR(20) ,
   idutilisateur integer NOT NULL,
   idpublicationcommentaire VARCHAR(20)  NOT NULL,
   idreactiontype VARCHAR(50)  NOT NULL,
   PRIMARY KEY(idcommentairereaction),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser),
   FOREIGN KEY(idpublicationcommentaire) REFERENCES publicationcommentaire(idpublicationcommentaire),
   FOREIGN KEY(idreactiontype) REFERENCES reactiontype(idreactiontype)
);

CREATE TABLE evenement(
   idevenement VARCHAR(20) ,
   description TEXT,
   daty DATE NOT NULL,
   datefin DATE,
   datedebut DATE NOT NULL,
   idutilisateur integer NOT NULL,
   PRIMARY KEY(idevenement),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);

CREATE TABLE signalementpublication(
   idsignalementpublication VARCHAR(20) ,
   daty DATE NOT NULL,
   descritpion VARCHAR(50) ,
   typesignalement VARCHAR(20)  NOT NULL,
   idpublication VARCHAR(20)  NOT NULL,
   idutilisateur integer NOT NULL,
   PRIMARY KEY(idsignalementpublication),
   FOREIGN KEY(typesignalement) REFERENCES typesignalement(typesignalement),
   FOREIGN KEY(idpublication) REFERENCES publication(idpublication),
   FOREIGN KEY(idutilisateur) REFERENCES utilisateur(refuser)
);

-- 1) 1 réaction max par utilisateur sur une publication
ALTER TABLE publicationreaction
ADD CONSTRAINT uq_publicationreaction_user_publication
UNIQUE (idutilisateur, idpublication);

-- 2) 1 réaction max par utilisateur sur un commentaire
ALTER TABLE commentairereaction
ADD CONSTRAINT uq_commentairereaction_user_commentaire
UNIQUE (idutilisateur, idpublicationcommentaire);

-- 3) 1 signalement max par utilisateur sur une publication
ALTER TABLE signalementpublication
ADD CONSTRAINT uq_signalementpublication_user_publication
UNIQUE (idutilisateur, idpublication);
