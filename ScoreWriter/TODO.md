# TODO list

cf. `ghi list -L writer`

* reprise complète de l'implémentation, pour supprimer les bugs. Cf. ci-dessous.


## REPRISE IMPLÉMENTATION

Pour fonctionner, l'application s'appuie en premier lieu sur :

* la configuration de l'extrait (tonalité, portées, métrique, etc.)
* les notes définies dans l'interface

### Déjà à régler 

* ne pas tout mélanger : 
  - la disposition de l'application n'a rien à faire dans la configuration de la pièce
  - le format de la page
  => Faire une propriété qui ne concerne que la musique
    - tonalité
    - métrique
    - systèmes (portée — nombre, clé et nom)
  => Faire une propriété qui concerne le traitement par lilypond
    - la proximité
    - la dimension de page
    - l'affichage des barres ou non
    - l'affichage des hampes ou non
    - espacement vertical entre portées
    - notes en valeurs absolues
  => Faire une propriété qui concerne le comportement de l'application
    - auto actualisation après changement
    - disposition (position du code par rapport à l'image)
