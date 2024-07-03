# Todo

* Construction des champs pour les systèmes complexes

* De façon générale, améliorer les retours d’erreur dès qu’il y a un problème (cf. ci-dessous)
* un bloc-note pour prendre des notes
* Pouvoir rouvrir le dernier fichier en faisant `score-builder last`

## Retour d’erreur

De façon générale, il faut être plus strict avec les retours d’erreur, pour ne pas perdre de temps à trouver une erreur.

Pour commencer, pouvoir lancer la commande comme je le fais pour voir où ça ne fonctionne pas, en deux degrés :
1) lancer `score-image fichier.mus` peut-être dans un thread
2) pouvoir ajouter l’option "keep" et jouer `lilypond fichier.ly` dans un thread et récupérer l’erreur.
