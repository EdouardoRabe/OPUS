-- ═══════════════════════════════════════════════════════════════
-- Création des tables pour gestion des réseaux sociaux
-- Date: 2026-02-24
-- ═══════════════════════════════════════════════════════════════

-- ── TABLE: reseauxsociaux ──
-- Stocke les types de réseaux sociaux disponibles
CREATE TABLE IF NOT EXISTS reseauxsociaux (
    idreseausocial VARCHAR(20) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE,
    urlpattern VARCHAR(255),
    iconeclass VARCHAR(50),
    couleurhex VARCHAR(7),
    priorite INT DEFAULT 0,
    actif INT DEFAULT 1
);

-- ── TABLE: profilsocialmedia ──
-- Lie les profils aux leurs comptes sur les réseaux sociaux
CREATE TABLE IF NOT EXISTS profilsocialmedia (
    idprofilsocial VARCHAR(50) PRIMARY KEY,
    idprofil VARCHAR(20) NOT NULL,
    idreseausocial VARCHAR(20) NOT NULL,
    valeur VARCHAR(255) NOT NULL,
    datycreation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datymodification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idprofil) REFERENCES profil(idprofil) ON DELETE CASCADE,
    FOREIGN KEY (idreseausocial) REFERENCES reseauxsociaux(idreseausocial) ON DELETE CASCADE,
    UNIQUE(idprofil, idreseausocial)
);

-- ───────────────────────────────────────────────────────────────
-- INSERTION DES RÉSEAUX SOCIAUX POPULAIRES
-- ───────────────────────────────────────────────────────────────

INSERT INTO reseauxsociaux (idreseausocial, libelle, urlpattern, iconeclass, couleurhex, priorite) VALUES
-- Professionnels
('linkedin', 'LinkedIn', 'https://linkedin.com/in/{value}', 'fab fa-linkedin', '#0A66C2', 100),
('github', 'GitHub', 'https://github.com/{value}', 'fab fa-github', '#181717', 95),
('gitlab', 'GitLab', 'https://gitlab.com/{value}', 'fab fa-gitlab', '#FC6D26', 90),
('bitbucket', 'Bitbucket', 'https://bitbucket.org/{value}', 'fab fa-bitbucket', '#0052CC', 85),
('stackoverflow', 'Stack Overflow', 'https://stackoverflow.com/users/{value}', 'fab fa-stack-overflow', '#F48024', 80),
('codepen', 'CodePen', 'https://codepen.io/{value}', 'fab fa-codepen', '#000000', 75),
('behance', 'Behance', 'https://behance.net/{value}', 'fab fa-behance', '#1769FF', 70),

-- Réseaux sociaux généraux
('twitter', 'Twitter', 'https://twitter.com/{value}', 'fab fa-twitter', '#1DA1F2', 90),
('facebook', 'Facebook', 'https://facebook.com/{value}', 'fab fa-facebook', '#1877F2', 85),
('instagram', 'Instagram', 'https://instagram.com/{value}', 'fab fa-instagram', '#E4405F', 88),
('tiktok', 'TikTok', 'https://tiktok.com/@{value}', 'fab fa-tiktok', '#000000', 75),
('youtube', 'YouTube', 'https://youtube.com/@{value}', 'fab fa-youtube', '#FF0000', 80),
('discord', 'Discord', 'https://discord.com/users/{value}', 'fab fa-discord', '#5865F2', 70),

-- Portfolio & Dev
('portfolio', 'Portfolio', '{value}', 'fas fa-globe', '#3B82F6', 65),
('website', 'Site Web', '{value}', 'fas fa-link', '#666666', 60),
('devto', 'Dev.to', 'https://dev.to/{value}', 'fab fa-dev', '#0A0E27', 65),
('medium', 'Medium', 'https://medium.com/@{value}', 'fab fa-medium', '#000000', 60),
('hashnode', 'Hashnode', 'https://hashnode.com/@{value}', 'fas fa-h', '#2962FF', 62),
('substack', 'Substack', 'https://substack.com/@{value}', 'fas fa-envelope', '#FF6600', 58),

-- Autres réseaux
('whatsapp', 'WhatsApp', 'https://wa.me/{value}', 'fab fa-whatsapp', '#25D366', 50),
('telegram', 'Telegram', 'https://t.me/{value}', 'fab fa-telegram', '#0088cc', 50),
('skype', 'Skype', 'https://join.skype.com/{value}', 'fab fa-skype', '#00AFF0', 45),
('email', 'Email', 'mailto:{value}', 'fas fa-envelope', '#EA4335', 55),
('phone', 'Téléphone', 'tel:{value}', 'fas fa-phone', '#34C759', 40)
ON CONFLICT (idreseausocial) DO NOTHING;

-- ───────────────────────────────────────────────────────────────
-- INDEX POUR AMÉLIORER LES PERFORMANCES
-- ───────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idxprofilsocialmediaidprofil 
    ON profilsocialmedia(idprofil);

CREATE INDEX IF NOT EXISTS idxprofilsocialmediareseau 
    ON profilsocialmedia(idreseausocial);

CREATE INDEX IF NOT EXISTS idxreseauxsociauxactif 
    ON reseauxsociaux(actif, priorite DESC);

-- ───────────────────────────────────────────────────────────────
-- LOGS
-- ───────────────────────────────────────────────────────────────

-- Tables créées:
-- - reseauxsociaux: 24 types de réseaux sociaux avec logo, couleur, priorité
-- - profilsocialmedia: liaison profil ↔ réseaux sociaux (UN compte par réseau par profil)
-- Indexes créés pour optimiser les recherches par idprofil et idreseausocial
