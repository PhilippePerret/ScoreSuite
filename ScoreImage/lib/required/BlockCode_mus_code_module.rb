# encoding: UTF-8
# frozen_string_literal: true
=begin

  Extension de la class MusicScore::Parser::BlockCode spécialement
  dédiée au traitement du code de la musique dans MUS CODE, donc 
  pas les options.

=end
require_relative 'regexp_lilypond'

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
  # - Remplacement des arpèges vers accords -
  line = traite_arpege_to_chord_in(line)
  # - Remplacement des suspensions de fusion de silences -
  line = traite_suspend_rests_merging_in(line)
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
    ['arp', 'arpeggio'],
    ['mergeNotes', 'mergeDifferentlyHeadedOn \mergeDifferentlyDottedOn']
  ].each do |search, remp|
    line = line.gsub(REG_SIMPLE % search, REG_SIMPLE % remp)
  end
  return line[1...-1]
end

def traite_arpege_to_chord_in(line)
  return line if not(line.match?('tieWait'))
  line = line.gsub(REG_ARP2CHORD) do
    sens_tie  = $~[:tie]
    sens_stem = $~[:stem]
    if sens_tie && sens_stem.nil?
      sens_stem = sens_tie == 'D' ? 'U' : 'D'
    end
    sens_tie   = DOWN_OR_UP[sens_tie]
    sens_stem  = DOWN_OR_UP[sens_stem]
    sens_tie   = sens_tie ? " \\tie#{sens_tie}" : ""
    sens_stem  = sens_stem ? " \\stem#{sens_stem}" : ""
    # puts "sens_tie: #{sens_tie} / sens_stem: #{sens_stem}".bleu
    '\set tieWaitForNote = ##t%s%s'.freeze % [sens_tie, sens_stem]
  end
  return line
end
DOWN_OR_UP = {nil => nil, 'D' => 'Down', 'U' => 'Up' }
REG_ARP2CHORD = /\\tieWait(?:(?<tie>[UD])(?<stem>[UD])?)?/


# Traitement de la suspension de la fusion des silences (qui est
# enclenchée par défaut avec score-image)
def traite_suspend_rests_merging_in(line)
  return line unless line.match?(/not_merge_rest/)
  line = line.gsub(REG_SUSPEND_REST_MERGE) do
    valeur = $~[:not].nil? ? 'f' : 't'
    '\set Merge_rests_engraver.suspendRestMerging = ##%s'.freeze % [valeur]
  end
  return line
end
REG_SUSPEND_REST_MERGE = /\\(?<not>not_)?merge_rests?/.freeze


# Traitement des instruments transpositeurs
def traite_transpositions_in(line)
  # puts "Line avant : #{line.inspect}".jaune
  line = line.gsub(/\\trans ([a-gs]{1,3})/) do
    
    # puts "[traite_transpositions_in] options = #{options}".jaune
    # exit 12

    inst_tune = $1.freeze
    puts "\ninst_tune = #{inst_tune}".bleu
    # table = inst_tune.match?(/.es/) ? TABLE_DEMITONS_BEMOLS : TABLE_DEMITONS_DIESES
    # offset_tune = table.index(inst_tune)
    # counter_offset = 12 - offset_tune
    # counter_note = table[counter_offset]

    lettre1 = inst_tune[0]
    diff_degres = 2 - DEGRES.index(lettre1)
    # => 2 pour A, -2 pour E, etc.
    diff_degres = (7 - diff_degres) % 7
    puts "diff_degres = #{diff_degres.inspect}".bleu
    inst_tons = TABLE_DEMITONS_DIESES.index(inst_tune)||TABLE_DEMITONS_BEMOLS.index(inst_tune)
    # diff_tons = 12 - inst_tons
    diff_tons = inst_tons
    # P.e. 3 pour ’a’ qui est à 9
    puts "diff_tons = #{diff_tons}".bleu

    counter_note = NOTE_WITH_ALT_FROM_C[diff_degres][diff_tons] || begin
      raise <<~ERR

      Impossible de trouver la contrenote pour l’instrument 
      tranpositeur #{inst_tune}.
      Valeurs calculées
      -----------------
      diff_degres = #{diff_degres.inspect}
      diff_tons   = #{diff_tons.inspect}
      ERR
    end 


    # - La "tune note", c’est-à-dire l’armure correspondant à la
    # transposition. Par exemple, si c’est un instrument en Eb, 
    # lorsque la tonalité est Eb, la "tune note" est c. C’est en
    # quelque sort l’inverse de la counter_note
    piece_tune = options[:key]||"c"
    trans_tune = MusicScore::Transposition.transposed_tune(
      inst_tune, piece_tune)
    # puts "trans_tune: #{trans_tune.inspect}"
    '\\key %{armure} \\transpose %{note} c\''.freeze % {note: counter_note, armure: trans_tune}
  end
  # puts "Line après : #{line.inspect}".bleu
  return line
end

DEGRES = "abcdefg".freeze

# Table qui permet de trouver la note de transposition exacte.
# Par exemple, entre C et A, il y a 3 demi-tons, et donc on pourrait
# obtenir Ré# aussi bien que Eb. Mais puisqu’il y a 2 degré entre
# C et A, on sait qu’il faut choisir Mi bémol et non pas Ré#
NOTE_WITH_ALT_FROM_C = {
  # En clé, la différence de degré par rapport à Do
  # En valeur, en clé, le nombre de demi-tons, en valeur la
  # note en découlant
  0 => {0 => 'c', 1 => 'cis'},
  # Ré
  1 => {1 => 'des', 2 => 'd', 3 => 'dis' },
  # Mi
  2 => {3 => 'ees', 4 => 'e', 5 => 'eis'},
  # Fa
  3 => {4 => 'fes', 5 => 'f', 6 => 'fis'},
  # Sol
  4 => {6 => 'ges', 7 => 'g', 8 => 'gis'},
  # La
  5 => {8 => 'aes', 9 => 'a', 10 => 'ais'},
  # Si
  6 => {10 => 'bes', 11 => 'b', 12 => 'bis'}
}

TABLE_DEMITONS_DIESES = [
  'c', 'cis','d','dis','e','f','fis','g','gis','a','ais','b'
].freeze
TABLE_DEMITONS_BEMOLS = [
  'c', 'des','d','ees','e','f','ges','g','aes','a','bes','b'
].freeze

def replace_multi_voices(line)
  line
    .gsub(REG_3_VOIX, '<< { \1 } \\\\\\ { \2 } \\\\\\ { \3 } >>'.freeze)
    .gsub(REG_2_VOIX, '<< { \1 } \\\\\\ { \2 } >>'.freeze)
end

def replace_repetition_code(line)

  # Répétitions à l’aide de ’*X’ (comme pour les silence dans 
  # Lilypond mais appliqué à tout code "compact")
  line = line.gsub(REG_REPETITION_ASTERISK) do
    note      = $~[:note]
    alter     = $~[:alter]
    octave    = $~[:octave]
    duration  = $~[:duration]
    fois      = $~[:fois].to_i

    premiere_note = "#{note}#{alter}#{octave}#{duration}"
    autres_notes  = "#{note}#{alter}"
    ([premiere_note] + Array.new(fois - 1, autres_notes)).join(' ')
  end

  # Répétitions à l’aide du signe ’% ... %X’
  line = line.gsub(REG_REPETITIONS) do
    segment     = $~[:segment]
    iterations  = $~[:iterations].to_i
    # Traitement d’une marque d’octave sur la première note : la
    # supprimer pour les répétitions
    notes_maybe = segment.strip.split(' ')
    first_note  = notes_maybe.shift # note : on l’enlève vraiment
    segments = 
      if first_note.match?(REG_MARK_OCTAVE)
        first_note_n  = first_note.gsub(REG_MARK_OCTAVE, '')
        segmentN      = "#{first_note_n} #{notes_maybe.join(' ')}"
        [segment] + Array.new(iterations - 1, segmentN)
      else
        Array.new(iterations, segment)
      end
    segments.join(' ')
  end

  return line
end

# Pour les \musicglyphs de LilyPond, voir
# https://lilypond.org/doc/v2.24/Documentation/notation/the-emmentaler-font
def traite_ornements_with_alterations(line)

  # puts "/nline = #{line.inspect}".jaune


  # - Traitement des doubles altération (au-dessus/en dessous)
  # 
  line = traite_ornements_with_dbl_alterations(line)

  # puts "\nline après double: #{line.inspect}".bleu

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

  return line
end
#/traite_ornements_with_alterations


def traite_ornements_with_dbl_alterations(line)
  line = line.gsub(REG_ORNEMENTS_WITH_DBLE_ALTE) do
    note      = $~[:note].freeze
    alter     = $~[:alter].freeze
    octave    = $~[:octave].freeze
    ornement  = $~[:ornement].freeze
    position  = ($~[:position]||'^').freeze
    alte_sup  = $~[:alte_sup].freeze
    alte_inf  = $~[:alte_inf].freeze

    hspace_sup = alte_inf == '#' ? '0.7' : '0.8'
    hspace_inf = alte_inf == '#' ? '0.5' : '0.6'

    alte_sup =
      case alte_sup
      when '#' then '\sharp'
      when 'b' then '\flat'
      when 'n' then '\natural'
      end
    alte_sup = alte_sup ? " \\teeny #{alte_sup}" : ''

    alte_inf =
      case alte_inf
      when '#' then '\sharp'
      when 'b' then '\flat'
      when 'n' then '\natural'
      end
    alte_inf = alte_inf ? " \\teeny #{alte_inf}" : ''


    posup = position == '^'

    ornementation = '%{pos}\markup %{bskip} %{halign} \center-column {%{alte_sup} \musicglyph "scripts.turn"%{alte_inf} }'.freeze % {
      pos: position, # au-dessus ou au-dessous,
      bskip: '\override #\'(baseline-skip . 2)'.freeze,
      halign: '\halign #-%s'.freeze % [posup ? hspace_sup : hspace_inf],
      alte_sup: alte_sup,
      alte_inf: alte_inf,
    }

    '%{note}%{ornementation}'.freeze % {
      note: "#{note}#{alter}#{octave}",
      ornementation: ornementation,
    }

  end #/gsub

  return line
end

def OLD_traite_ornements_with_dbl_alterations(line)
  raise "Je ne dois plus utiliser ça"
  # Ici, il faut capturer la note, car on doit placer quelque chose
  # avant.
  line = line.gsub(REG_ORNEMENTS_WITH_DBLE_ALTE) do

    note      = $~[:note].freeze
    alter     = $~[:alter].freeze
    octave    = $~[:octave].freeze
    ornement  = $~[:ornement].freeze
    position  = ($~[:position]||'^').freeze
    alte_sup  = $~[:alte_sup].freeze
    alte_inf  = $~[:alte_inf].freeze

    alte_sup =
      case alte_sup
      when '#' then '\sharp'
      when 'b' then '\flat'
      when 'n' then '\natural'
      end

    alte_inf =
      case alte_inf
      when '#' then '\sharp'
      when 'b' then '\flat'
      when 'n' then '\natural'
      else nil
      end

    overrides = ''

    if ['turn','reverseturn','slashturn'].include?(ornement)
      if position == '^' && alte_inf != '\flat'
        # Le dièse/bécarre est trop séparé (ou le signe est trop haut)
        overrides = '\once \override TextScript.script-priority = #-300 '.freeze
      elsif position == '_' && alte_sup != '\sharp'
        # Même chose que ci-dessus, mais avec le bémol quand le 
        # l’ornement est placé en dessous
        overrides = '\once \override TextScript.script-priority = #-300 '.freeze
      end

      puts "\noverrides = #{overrides.inspect}".bleu
    end

    
    alte_inf = 
      if alte_inf
        hspace = alte_inf != '\sharp' ? ' \hspace #0.3' : ''
        '%s\markup {%s \teeny %s }'.freeze % [position, hspace, alte_inf]
      else '' end
    alte_sup = 
      if alte_sup
        hspace = alte_sup != '\sharp' ? ' \hspace #0.3' : ''
        '%s\markup {%s \teeny %s }'.freeze % [position, hspace, alte_sup]
      else '' end

    ornement = 
      '%s\markup { \hspace #0.5 \musicglyph  "scripts.%s" }'.freeze % [position, ornement]

    '%{over}%{note}%{ainf}%{ornement}%{asup}'.freeze % {
      over: overrides,
      note: "#{note}#{alter}#{octave}",
      ornement: ornement,
      ainf: alte_inf, asup: alte_sup
    }

  end

  return line  
end

ORNEMENTS = /(?<ornement>reverseturn|slashturn|haydnturn|turn|prall|mordent)/.freeze
REG_ORNEMENTS_WITH_ALTE = /\\#{ORNEMENTS}(?<alte_sup>[#bn])/.freeze
REG_ORNEMENTS_WITH_DBLE_ALTE = /#{REG_NOTE_DUREE_SIMPLE}(?<position>[_\^])?\\#{ORNEMENTS}(?<alte_sup>[#bn])?\/(?<alte_inf>[#bn])/.freeze

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
