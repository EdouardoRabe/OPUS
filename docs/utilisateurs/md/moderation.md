# Moderation des Publications

## Modifier ou supprimer sa propre publication

Comme tout utilisateur, le moderateur peut modifier ou supprimer ses propres publications depuis leur fiche.

## Supprimer la publication d'un autre utilisateur

Cette action est reservee au moderateur et se fait uniquement depuis la page de detail d'un signalement :

1. Aller dans Moderation > Signalements.
2. Cliquer sur "Voir le detail" sur le signalement concerne.
3. La publication signalee est affichee. Si elle existe encore, un bouton "Supprimer la publication" est disponible.
4. Confirmer la suppression. La publication disparait du feed pour tous les membres.

> La suppression est un soft delete (etat = 0 en base). La publication n'est plus visible mais les donnees restent.

## Flux typique de traitement d'un signalement

1. Un membre signale une publication inappropriee (bouton de signalement dans le feed).
2. Le signalement apparait dans Moderation > Signalements.
3. Le moderateur consulte le detail et visualise la publication.
4. Si la publication est effectivement inappropriee, le moderateur la supprime.
5. Si necessaire, le moderateur peut aussi bannir l'auteur depuis Moderation > Utilisateurs.
