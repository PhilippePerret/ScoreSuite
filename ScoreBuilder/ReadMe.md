# Score Builder

Application de la suite *Score* qui permet de construire une partition complète (ou pas…) en code mus, en se basant sur une partition PDF ou JPEG, de façon assistée.

## Utilisation

> Pour une première utilisation, voir la section [Première utilisation](#premiere-utilisation)

* Ouvrir un Terminal dans un dossier contenant un fichier `score_builder.yaml`
* jouer la commande `score-builder`

Ou :

* Ouvrir une fenêtre de Terminal (n’importe où)
* jouer la commande `score-builder path/to/folder`

où `path/to/folder` est le chemin d’accès vers un dossier contenant un fichier de données `score_builder.yaml`.

---

## Présentation

L’application, qu’on doit utiliser sur un écran assez large, se présente sous la forme d’une page HTML découpée en trois parties horizontales (ou deux parties horizontales et deux verticales), avec :

* à gauche la partition originale de référence,
* au centre le formulaire pour entrer le code `mus`,
* à droite le résultat du code (qu’on peut aussi faire apparaitre dans une autre fenêtre si on travaille en multi-écran)

---

<a name="premiere-utilisation"></a>

## Première utilisation

* Ouvrir un Terminal au dossier où doit se construire la partition. Ce dossier doit contenir :
  * soit un fichier PDF de la partition originale (numérotée)
  * soit des fichiers JPEG de chaque page, indexés (par exemple `score-1.jpg`, `score-2.jpg`, etc.)
* Jouer la commande `score-builder .` et répondre aux questions demandées.
