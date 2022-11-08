# Table d'analyse

# Manuel de développement

## Analyse

Une analyse est consigné dans un dossier quelconque n'importe où sur tout support.

Ce dossier contient :

* un fichier YAML d'identité, contenant les données générales de l'application
* un fichier YAML des préférences, définissant notamment la position des systèmes,
* un fichier YAML des marques d'analyse
* un dossier contenant les images des systèmes (qui doivent tous être séparés)
* un dossier 'assets' qui servira plus tard si l'on veut développer l'application plus loin.

### Fichier d'identité

Le fichier d'identité porte le nom `analyse_id.yaml`. Il définit :

* `id`. Identifiant de l'application (attention : l'unicité n'est pas vérifiée),
* `analyse_title`. Titre générale de l'analyse (pas de l'œuvre),
* `piece_title`. Titre de l'œuvre analysée,
* `piece_composer`. Compositeur, sous forme "NOM, Prénom"
* `analyst`. Patronyme de l'analyste "NOM, Prénom"

### Fichier préférences

Le fichier des préférences porte le nom `preferences.yaml`. Il définit :

* `systems_positions`. Position de chaque système (1 image = 1 système)
* `auto_save`. Pour l'auto-sauvegarde.

### Fichier des marques d'analyse

Ce fichier contient toutes les marques d'analyse à poser sur la table d'analyse.
