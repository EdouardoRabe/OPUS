alter table promotion add column idparcours VARCHAR(20) not null;
alter table promotion add foreign key (idparcours) references parcours(idparcours);