# Tutoriel Score-Analyse

Ce tutoriel présente le procédure complète d’une analyse avec la suite **ScoreSuite** et principalement **ScoreAnalyse** qui en est la pièce centrale.

## Procédure complète

---

Voyons comment produire l’analyse d’une pièce de musique que nous avons en partition (récupérée par exemple sur le site de l’[ISMLP](https://imslp.org). Pour l’exemple, ce sera le premier prélude du clavier bien tempéré de Jean-Sébastien Bach.

<a name="dossier-analyse"></a>

### Dossier de l’analyse

La première chose à faire est de créer un dossier dans lequel seront placés tous les éléments de notre analyse. J’appelle ce dossier **`Analyse_CBT1_p1`** (“CBT1” signifie “premier clavier bien tempéré” et “p1” signifie “Premier prélude”).

Je place dans un dossier **`Divers`** de ce dossier la partition récupérée en PDF sur le site de l’[ISMLP](https://imslp.org). Je la renomme **`Partition_originale.pdf`** (mais cela n’a pas d’importance pour la suite, si ce n’est pour en parler plus simplement).

> Je placerai dans ce dossier tous les fichiers qui ne seront pas vraiment utiles à l’analyse.

### Séparation des pages en images

Pour pouvoir manipuler la partition, je vais devoir séparer le fichier PDF (noter qu’il contient tout le cahier, dans la version que j’ai téléchargée) en plusieurs fichier image au format `JPEG`. Pour ce faire, j’ouvre la partition dans l’application **Aperçu** (**Preview** en anglais), je sélectionne la première page, je l’exporte en JPG dan mon dossier `Divers`, avec pour nom **`page1.jpg`** et une qualité maximale. Je fais la même chose pour la seconde page avec le nom **`page2.jpg`**.

Je me retrouve donc à présent avec cette hiérarchie d’éléments :

~~~bash
Analyse_CBT1_p1 | 
								| Divers  |
													| Partition_originale.pdf
													| page1.jpg
													| page2.jpg
~~~

<a name="decoupe-systems"></a>

### Découpage des pages de la partition en systèmes

Pour pouvoir analyser confortablement la partition, nous devons écarter les systèmes afin de laisser assez de place pour mettre toutes les marques d’analyse. Dans ce but, nous devons découper la partition en systèmes.

Pour découper les pages `jpeg` de la partition en systèmes, nous utilisons **`ScoreCutting`**.

Je commence par place l’image `page1.jpg` à la racine du dossier principal `Analyse_CBT1_p1` (je laisse l’autre page à sa place).

Je controle-clique sur le dossier `Analyse_CBT1_p1` et j’ouvre un nouveau Terminal à ce dossier. Et je joue la commande :

<command>score-cutting</command>

Cela ouvre la première page dans Score-cutting. 

Il suffit maintenant de double-cliquer aux endroits où il faut faire la découpe, c’est-à-dire le plus près du haut et du bas de chaque système.

> Attention, il faut absolument 2 lignes de coupe par système.

Je confirme la découpe si elle convient et je demande d’y procéder avec le bouton `Procéder à la découpe`.

Cela produit un dossier **`systems`** dans le dossier racine de l’analyse dans lequel sont rangés tous les systèmes de la première page.

Je remets le fichier `page1.jpg` dans le dossier `Divers` et je place le fichier `page2.jpg` (la deuxième page) dans le dossier principal. 

Je demande le rechargement de **ScoreCutting**, qui va prendre en compte, maintenant, la deuxième page de la partition.

**ATTENTION** : Commencer par bien régler le champ « N° premier système », en bas de l’interface, avec le numéro de système suivant. Si le dernier système de la première page portait le numéro **6** (ce qu’on peut voir dans le dossier `systems` alors il faut mettre **7** ici, pour que le premier système de la page 2 soit le système 7.

Comme pour la première page, placer les doubles lignes de découpe et procéder au découpage.

Si vous avez procédé correctement à l’opération, vous devez vous retrouver avec **12 systèmes** dans le dossier `systems`.

Replacer le fichier `page2.jpg` dans le dossier `Divers`, nous ne devrions plus en avoir besoin.

### Mise en place de l’analyse

Nous allons bientôt pouvoir procéder au début de l’analyse. Dans la fenêtre de Terminal que nous avons ouvert, tapons la commande :

<command>score-analyse analyse</command>

L’application nous demande si nous voulons créer une nouvelle analyse dans ce dossier. Nous confirmons que lui.

L’application réclame alors quelques informations sur la pièce et l’analyse.

L’application détecte le dossier `systems` et nous demande s’il contient les systèmes de la partition. Nous confirmons que oui.

**ScoreAnalyse** procède alors à la création de l’analyse, ce qui produit la hiérarchie suivante :

~~~bash
Analyse_CBT1_p1 | 
								| analyse | infos.yaml
								|					| preferences.yaml
								|					| systems | (les systèmes)
								|
								| Divers  |
								|		 	  	| Partition_originale.pdf
								|	 	  		| page1.jpg
								| 				| page2.jpg
								| systems | system-01.jpg
													| system-02.jpg
													| etc.
~~~





---

<a name="table-analyse"></a>

## La table d’analyse

---

<a name="gestion-images"></a>

## Gestion des images et autres extraits de partition

### Extrait de partition simple

J’ai besoin d’un extrait assez simple de partition, sur une seule portée, avec quelques notes. Plutôt que de changer de logiciel, je vais utiliser l’outil de fabrication rapide d’image, dans la boite à outils de l’application.

Pour ouvrir la boite à outils, je peux choisir le menu `Fichier > Boite à outils…` ou activer le raccourci `⌘O`.

En haut de la boite à outils, je trouve un champ (fond noir) dans lequel je vais pouvoir taper du pseudo code Lilypond (Lilypond simplifié) que j’appelle `code MusicScore`. Ce code permet de produire des images très simplement. Je peux produire mon premier extrait simplement en copiant le code suivant dans le champ et en cliquant sur le bouton `Construire`.

~~~bash
-> segment1
c d e f
~~~

La procédure précédente va produire l’image `segment1.svg` dans le dossier `images`de l’analyse et mettre ce nom dans le presse-papier.

Il me reste juste, alors, à double-cliquer sur la [table d’analyse][] à l’endroit voulu, de choisir le type `Image` dans le menu des types qui s’affiche, et de coller le nom de l’image.

Aussitôt, l’image s’insère dans mon analyse !

### Partition plus complexe

J’ai besoin de développer une partition plus complexe, que je serais en peine de développer dans le champ de la boite d’outil. Pour ça, je vais utilise **ScoreWriter** qui offre une interface pratique pour produire des images de partition assez complexes.



[table d’analyse]: #table-analyse
