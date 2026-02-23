\encoding UTF8;
INSERT INTO direction(id, desce)
VALUES ('DIR42', 'Direction Generale')
ON CONFLICT (id) DO NOTHING;

-- create admin user and mark active
INSERT INTO utilisateur (
    refuser, loginuser, pwduser, nomuser,
    adruser, teluser, idrole, estactif
) VALUES
    (1, 'admin', 'paop', 'admin', 'DIR42', '1002067', 'dg', 1)
ON CONFLICT (refuser) DO UPDATE
  SET loginuser = EXCLUDED.loginuser,
      pwduser    = EXCLUDED.pwduser,
      nomuser    = EXCLUDED.nomuser,
      adruser    = EXCLUDED.adruser,
      teluser    = EXCLUDED.teluser,
      idrole     = EXCLUDED.idrole,
      estactif   = EXCLUDED.estactif;

INSERT INTO paramcrypt(id, niveau, croissante, idutilisateur)
VALUES (
    'CRY000088',
    4,
    1,
    '1'
)
ON CONFLICT (id) DO UPDATE
  SET niveau = 0, croissante = 1;

