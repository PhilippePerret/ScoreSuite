# encoding: UTF-8
# frozen_string_literal: true
=begin

  Extension de la class MusicScore::Parser::BlockCode spécialement
  dédiée au traitement du code de la musique dans MUS CODE, donc 
  pas les options.

=end
class MusicScore
class Parser
class BlockCode

REG_3_VOIX = /<< (.+?) \/\/ (.+?) \/\/ (.+?) >>/.freeze
REG_2_VOIX = /<< (.+?) \/\/ (.+?) >>/.freeze

# Pour les répétitions sous la forme ’% ... %X’
REG_REPETITIONS = /\% (?<segment>.+?) \%(?<iterations>[0-9]+)/

##
# = main =
# = entry =
# 
# On traite la ligne comme une ligne de code
# 
def traite_as_code_mscore(line, idx)
  # - Remplacement des variables -
  line = traite_definitions_in(line, idx)
  # - Remplacement des segments multi-voix simplifiés -
  line = replace_multi_voices(line)
  # - Remplacement des répétitions avec % ... %X -
  line = replace_repetition_code(line)
  # - Traitement des reprises avec 1re, 2e, etc.-ième fois.
  line = traite_reprises_avec_alternatives(line)
  # - Traitement des ornements avec altérations -
  line = traite_ornements_with_alterations(line)
  # - Traitement des autres barres -
  line = translate_barres(line)
  # - (essai) Traitement de l’instrument transpositeur -
  line = traite_transpositions_in(line)
  # - Traite de remplacement divers -
  line = traite_divers_remplacements_in(line)
end

# Traitement de divers remplacements pour réduire
REG_SIMPLE = '\%s '.freeze
def traite_divers_remplacements_in(line)
  line = " #{line} "
  [
    ['arp', 'arpeggio']
  ].each do |search, remp|
    line = line.gsub(REG_SIMPLE % search, REG_SIMPLE % remp)
  end
  return line[1...-1]
end

# Traitement des instruments transpositeurs
def traite_transpositions_in(line)
  # puts "Line avant : #{line.inspect}".jaune
  line = line.gsub(/\\trans ([a-gs]{1,3})/) do
    instrument_tune = $1.freeze
    table = instrument_tune.match?(/.es/) ? TABLE_DEMITONS_BEMOLS : TABLE_DEMITONS_DIESES
    offset_tune = table.index(instrument_tune)
    counter_offset = 12 - offset_tune
    counter_note = table[counter_offset]
    '\\tune %{note} \\transpose c %{note}' % {note: counter_note}
  end
  # puts "Line après : #{line.inspect}".bleu
  return line
end

TABLE_DEMITONS_DIESES = [
  'c', 'cis','d','dis','e','f','fis','g','gis','a','ais','b'
]
TABLE_DEMITONS_BEMOLS = [
  'c', 'des','d','ees','e','f','ges','g','aes','a','bes','b'
]

def replace_multi_voices(line)
  line
    .gsub(REG_3_VOIX, '<< { \1 } \\\\\\ { \2 } \\\\\\ { \3 } >>'.freeze)
    .gsub(REG_2_VOIX, '<< { \1 } \\\\\\ { \2 } >>'.freeze)
end

def replace_repetition_code(line)
  line.gsub(REG_REPETITIONS) do
    segment     = $~[:segment]
    iterations  = $~[:iterations].to_i
    "#{segment} " * iterations
  end
end


def traite_ornements_with_alterations(line)
  line = line.gsub(REG_ORNEMENTS_WITH_ALTE) do
    ornement = $~[:ornement].freeze
    alte_sup = $~[:alte_sup].freeze

    if alte_sup
      alte_sup =
        case alte_sup
        when '#' then '\sharp'
        when 'b' then '\flat'
        when 'n' then '\natural'
        end
      alte_sup = '^\markup { \hspace #0.5 \center-column { \teeny %s } }' % alte_sup
    end

    "\\#{ornement}#{alte_sup}"
  end
  line.gsub(REG_ORNEMENTS_WITH_DBLE_ALTE) do
    note      = $~[:note].freeze
    ornement  = $~[:ornement].freeze
    alte_sup  = $~[:alte_sup].freeze
    alte_inf  = $~[:alte_inf].freeze

    if alte_sup
      alte_sup =
        case alte_sup
        when '#' then '\sharp'
        when 'b' then '\flat'
        when 'n' then '\natural'
        end
      alte_sup = '^\markup { \hspace #0.5 \center-column { \teeny %s } }' % alte_sup
    end

    if alte_inf
      amorce_alte_inf = '\once \override TextScript #\'script-priority = #-100 '
      alte_inf =
        case alte_inf
        when '#' then '\sharp'
        when 'b' then '\flat'
        when 'n' then '\natural'
        end
      alte_inf = '^\markup { \hspace #0.5 \center-column { \teeny %s } }' % alte_inf
    else
      amorce_alte_inf = ''
    end
    
    "#{amorce_alte_inf}#{note}\\#{ornement}#{alte_inf}#{alte_sup}"

  end
end
ORNEMENTS = /(?<ornement>turn|prall|mordent)/.freeze
REG_ORNEMENTS_WITH_ALTE = /\\#{ORNEMENTS}(?<alte_sup>[#bn])/.freeze
REG_ORNEMENTS_WITH_DBLE_ALTE = /(?<note>[a-z0-9,'’]+)\\#{ORNEMENTS}(?<alte_sup>[#bn])?\/(?<alte_inf>[#bn])/.freeze

# On ne traite ici que les reprises avec alternative, les autres
# barres sont traitées plus simplement dans #translate_barres
# 
# 
# TODO 
#   TESTER AVEC |1,2   (+ -> MANUEL — indiquer "pas de 1-3")
# 
def traite_reprises_avec_alternatives(line)
  while true # Tant qu’il y a des reprises avec alternatives
    # <=== TODO Test plusieurs reprises avec alternatives
    break if not(line.match?(/\|1/))
    # puts "La ligne #{line.inspect} passe.".bleu
    # On tâtonne :
    # On cherche tous les segments de répétition pouvant avoir
    # une alternative. Un tel segment de répétition possède forcément
    # un ":|<X>" pour passer à la suite
    # On commence par prendre le bout
    offset_end_reprise = line.index(REG_FIN_REPETITION_WITH_ALT)
    if offset_end_reprise
      # Fin de la dernière alternative
      offset = line.index(REG_END_LAST_ALT, offset_end_reprise)
      seg = line[0...offset].strip
      
      # Le bout de muscode après
      next_seg = (line[offset..] || "").strip
      # On supprime ses éventuels ’||’ au début (sinon, il faut les
      # garder car c’est ’|:’ ou ’|.’)
      next_seg = next_seg[2..] if next_seg.start_with?('||')
      
      # puts "next_seg = #{next_seg.inspect}".bleu
      # Noter que la dernière alternative peut avoir + d’alternatives,
      # quand on remonte tout au début. On peut avoir :
      # |: ... |1 ... :|2 ... |3 ... || <====== TODO TESTER
      offset = seg.rindex('|:')||0
      # Le bout de muscode avant
      previous_seg = offset > 0 ? seg[0...offset] : ""
      seg = seg[offset..-1]
      # puts "Segment avec reprise : #{seg.inspect}"

      segs = seg.split(/(\:?\|)([0-9,]+)/)
      # => [debut, barre, numéro, note alt, barre, num, notes etc.]

      # Le premier élément (les notes avant la première alternative)
      notes_repeat = segs.shift
      # Il peut commencer par le début de reprise
      notes_repeat = notes_repeat[2..] if notes_repeat.start_with?('|:')

      # Le dernier élément peut contenir les deux signes qui 
      # mettent fin à la dernière alternative, ’||’, ’|:’ ou ’|.’
      # (NON, JE CROIS QUE ÇA N’ARRIVE PLUS)
      if segs[-1].match?(/#{REG_END_LAST_ALT}$/)
        two_last_chars = segs[-1][-2..-1]
        # Il faut les remettre dans next_seg si c’est ’|:’ ou ’|.’
        if ['|.','|:'].include?(two_last_chars)
          next_seg = "#{two_last_chars} #{next_seg}"
        end
        segs[-1] = segs[-1][0..-3] 
      end

      segs = segs.each_slice(3).to_a
      # puts "segs = #{segs.inspect}".bleu
      # => Groupe par 3 => [ [bar,num, note], [bar,num,note], etc.]
      
      # # Nombre de reprise (dépend du numéro de la dernière alternative)
      nb_reprises = segs.count

      # On crée une alternative pour chaque alternative
      alternatives = segs.map do |truplet|
        # puts "truplet = #{truplet.inspect}".bleu
        "\\volta #{truplet[1]} { #{truplet[2].strip} }"
      end.join(' ')

      # Formatage final
      seg_formated = "\\repeat volta #{nb_reprises} { #{notes_repeat} \\alternative { #{alternatives} } }"
      line = "#{previous_seg} #{seg_formated} #{next_seg}"

      # puts "line à la fin : #{line.inspect}".bleu
    else
      raise "La ligne #{line} est malformatée. Elle devrait contenir une fin de répétition avec alternative : ’:|<x>’."
    end
  end #/ while
  # raise 
  line  
end
REG_FIN_REPETITION_WITH_ALT = /\:\|([0-9]+)/.freeze
REG_END_LAST_ALT = /(\|\||\|\.|\|\:)/.freeze # || ou |. ou |:

def translate_barres(line)
  # Les barres de reprise sont simplement mises en '|:', ':|:' ou ':|'
  line = line.gsub(/:\|:/, '_DOUBLE_BARRES_REPRISE_')
        .gsub(/\|:/, '\bar ".|:"')
        .gsub(/:\|/, '_BARRES_REPRISE_FIN_')
        .gsub(/\|\./, '\bar "|."')
        .gsub(/\|\|/, '\bar "||"')
  line = line.gsub(/_DOUBLE_BARRES_REPRISE_/, '\bar ":|.|:"')
  line = line.gsub(/_BARRES_REPRISE_FIN_/, '\bar ":|."')
  return line
end

end #/BlockCode
end #/Parser
end #/MusicScore
