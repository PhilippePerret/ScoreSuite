# Aide Score Builder

## Description

**Score-builder** est une application web qui permet de produire très rapidement, de façon assistée, des partitions de musique avec l’aide de Lilypond.

Alors que **Score-writer** permet de construire la partition par mesure (sans variable), ***Score-builder*** permet de le faire avec des variables, des librairies (comme la librairie des basse d’Alberti) et d’avoir un espace de travail opérationnel.

***Score-builder*** a été spécialement designé pour produire les « Recueils (de partitions) sur mesure » pour les éditions Icare. Pour produire, à partir d’une partition originale, une partition propre aux éditions.

## Présentation

***Score-builder*** se présente comme un écran large divisé en trois tiers horizontalement :

* à gauche on peut afficher la partition originale, de référence, à reproduire.
* au centre le formulaire de code,
* à droite le résultat obtenu (images SVG.



## Procédure de démarrage

La première chose à faire est de récupérer **la partition originale** en ligne, par exemple sur le site de l’[IMSLP](https://imslp.org/wiki/Main_Page).

On met cette partition dans un dossier de pièce (pour les *recueils de partitions sur mesure*, on crée un dossier automatiquement à partir de la création d’une pièce avec la commande **`rspm create piece`**.

Si cette partition originale est en PDF, on peut ouvrir un Terminal au dossier de la pièce est lancer **`score-builder`**. Cela produira : 

* l’extraction de chaque page de la partition en JPEG,
* la création d’un fichier **`build_code.mus`** pour mettre le code mus de la partition
