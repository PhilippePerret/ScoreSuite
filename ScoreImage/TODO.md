# Score-image Todo List

* Ajouter l’option "séparateur de systèmes" et l’implémenter

## BUGS

### Transposition

Revoir complètement le système de transposition, qui ne fonctionne pas :

* au niveau de l’armure à utiliser
* au niveau des notes

Tests = dossier `transpose`

Quelle formule utiliser pour la transposition ?
Cas d’un instrument en Bb
- quand la note Do est marquée, c’est Sib qui est joué
=> il sonne une seconde majeure en dessous
=> il faut marquer la note qu’on veut une seconde majeur au-dessus
=> pour obtenir un Do, on doit jouer/marquer un Ré
=> La tonalité de Do devient tonalité de Ré (2#)

Cas d’un instrument en A
- quand la note Do est marquée, c’est un A qui est joué
=> il sonne une tierce mineure en dessous
=> il faut marquer la note qu’on veut une tierce mineure au-dessus
=> pour obtenir un Do, on doit marquer un Mib
=> La tonalité de Do devient la tonalité de Mib (3b)

Formule

Différence avec Do :
diff_with_c = 

# Différences avec Do
# [nombre de demitons, nombre de degrés]
DIFFS_WITH_C = {
  c => [0, 0], cis => [1, 0], des => [1, 1], 
  d => [2, 1],
  dis => [3, 1], ees => [3, 2],
  e => [4, 2], fes => [4, 3],
  f => [5, 3],
  fis => [6, 3], ges => [6, 4],
  g => [7, 4],
  gis => [8, 4], aes => [8, 5],
  a => [9, 5], 
  ais => [10, 5], bes => [10,6],
  b => [11, 6], ces => [11, 0]
}
NOTES_FROM_C = {
  # se lit : à <nombre de 1/2 tons de Do> => { <à x degrés> => <note réelle> }
  0 => {0 => c, -1 => bis},
  1 => {0 => cis, 1 => des},
  2 => {1 => d},
  3 => {1 => dis, 2 => ees},
  4 => {2 => e, 3 => fes},
  5 => {3 => f},
  6 => {3 => fis, 4 => ges},
  7 => {4 => g},
  8 => {4 => gis, 5 => aes},
  etc.
}
# noter que DIFFS_WITH_C peut découler de NOTES_FROM_C (et inversement)
ecart_pos = 12 - diff_with_c[0]
ecart_deg = 7 - diff_with_c[1]
# p.e. pour La : 
# ecart_pos = 12 - 9 = 3
# ecart_deg = 7 - 5 = 2
# => c + 3 = {1 => dis, 2 => ees}
