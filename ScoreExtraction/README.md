# Score Extraction

Application pour pouvoir extraire n'importe quel segment musical d'une partition en fournissant le numéro de première et de dernière mesure.

Utilisation :

* produire le fichier `data_mesure.rb` contenant `DATA_MESURES`, les données de chaque mesure (on peut [produire ce code avec MusicScoreWriter](#produce-data-with-musicscorewriter)),
* ouvrir un Terminal au dossier contenant ce fichier,
* jouer l'alias `score-extrait` (il doit avoir été défini dans `~/.zshrc`) avec en premier argument le numéro de première mesure, en seconde argument le numéro de dernière mesure (comprise) puis [les options](#options) voulues
* l'image est produite dans le même dossier, avec le préfixe défini ou par défaut ('score_extrait') suivi des numéros de mesure sous la forme "mmX-Z" pour "de la mesure X à la mesure Z".


<a name="options"></a>

## Options

On peut ajouter ces options à la ligne de commande pour affiner la production de l'extrait.

-m/--mesure   Pour indiquer le numéro de première mesure de l'extrait


<a name="produce-data-with-musicscorewriter"></a>

## Produire la donnée des mesures avec MusicScoreWriter

* lancer l'application,
* choisir « Note en hauteur absolue (\fixed c') » dans les options,
* écrire le code de la partition (en hauteur absolue, le do de base étant sous la portée pour la clé de SOL et dans la portée pour la clé de FA),
* dans le panneau OUTILS, choisir le format de sortie « Table de données des mesures »,
* produire le code,
* copier le code est de coller dans un fichier `data_mesures.rb`, dans un dossier spécialement prévu pour ça (par exemple `score`),
* utiliser l'application courante pour tirer des extraits de la partition.
