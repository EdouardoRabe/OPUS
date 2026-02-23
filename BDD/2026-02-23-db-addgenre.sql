create table genre(
    idgenre varchar(20),
    libelle varchar(50),
    primary key (idgenre)
);

alter table profil add column idgenre VARCHAR(20) not null;
alter table profil add foreign key (idgenre) references genre(idgenre); 

insert into genre (idgenre, libelle) values ('GEN000001', 'homme');
insert into genre (idgenre, libelle) values ('GEN000002', 'femme');

select * from genre;

CREATE SEQUENCE public.seq_genre START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 999999999999999 CACHE 1;
ALTER SEQUENCE public.seq_genre OWNER TO postgres;

CREATE FUNCTION public.get_seq_genre() RETURNS integer
    LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_genre'));
END
$$;
ALTER FUNCTION public.get_seq_genre() OWNER TO postgres;