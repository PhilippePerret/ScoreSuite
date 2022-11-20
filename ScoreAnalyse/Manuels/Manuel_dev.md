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



## Groupement des tags

Depuis la version de novembre 2022, on peut grouper les tags, ce qui permet notamment de les déplacer ou de les supprimer ensemble.

QUESTION : comment les tags sont-ils groupés.

C’est une propriété ‘grp’ qui signifie “groupe” qui liste tous les tags associés

Pour le moment, je considère que cette liste doit contenir tous les ID de tags, même celui qui possède la propriété. Cela permet d’actualiser les listes très facilement, sans avoir à enlever l’ID du tag 

Par exemple :

~~~javascript
T1 et T5 sont associés :
T1.grp = [1, 5]
T5.grp = [1, 5]
~~~

Les méthodes à créer

~~~javascript
groupWith(tag) // regroupe (attention 

degroupFrom(tag) // dégroupe

isGrouped // => true si le tag est associé

isGroupedWith(tag) // => true si associé au tag +tag+
~~~



