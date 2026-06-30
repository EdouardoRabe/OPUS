# Architecture Technique OPUS

## Vue d'ensemble

Le projet est decoupe en deux modules principaux :

- `opus-war` : interface web (JSP), endpoints AJAX JSP, servlets utilitaires.
- `opus-ejb` : logique metier et acces donnees via classes metier/services.

Build/deploiement principal : `build.xml` racine (Ant) qui compile EJB puis WAR, puis copie dans WildFly.

## Flux d'execution standard

1. L'utilisateur charge une page via `module.jsp?but=...`.
2. La page front appelle un endpoint AJAX JSP dans `opus-war/web/pages/**/ajax/`.
3. L'endpoint appelle une methode de service `alumni.*Service`.
4. Le service manipule les classes metier `alumni.*` mappees sur les tables SQL.
5. Le resultat est renvoye en JSON/HTML puis injecte dans l'UI.

## Emplacements importants

| Element | Chemin |
|---------|--------|
| UI principale | `opus-war/web/pages/` |
| Endpoints AJAX | `opus-war/web/pages/*/ajax/` |
| Servlets utilitaires | `opus-war/src/java/servlet/`, `opus-war/src/java/web/` |
| Controle d'acces | `opus-war/src/java/user/Restriction.java`, `RestrictionServlet.java` |
| Connexion / Login | `opus-war/src/java/user/Visa.java` |
| Services metier | `opus-ejb/src/java/alumni/*Service.java` |
| Entites metier (mapping table) | `opus-ejb/src/java/alumni/*.java` |
| EJB facade session | `opus-ejb/src/java/user/UserEJBBean.java` (stocke en session HTTP comme `"u"`) |
| WebSocket notifications | `opus-ejb/src/java/web/socket/NotificationSocket.java` (`/ws/notifications`) |
| Scripts SQL | `BDD/` |

## Framework APJ — Conventions

### Entite (ClassMAPTable)

Chaque table est mappee a une classe Java qui etend `ClassMAPTable` :

```java
public class Profil extends ClassMAPTable {
    public Profil() { setNomTable("profil"); }
    public String getTuppleID() { return idprofil; }
    public String getAttributIDName() { return "idprofil"; }
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PRF", "get_seq_profil");
        this.setIdprofil(makePK(c));
    }
}
```

### Requete (CGenUtil)

```java
// Avec connexion existante (prefere dans les services)
Profil[] results = (Profil[]) CGenUtil.rechercher(filtre, null, null, conn, " and idutilisateur = 1");

// Sans connexion (le framework ouvre/ferme)
Typepublication[] types = (Typepublication[]) CGenUtil.rechercher(new Typepublication(), null, null, " order by idtypepublication");
```

### Navigation

- URL : `module.jsp?but=mon-module/ma-page.jsp`
- Formulaires simples POST vers `apresTarif.jsp`
- Formulaires maitre-detail POST vers `apresMultiple.jsp` / `apresInsertMultiple.jsp`

### Workflow (ClassEtat)

Etats : Cree(1) → Valide(11) → Fait(10) → Cloture(9) / Annule(0)

## Build et deploiement

Cibles Ant dans `build.xml` :

| Cible | Action |
|-------|--------|
| `clean` | Supprime les artefacts de build |
| `init` | Prepare l'arborescence |
| `compile` | Compile l'EJB |
| `buildEjbJar` | Package l'EJB en JAR |
| `compileWar` | Compile le WAR |
| `copieProperties` | Copie les fichiers `.properties` |
| `deploy` | Copie dans `deploy.dir` WildFly et declenche le deploiement |

Commandes utiles :

```bash
ant deploy        # build complet + deploiement
ant buildEjbJar   # compile EJB seulement (verification rapide d'erreurs Java)
ant clean         # nettoie les artefacts
```

## Raccourcis de comprehension

- Modifier un comportement metier → commencer par `alumni.*Service`.
- Modifier l'affichage → commencer par JSP dans `opus-war/web/pages/`.
- Modifier les donnees persistees → verifier classe `alumni.*` + script SQL dans `BDD/`.
