# Score-Writer Manuel

## Présentation

**Score-writer** permet de produire rapidement des partitions (ou segments de partitions), à l’aide d’un code pseud-LiLypond interprété en direct, qui permet donc de visualiser immédiatement ce que l’on produit comme image.

## Utilisation

### Utilisation basique

* Ouvrir un Terminal à un dossier quelconque où l’on veut produire l’image,
* jouer la commande `score-writer mon_image`,
* si `mon_image.mus` existe dans le dossier courant, elle est chargé comme image courante. Sinon, c’est une nouvelle image qui est produite.

### Création d’une nouvelle image

* Ouvrir un Terminal dans le dossier où l’image doit être créée,
* jouer la commande `score-write <nom_de_mon_image>`
* régler la configuration de l’image (portées, métrique, tonalité, disposition de l’interface, etc.),
* produire le code pseudo-lily,
* cliquer sur le bouton “Build” pour produire l’image et l’enregistrer.

## L'interface

### Réglage de l'interface

On peut régler l'interface pour que les éléments (image de la partition et code) soient placés aux endroits voulus.

* ouvrir le panneau `Options`,
* dans le menu “Disposition lignes code / image partition”, choisir la disposition voulue.
* => Elle s'applique automatiquement.


## Portée

### Nombre et disposition des portées

Par défaut, l'interface présente 2 portées (version `Piano`). Mais on peut définir des systèmes d'autant de mesures que l'on veut. Pour ce faire, procéder ainsi :

* ouvrir le panneau `Options`,
* choisir le système voulu (si le système n'existe pas, choisir “Autre…” et indiquer le nombre de portées voulues)
* on peut [procéder à leur réglage](#reglage_portees) tout de suite si on le désire,
* ouvrir le panneau `Outils`,
* cliquer sur le bouton “Tout effacer” pour repartir d'une disposition vierge.

> Noter qu'il faut explicitement tout effacer pour prendre en compte la nouvelle disposition, afin que les erreurs de suppression de code (en supprimant des portées) ne surviennent.

<a name="reglage_portees"></a>

### Réglage des portées

On peut régler les portées (leur nom, leur clé, etc.) dans le panneau `Options`.

* Ouvrir le panneau `Options`,
* sur la première ligne, choisir le système voulu (certains sont prédéfinis),
* => en fonction du choix, des définitions de portées se construisent,
* régler les valeurs pour quelles soient définies dans le code,
* demander la production du code pour voir le résultat.

## Notes

### Hauteur relative

Par défaut, l’écriture des notes se fait en position relative. Cf. ci-dessous pour passer en version fixe.

### Hauteur absolue

Pour passer en hauteur des notes absolue :

* ouvrir l’onglet OPTIONS,
* cocher la case “Hauteur des notes en valeur absolue (fixed)”

> Note : le mode `fixed` est indispensable si l’on doit faire une sortie sous forme de [donnée pour extraction](#data-for-extraction).



## Sortie du code

<a name="data-for-extraction"></a>

### Données pour extraction

C’est un format de sortie qui permet ensuite d’extraire des mesures du code. C’est la sortie idéale pour une partition complète étudiée, afin de sortir ensuite des extraits les plus divers à l’aide de la commande `score-extract` (programme **ScoreExtraction**).

* ouvrir l’onglet OUTILS,
* choisir le format “Table des données des mesures”
