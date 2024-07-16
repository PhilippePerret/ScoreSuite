# Aide Score Builder

## Introduction

### Description

**Score-builder** est une application web qui permet de produire très rapidement, de façon assistée, des partitions de musique avec l’aide de Lilypond.

Alors que **Score-writer** permet de construire la partition par mesure (sans variable), ***Score-builder*** permet de le faire avec des variables, des librairies (comme la librairie des basse d’Alberti) et d’avoir un espace de travail opérationnel.

***Score-builder*** a été spécialement designé pour produire les « Recueils (de partitions) sur mesure » pour les éditions Icare. Pour produire, à partir d’une partition originale, une partition propre aux éditions.

### Présentation

***Score-builder*** se présente comme un écran large divisé en trois tiers horizontalement :

* à gauche on peut afficher la partition originale, de référence, à reproduire.
* au centre le formulaire de code,
* à droite le résultat obtenu (images SVG.

### Routine d’utilisation

* Ouvrir un Terminal dans un dossier contenant les éléments d’une partition (par exemple le PDF de la partition originale, mais en fait, le dossier peut être vide).
* Lancer la commande **`score-builder`**.
* Si nécessaire (si le dossier est vide par exemple), la commande peut demander de construire un fichier **`.mus`**. Dans tous les cas, il ouvre l’éditeur ***Score-Builder***.
* On écrit le code dans le champ de code, la partie centrale de l’interface utilisateur.
* On presse **`⌘ s`** pour enregistrer le code et produire l’image de la partition, qui apparait à droite de l’interface.

## Procédure pour commencer à construire une partition

La première chose à faire est de récupérer **la partition originale** en ligne, par exemple sur le site de l’[IMSLP](https://imslp.org/wiki/Main_Page).

On met cette partition dans un dossier de pièce (pour les *recueils de partitions sur mesure*, on crée un dossier automatiquement à partir de la création d’une pièce avec la commande **`rspm create piece`**.

Si cette partition originale est en PDF, on peut ouvrir un Terminal au dossier de la pièce est lancer **`score-builder`**. Cela produira : 

* l’extraction de chaque page de la partition en JPEG,
* la création d’un fichier **`build_code.mus`** pour mettre le code mus de la partition



## Production des images SVG

En cliquant sur le bouton « Build & Save » — où en jouant **`⌘s`** dans le champ de code —, on produit les images SVG de la partition et l’on enregistre le code MUS (avec les options) dans le fichier mus du dossier.

### En cas d’erreur

Parfois, une erreur non documentée est produite lors de la construction. Pour en découvrir l’origine, en l’absence de message d’erreur clair, on a plusieurs moyens.

* Lancer la commande **`score-image -d`** directement dans le dossier de la pièce. Le `-d` permet de débugger l’application.
* Ajouter l’option **`--keep`** pour conserver les fichiers Lilypond provisoires (`.ly`), puis les jouer en ouvrant un Terminal au dossier des images SVG et en jouant **`lilypond <nom fichier>`** .

Si aucune de ces techniques ne porte ses fruits, il est possible de retirer petit à petit du code du fichier d’origine pour en tester seulement des bouts. Dans ce cas, le [bloc-notes](#blocnotes) est particulièrement utile, qu’on peut ouvrir en cliquant le bouton « Bloc-note ».

---

<a name="blocnotes"></a>

## Bloc-notes

Le bloc-notes permet de prendre des notes et/ou de copier des éléments de code.

### Enregistrement et fermeture

Pour enregistrer le bloc-notes et fermer la fenêtre en même temps, il suffit de tenir la touche ⌘ appuyée en cliquant sur le bouton d’enregistrement.

### Déplacement des notes

On peut déplacer les notes avec les boutons ⌘ + ◀️ et ⌘ + ▶️ qui permettent de choisir les autres notes.

---

<a name="outils"></a>

## Outils

Le bouton « Outils » permet d’afficher le panneau des outils.

Ces outils permettent notamment de :

* initier le module ruby qui permet de produire des partitions ou des portions de partitions de façon programmatique lorsque c’est possible (particulièrement utile avec du Bach où un système se répète souvent d’un bout à l’autre des pièces — voir les préludes).
