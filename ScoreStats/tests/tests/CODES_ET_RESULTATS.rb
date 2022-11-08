# encoding: UTF-8
=begin

  Ce module contient tous les cas qui peuvent se poser avec les 
  résultat attendus.

=end

##
# Permet de remplir tous les manques du tableau +hash+ qui devrait
# contenir toutes les notes
# 
def resultat(hash)
  ALL_NOTES.each do |note|
    next if hash.key?(note)
    hash.merge!(note => {count:0, duree:0})
  end

  return hash
end

#
###### Les durées complexes ######
B60_1 = 4.0   # ronde à 60
B60_2 = 2.0   # blanche à 60
B60_4 = 1.0   # noire à 60
B60_8 = 0.5   # croche à 60
T60_8 = (B60_4/3).round(2)  # croche en triolet à 60

B120_1 = (B60_1 / 2).round(2)
B120_2 = (B60_2 / 2).round(2)
B120_4 = (B60_4 / 2).round(2)
B120_8 = (B60_8 / 2).round(2)

##
# Définition de tous les codes possibles avec leur résultat attendu
# 
# 
CODES_ET_RESULTATS = []

#
# Une note simple
#
CODES_ET_RESULTATS << {
  code: 'a1',
  tempo: 60,
  res: resultat({'a' => {count: 1, duree: B60_1}}),
  options:{piano: false}
}

#
# Une note répétée à la même voix (durée par défaut)
# 
CODES_ET_RESULTATS << {
  code: 'a a a',
  tempo: 60,
  res: {'a' => {count:3, duree: (3 * B60_4)}}
}
CODES_ET_RESULTATS << {
  code: 'a a a',
  tempo: 120,
  res: {'a' => {count:3, duree: (3 * B120_4)}}  
}
#
# En utilisant un «\fixed c»
#
CODES_ET_RESULTATS << {
  code: '\\fixed a\' { a1 } ',
  tempo: 120,
  res: resultat('a' => {count:1, duree: 2.0})
}

# 
# En utilisant un «\relative c» au départ
#
CODES_ET_RESULTATS << {
  code: "\\relative c'' { c1 }",
  tempo: 120,
  res: resultat('c' => {count:1, duree: 2.0})
}

#
# En TRANSPOSANT la partition, ce qui ajoute la note
# de la transposition
#
CODES_ET_RESULTATS << {
  code: "c1",
  tempo: 60,
  res: resultat('c' => {count:1, duree:4.0}),
  options:{transpose:'a c'}
}


#
# Avec une liaison entre deux notes
#
CODES_ET_RESULTATS << {
  code: 'c1 c1',
  tempo: 60,
  res: resultat('c' => {count:2, duree:8.0})
}
CODES_ET_RESULTATS << {
  code: 'c1~ c1',
  tempo: 60,
  res: resultat('c' => {count:1, duree:8.0})
}

#
# Liaison dans un triolet
#
CODES_ET_RESULTATS << {
  code: '3{c8 d e~} e4',
  tempo: 60,
  res: resultat({
    'c' => {count:1, duree:T60_8},
    'd' => {count:1, duree:T60_8},
    'e' => {count:1, duree:T60_8 + 1.0}
  })
}
