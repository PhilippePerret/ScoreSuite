# Score-image Todo List

* Création test : expliquer quoi faire après la création
* Test : pouvoir faire un négatif (un fichier "NEGATIF" dans le dossier des tests contenant les éléments qu’on doit trouver dans le message d’erreur)
* Test : une option "fail-fast"

Travailler les erreurs "négatives", c’est-à-dire un test qui doit échouer. Il faudrait un fichier qui concerne le numéro de l’erreur et checke le message d’erreur produit.

## Essai d’une gestion plus intelligente des groupes dans les portées définies par nom et clé :

Avec un class ’NamedStaves’ dont on appelle la méthode de classe `::parse` dès que l’option ’--staves_names’ est rencontrée.

Les cas pouvant se produire :

* aucune définition de groupe
* une définition de groupe général (crochet et accolade seulement au début et à la fin)
* définition de sous-groupe (sans groupe général)
* définition de sous-groupes et de groupe général

On met dans `options[:staves_data]` l’instance ’NamedStaves’ qui sera produite par `NamedStaves::parse`
