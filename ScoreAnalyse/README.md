# TABLE D'ANALYSE

## Présentation 

Application statique permettant de procéder à une analyse musicale de façon très souple et de l'imprimer.

## Procédure

* Découper la partition en système
* donner les systèmes à la table d'analyse (dans son dossier `./systemes`)
* charger l'application en ouvrant le fichier dans Chrome (permet de gérer les sons),
* => les systèmes se construisent,
* faire un tour dans les préférences (`⇧P`) pour jeter un œil aux valeurs par défaut,
* modifier les valeurs par défaut si nécessaire,
* commencer à analyser en double-cliquant aux endroits voulus,
* ouvrir le manuel (`⇧M`) pour en savoir un peu plus.

## Découpage de la partition

Pour utiliser la puissance de la table d'analyse, il faut découper la partition de référence en systèmes indépendants. Pour le faire de façon très rapide et précise, utiliser mon application `StavesCutting`.

## Statique ? Vraiment ?

Bien que statique (only HTML, CSS et JS), elle permet d'enregistrer des préférences, des analyses, en se servant de stockage local (`localStorage`).
