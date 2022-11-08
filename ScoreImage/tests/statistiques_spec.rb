# encoding: UTF-8
=begin

Module pour tester le module Statistique qui produit les 
statistiques des notes de l'extrait à produire

Exemple de code
---------------
["\\fixed c' { r4 <b, d fis>2 r4 <a, cis fis>2 r4 <b, d fis>2 r4 <a, cis fis>2 r4 fis'( a' g' fis' cis' b cis' d' a2. fis2.~ fis~ fis~ fis) r4 fis'( a' g' fis' cis' b cis' d' a2. cis' fis' e~ e~ e) a4( b c' e' d' b << { d'4 c' b } \\\\ { r4 e2 } >> << { d'2.~ } \\\\ { r4 d2 } >> << { d'2) d'4( } \\\\ { r4 d2 } >> e'4 f' g' a'4 c' d' << { e' d' b } \\\\ { r4 e2 } >> << { d'2.~ } \\\\ { r4 d2 } >> }", "\\fixed c { g,2. d,2. g,2. d,2. << { r4 <b d' fis'>2 } \\\\ { g,2. } >> << { r4 <a cis' fis'>2 } \\\\ { d,2. } >> << { r4 <b d' fis'>2 } \\\\ { g,2. } >> << { r4 <a cis' fis'>2 } \\\\ { d,2. } >> << { r4 <b d' fis'>2 } \\\\ { g,2. } >> << { r4 <a cis' fis'>2 } \\\\ { d,2. } >> << { r4 <b d' fis'>2 } \\\\ { g,2. } >> << { r4 <a cis' fis'>2 } \\\\ { d,2. } >> << { r4 <b d' fis'>2 } \\\\ { g,2. } >> << { r4 <a cis' fis'>2 } \\\\ { d,2. } >> << { r4 <b d' fis'>2 } \\\\ { g,2. } >> << { r4 <a cis' fis'>2 } \\\\ { d,2. } >> << { r4 <a cis' fis'>2 } \\\\ { fis,2. } >> << { r4 <b d' fis'>2 } \\\\ { b,,2. } >> << { r4 <g b>2 } \\\\ { e,2. } >> << { r4 <b d' g'>2 } \\\\ { e,2. } >> << { r4 <f a d'>2 } \\\\ { d,2. } >> << { r4 <a c' e'>2 } \\\\ { a,,2. } >> << { r4 <g b e'>2 } \\\\ { d,2. } >> << { r4 <d g b>2 } \\\\ { d,2. } >> << { r4 <c e a>2 } \\\\ { d,2. } >> << { r4 <c fis a>2 } \\\\ { d,2. } >> << { r4 <a c' f'>2 } \\\\ { d,2. } >> << { r4 <a c' e'>2 } \\\\ { d,2. } >> << { r4 <d g b>2 } \\\\ { d,2. } >> << { r4 <c e a>2 } \\\\ { d,2. } >> }"]

=end
require_relative '../required'

SttPms = Struct.new(:options, :expression, :path)


def stat(lines)
  folder_assets = File.join(__dir__,'assets')
  file_mus = File.join(folder_assets,'tests_stats.mus')
  if not File.exist?(file_mus)
    `mkdir -p "#{folder_assets}"`
    File.open(file_mus,'wb'){|f| f.write lines.join("\n")}
  end
  mscore = MusicScore.new
  mscore.set_params(SttPms.new(nil, nil, file_mus))

  MusicScore::Statistiques.new(mscore, lines)  
end


@success = 0
@failures = 0
def should_equal(actual, expected, chose = nil)
  if actual == expected
    # OK
    if chose
      puts "#{chose} vaut bien #{expected.inspect}".vert
    else
      puts "La valeur est bien égale à #{expected.inspect}".vert
    end
    @success += 1
  else
    if chose
      puts "#{chose} devrait être égal à #{expected.inspect}. il vaut #{actual.inspect}".rouge
    else
      puts "Valeur attendue : #{expected.inspect} / valeur obtenue : #{actual.inspect}".rouge
    end
    @failures += 1
  end
end
def print_resultat
  method_color = @failures > 0 ? :rouge : :vert
  puts "--------------------------------------".send(method_color)
  puts "Succès: #{@success} - Échecs: #{@failures}".send(method_color)
  puts "\n\n"
end


def plain_notes(stats)
  stats.tableau_stats.map{|n,dn| dn[:plain_notes].join(' ')}.join(' ')
end




clear
puts "TESTS DES STATISTIQUES AVEC SCORIZE (music-score --stats)"

#
# Les notes sous différentes forme, avec ou sans durée
st = stat(["\\relative c,, { c d e f f2 g a b }"])
should_equal(plain_notes(st), 'c4 d4 e4 f4 f2 g2 a2 b2', 'Les différentes sortes de notes')

#
# Une note sans durée…
# … prend la durée par défaut si pas de note avant
# 
st = stat(['c'])
should_equal(plain_notes(st), 'c4')
# … prend la durée précédente s'il y a une note avant
st = stat(['d c d2 c'])
should_equal(plain_notes(st), 'd4 d2 c4 c2')

#
# Un triolet
# 
st = stat(['3{c8 d e}'])
should_equal(plain_notes(st), 'c4D3 d4D3 e4D3')
tbl = st.tableau_stats
should_equal(tbl['c'][:duration], (1.0/3).round(2), 'La durée de c dans 3{c8 d e}')
should_equal(tbl['e'][:duration], (1.0/3).round(2), 'La durée de e dans 3{c8 d e}')
# si 8 = 60
# alors triolet 8 = 2 x 60 / 3


#
# Triolet d'accords ou triolet avec accord
# (je pense que c'est impossible pour le moment : si on traite les
#  accords d'abord, on se retrouve avec trop de notes à l'intérieur,
#  si on traite les triolets d'abord, je ne suis pas certain que les
#  accords soient repérés comme des notes — mais il vaudrait mieux
#  faire comme ça de toute façon)
#
motif = '3{<e, cis>8 \up e cis}' # tiré du clair de lune de Beethoven
st = stat([motif])
should_equal(plain_notes(st), 'e4D3 e4D3 cis4D3 cis4D3', "purified_line(« 3{<e, cis>8 \\up e cis} »)") 

# Triolet avec des durées différentes à l'intérieur
# Par exemple 3{c8 d16 e f8}
motif = '3{c8 d16 e f8}'
st = stat([motif])
should_equal(plain_notes(st), 'c4D3 d8D3 e8D3 f4D3', "purified_line(« #{motif} »")

#
# Motifs problématiques
#
motif = '{ r2 r4 gis8. gis16 }'
st = stat([motif])
should_equal(plain_notes(st), 'r2 r4 gis8. gis16', "purified_line(« #{motif} »")

motif = '<< { s2 \up r2 }'
st = stat([motif])
should_equal(plain_notes(st), 's2 r2', "purified_line(« #{motif} »")

# motif = '3{gis,8 cis e} 3{a,8 cis fis} 3{a,8 cis fis}  } >>'

# Problème d'accords collés et d'accords sans durée
motif = "<gis, gis>\\stemNeutral <cis gis cis'>1<cis cis'>2<fis, fis><b, b>16"
st = stat([motif])
should_equal(plain_notes(st), 'gis4 gis4 gis1 cis1 cis1 cis2 cis2 fis2 fis2 b16 b16')
exit 0


st = stat(["\\fixed c' { fis8. c'4( <d f,,-. a>2.) c8 }"])
should_equal(st.purified, ['fis8. c4 d2. f2. a2. c8'], 'Les lignes épurées')
tbl = [{note:'a', count:1, duration:3.0}, {note:'c', count:2, duration:1.5}, {note:'d', count:1, duration:3.0}, {note:'f', count:1, duration:3.0}, {note:'fis', count:1, duration:0.75}]
should_equal(st.tableau_stats.count, tbl.count)
# TODO : vérifier plus profondément

st.produce
# TODO : tester le contenu des fichiers produits


st = stat(["<d fis>4 <f a>8. <r ceses>16.."])
should_equal(st.purified, ['d4 fis4 f8. a8. r16.. ceses16..'])


print_resultat
