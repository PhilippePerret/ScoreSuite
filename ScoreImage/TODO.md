# Score-image Todo List

* Ajouter l’option "séparateur de systèmes" et l’implémenter


### Sorties midi

(pour contrôler, mais vraiment pour jouer)


### Fichier MIDI 

* pouvoir définir le tempo en ligne de commande (c’est déjà le cas, donc le prendre en compte)

### TESTS À FAIRE

* pas de numérotation de mesure
* numérotation tous les 5
* numérotation en dessous de la portée
* test sur marque d’octave
  - simple note
  - simple note en dessous
  - accord
  - accord en dessous

### Retour Lilypond

Plutôt que d’utiliser `2>&1` en lançant Lilypond, il faudrait utiliser `Open3.capture3` pour récupérer précisément le message d’erreur. Attention, ça changement pas mal de choses dans le code et notamment au niveau de `MusicScore::Output#build_svg_files` et `MusicScore::Output#build`.

### Calcul de la transposition

Elle est exprimée par "<note1> <note2>" avec les deux notes qui peuvent contenir des octaves et des altérations.

Je voudrais obtenir le nombre de demi-tons. Non, parce qu’une transposition de "c cis" ne doit pas donner les mêmes notes que "c des". Dans le premier cas, la note garde son nom et on la monte d’un demi-ton, dans l’autre, on prend le degré suivant.

1. épurer pour connaitre la note de départ et la note de fin :
tout, snote, alter, octave = note.match(REG_NOTE_TRANSPO).to_a
