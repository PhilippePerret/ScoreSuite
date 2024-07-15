# Score-image Todo List

* Ajouter l’option "séparateur de systèmes" et l’implémenter

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
