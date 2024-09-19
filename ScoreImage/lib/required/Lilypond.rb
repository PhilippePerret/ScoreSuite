# encoding: UTF-8
# frozen_string_literal: true
=begin

  Class MusicScore::Lilypond
  --------------------------
  Pour produire le code final à partir du code music-score

=end
class MusicScore
class Lilypond

LILYPOND_VERSION = "2.24.0"

CLE_TO_CLE_LILY = {
  'F' => 'bass', 'F3' => 'varbaritone',
  'G' => 'treble', 'G1' => 'french',
  'UT1' => 'soprano', 'UT2' => 'mezzosoprano',
  'UT3' => 'alto', 'UT4' => 'tenor', 'UT5' => 'baritone'
}

# Pour savoir si c’est une définition "pure" de la tonalité qui,
# dans ce cas, n’ajoute pas de double barre avant
REG_PUR_TUNE_IN = /[a-g](es|is)?/.freeze
REG_PUR_TUNE = /^#{REG_PUR_TUNE_IN}$/.freeze

class << self

attr_reader :options


# --- MÉTHODES DE TRANSLATION DU CODE MUSIC-SCORE VERS LILYPOND ---
##
# = main =
#
# Traduit un code music-score en un code Lilypond conforme
#
def translate_from_music_score(str, options)
  rationnalise_options(options)
  str = " #{str} "

  # P.e les \slurOff, les substitutions de doigtés (tilde)
  str = translate_shortcuts_from_mus(str)

  str = translate_octaves_from_ms(str)

  # str = translate_barres_from_ms(str)

  str = " #{str.strip} "
  str = translate_armure_from_mus(str)

  str = " #{str.strip} "
  str = translate_keys_from_ms(str)

  str = " #{str.strip} "
  str = translate_percents_from_ms(str)

  str = " #{str.strip} "
  str = translate_nuplets_from_ms(str)

  str = " #{str.strip} "
  str = translate_trilles_from_ms(str)

  str = " #{str.strip} "
  str = translate_graces_notes_from_ms(str)

  str = " #{str.strip} "
  str = translate_staff_change_from_ms(str)

  # On échappe toutes les balances
  str = str.gsub(/\\/, '\\')

  return str
end


##
# = main =
#
# @return [String]  
#     Le code complet à copier dans le fichier lilypond final, pour 
#     interprétation.
#
# @param code     [Array] Les lignes de code (code Lilypond)
# @param options  [Hash]  Les options
#     Note :  la méthode options.to_sym permet d'avoir les clés en
#             String et en Symbol, peu importe.
# 
#   :midi     Quand on met ’--midi’ en options dans le code mus. On
#             doit alors produire le fichier normal SVG et le fichier
#             MIDI. Noter qu’il faut deux fichiers pour ça, car il 
#             faut un fichier lilypond particulier pour les articula-
#             tion en MIDI.
#             Noter que cette option est différente de l’option 
#             ’-midi’ en ligne de commande, qui demande de ne sortir
#             que le fichier MIDI.
#
def compose(code, options)
  # Rationalisation des options
  # Noter que maintenant (provisoirement si ça foire) elles ont été
  # rationaliser une première fois dans #translate_from_music_score
  # ci-dessus
  rationnalise_options(options)
  sep = "\n% --- %\n".freeze # délimiteur de partie
  beautify_code(header + sep + bloc_score(code,options) + sep + footer)
end

def bloc_score(code, options)
  c = []
  c << '\score {'.freeze
  if midi?
    # Pas de bloc layout, mais la marque pour les articulations
    c << '\articulate <<'
  else
    c << bloc_layout
  end
  c << body(code, options[:system])
  if midi?
    c << '>> % /fin articulate'
    c << bloc_midi
  end
  c << '} %/fin de score'

  return c.join("\n")
end

def midi?
  :TRUE == @outputmidifile
end
def set_midi(value = true)
  @outputmidifile = value ? :TRUE : :FALSE
end
def midi_file_required?
  :TRUE == @midifileisrequired
end
def only_midi_file?
  :TRUE == @onlymidifileoutput ||= true_or_false(CLI.option(:midi))
end



# Méthode qui met en forme le texte du code pour qu’il soit plus
# lisible, mieux présenté.
def beautify_code(code)
  ary = []
  @indent_len = 0
  @indent_str = ""
  next_indent_len = nil # pour simplifier l’écriture (cf. ci-dessous)
  code.split("\n").each do |line|
    line = line.strip
    next if line.empty?
    # puts "line: #{line}".bleu
    if line.end_with?('<<') || line.end_with?('{')
      next_indent_len = true
    # elsif line.end_with?('>>') # Problème avec double voix
    elsif line == '>>'
      crementize_indentation(-1)
    elsif line.end_with?('}')
      # Il faut compter le nombre de { et de } pour être sûr que
      # c’est vraiment un passage à la ligne (ne faudrait-il pas le
      # faire partout, d’ailleurs ?)
      nombre_open = line.count('{')
      nombre_clos = line.count('}')
      if nombre_clos > nombre_open
        crementize_indentation(-1)
      end
    end
    ary << @indent_str + line
    if next_indent_len
      crementize_indentation(1)
      next_indent_len = nil
    end
  end
  final_txt = ary.join("\n")

  # - Quelques ultimes nettoyages -
  # 
  # Pour le moment, on ne doit que supprimer les doubles \key à la
  # suite qui posent un problème silencieux lorsqu’il y a des 
  # instruments transpositeurs.
  final_txt = ultime_nettoyage(final_txt)

  # - On retourne le texte finalisé -
  return final_txt
  
rescue Exception => e
  puts <<~TEXT.rouge

  IMPOSSIBLE DE BEAUTISER LE CODE CI-DESSOUS :
  (raison : #{e.message})
  #{code}
  --------------------------------------------
  J’en étais à :
  #{ary.join("\n")}
  --------------------------------------------
  TEXT
  raise "Problème de formatage"
end

def ultime_nettoyage(str)
  str = str.gsub(REG_DOUBLE_KEYS) do
    $~[:deuxieme] # on retire le premier
  end

  return str
end

REG_KEY_LL = /\\key #{REG_PUR_TUNE_IN} \\(major|minor)/.freeze
# Pour détecter les doubles définitions d’armure introduite pour les
# instruments transpositeur (je n’ai pas trouvé le moyen de les
# retirer autrement qu’en les remplaçant ci-dessus)
REG_DOUBLE_KEYS = /(?<premier>#{REG_KEY_LL})([\t\n ]+)(?<deuxieme>#{REG_KEY_LL})/


def crementize_indentation(adding)
  @indent_len += adding
  @indent_str =  "  " * @indent_len
  # puts "indent: #{@indent_len}".orange
end

def rationnalise_options(options)

  # Depuis JUILLET 2024, on analyse mieux les noms pour tenir compte
  # des éventuels groupements de portées. Trois classes ont été 
  # créées pour ça : Lilypond::Group, Lilypond::System et 
  # Lilypond::Staff
  options.merge!(isystem: Lilypond::System.parse(options['staves_names'], options['staves_keys']))

  #
  # On ajoute les clés symboliques (donc on aura les deux versions
  # des clés dans la table)
  #
  @options = options.to_sym

  # Pour indiquer que le fichier MIDI est requis, si les options
  # du code mus contiennent ’--midi’
  @midifileisrequired = options[:midi] == true

end

##
# @return [String] Le corps du code en fonction du système choisi.
# 
# @param [String|Integer] system
#         Valeurs possible :
#         solo        Une seule portée
#         piano       Piano
#         quatuor     Quatuor à corde
#         sonate_with_piano   Type sonate pour violon, flûte, etc.
#         Ou :
#           un nombre de portées.
#
def body(code, system)
  system = 'solo' if system.is_a?(Integer) && system == 1
  case system
  when 'sonate_with_piano'
    params = {name: options[:staves_names][0]}
    systeme_for_sonate_with_piano(code, params)
  when 'piano'
    params = {name: (options[:staves_names]||[''])[0].downcase == 'piano' }
    system_for_piano(code, params)
  when 'solo', 'quatuor'
    params = options.dup
    send("system_for_#{system}", code, params)
  when Integer 
    system_for_x_staves(code)
  else
    raise EMusicScore.new("La valeur '#{system}' pour 'system' est intraitable… (inconnue)")
  end
end

def bloc_midi
  <<~LILYPOND
  \\midi {
    #{mark_tempo_midi}
  }
  LILYPOND
end
def mark_tempo_midi
  return "" unless tempo?
  note_base, tempo_base =
    if tempo.end_with?('T')
      ['4.', tempo[0..-2]]
    else
      ['4', tempo]
    end
  '\tempo %s = %s'.freeze % [note_base, tempo_base]
end
def tempo?
  not(tempo.nil?)
end
def tempo
  @tempo ||= begin
    (CLI.option(:tempo)||options[:tempo]).to_s.freeze
  end
end

def system_for_solo(code, params)
  <<~LILYPOND
  \\new Staff #{mark_with_staff(params)}<<
  #{markin_transposition}\\relative c' {
    #{option_no_time}
    #{option_no_stem}
    \\clef "treble"
    #{option_tonalite}
    #{option_num_mesure}
    #{code[0]}
  }
  >>
  LILYPOND
end
#/system_for_solo

def systeme_for_sonate_with_piano(code, params)
  <<~LILYPOND
  <<
    #{staff_for(code[0], params)}
    #{system_for_piano(code[1..2], **{name:true})}
  >>
  LILYPOND
end

def system_for_piano(code, **params)
  params.merge!(name: 'PIANO') if params[:name]
  <<~LILYPOND
  \\new PianoStaff #{mark_with_staff(params)}<<
    \\new Staff = "haute" {
      % enforce creation of all contexts at this point of time
      \\clef "treble"
      #{markin_transposition}\\relative c' {
        #{option_no_time}
        #{option_no_stem}
        #{option_tonalite}
        #{option_num_mesure}
        #{code[0]}
      }
    }
    \\new Staff = "basse" {
      \\clef bass
      #{markin_transposition}\\relative c {
        #{option_no_time}
        #{option_no_stem}
        #{option_tonalite}
        #{code[1]}
      }
    }
  >>
  LILYPOND
end
#/system_for_piano

# Méthode gérant les systèmes à portées multiples
# 
# Depuis juillet 2024, on peut regrouper les portées pour former des
# groupes d’instruments (les bois, les cordes, etc.) ou former des
# instrument à double portée comme la harpe ou le piano.
# Pour gérer cela, on utilise simplement les crochets pour définir
# staves_names avec la règle suivante :
#       Si les noms entre les crochets sont identiques, il 
#       s’agit d’un instrument unique (le piano, la harpe)
#       dans le cas contraire il s’agit d’un groupe d’ins-
#       truments (les bois, les cordes…)
# 
# Pour les regroupements, on trouve les expressions:
# cf. https://lilypond.org/doc/v2.24/Documentation/notation/displaying-staves#grouping-staves
#   << 
#     \new Staff 
#     \new Staff 
#     ...           Trait seul pour réunir les staves
#   >>              Barres de mesures non reliées
#                   Valeur par défaut
#   - ChoirStaff    Trait + crochets obliques pour réunir les portées 
#                   Barres de mesures non reliées
#   - StaffGroup    Trait + crochets obliques pour réunir les portées 
#                   Barre de mesures reliées
#   - GrandStaff    Trait + accolade pour réunir les portées
#                   Barres de mesures reliées
#   - PianoStaff    = GrandStaff
#   - DrumStaff     portée à cinq lignes pour batterie
#   - RhytmicStaff  portée à ligne unique
#   - TabStaff      Tablature
# 
# Maintenant, au lieu d’avoir un ’options['staves_names']’ qui 
# contient les noms et un options['staves_keys'] qui contient les
# clés, on crée un ’options[:system]’ qui contient toutes les données
# analysées.
# Voir la méthode Lilypond::System::parse qui analyse la définition
# de ’staves_names’ (et ’staves_keys’)
# 
def system_for_x_staves(code, **params)
  isystem = options[:isystem]

  # puts isystem.inspect # inspection personnalisée

  c = []
  c << isystem.start_mark
  code.each_with_index do |code_portee, idx|
    staff = isystem.staves[idx] # => Lilypond::Staff

    # Marque de début de groupe ?
    if staff.in_group? && staff.first_staff?
      c << staff.group.start_mark
    end

    # - Code de la portée
    c << staff_for(code_portee, { name: staff.final_name, key: staff.key })

    # Marque de fin de groupe ?
    if staff.in_group? && staff.last_staff?
      c << staff.group.end_mark
    end

  end
  c << isystem.end_mark
  c = c.join("\n")
  # puts "------------\nCODE LILYPOND:\n#{c}\n---------------".jaune
  return c
end


def system_for_quatuor(code, **params)
  <<-LILYPOND
  \\new StaffGroup <<
    #{staff_for(code[0], {name:'Violon 1'})}
    #{staff_for(code[1], {name:'Violon 2'})}
    #{staff_for(code[2], {name:'Alto',  key: 'alto'})}
    #{staff_for(code[3], {name:'Cello', key: 'bass'})}
  >>
  LILYPOND
end
#/system_for_quatuor

def staff_for(code, params)
  relative = case params[:key]
  when 'F'    then ''
  when /^UT/  then "'"
  else "''"
  end
  staff_cle = params[:key] ? "\\clef #{CLE_TO_CLE_LILY[params[:key]]}\n" : ""
  <<~LILYPOND
  \\new Staff #{mark_with_staff(params)} {
    #{markin_transposition}\\relative c#{relative} {
      #{staff_cle}
      #{option_no_time}
      #{option_no_stem}
      #{option_tonalite}
      #{option_num_mesure}
      #{code}
    }
  }
  LILYPOND
end

def mark_with_staff(params)
  withs = []
  unless options[:merge_rests] === false
    # Pour le moment, par défaut, on merge les silences
    withs << '\consists Merge_rests_engraver'
  end
  if params[:name]
    withs << ('instrumentName = %s'.freeze % params[:name] )
  end

  # On "compile" tous les with(s)
  if withs.empty?
    ''
  else
    '\with { %s } '.freeze % withs.join("\n")
  end
end


def header
  <<-LILYPOND
\\version "#{LILYPOND_VERSION}"

#(set-default-paper-size #{option_page_format})
#{option_global_staff_size}

#{'\include "articulate.ly"' if midi?}

\\paper{
  indent=0\\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f

  #{option_page_numbers}
  #{option_vspace_between_systems}
  #{options_system_count_per_page}
}

  LILYPOND
end
#/header


# Le ’layout’ dans :
#   \score {
#     \layout {
#     }
#     ... musique
#   }
def bloc_layout
  <<~CODE.gsub('\\','\\\\')
  \\layout {
    \\context {
      % On utilise context pour utiliser des context
      #{option_staves_vspace}
      #{layout_context_score}
    }
    #{code_extraction_fragment}
  }
  CODE
end

# ==== LAYOUT/CONTEXT/ SCORE ===

def layout_context_score
  lines = []
  if options[:barres] === false
    lines << '\override BarLine.break-visibility = #all-invisible'
  end


  # - Proximité des notes -
  if options[:proximity]
    lines << (OVERRIDE_PROXIMITY % options[:proximity])
  end


  # - Numéro de mesure -

  # Absence du numéro de mesure
  if options[:mesures] === false || options[:mesure] === false
    lines << '\omit BarNumber'
  else 
    # Compatibilité descendante
    options.merge!(number_per: 5) if options[:number_per_5]
    # Cas première mesure numérotée
    if options[:first_measure] && not(options[:mesure])
      lines << NUMBER_BAR_ALL
    end
    if options[:measure_number_under_staff]
      lines << (OVERRIDE_BARNUM_DIR % 'DOWN')
    end
    if options[:mesure]
      lines << (FIRST_MEASURE_NUMBER % options[:mesure])
    end
    # Visibilité des numéros
    if options[:number_per]
      lines << NUMBER_BAR_PER % options[:number_per]
      lines << (OVERRIDE_BARNUM_VISIBILITY % ['f','t','t'])
    elsif options[:first_measure]
      cours = options[:number_per] ? 't' : 'f'
      lines << (OVERRIDE_BARNUM_VISIBILITY % ['f', cours, 't'])
    end
  end

  # S’il faut écrire le contexte \Score
  if lines.empty?
    return ""
  else
    '\\Score' + "\n" + lines.join("\n")
  end
end

# - Proximité des signes -
OVERRIDE_PROXIMITY = <<~'TEXT'.strip.freeze
\override SpacingSpanner.common-shortest-duration = #(ly:make-moment 1/%s)
TEXT

# - Numéro de mesure -
NUMBER_BAR_PER = <<~'TEXT'.strip.freeze
barNumberVisibility = #(every-nth-bar-number-visible %s)
TEXT
NUMBER_BAR_ALL = <<~'TEXT'.strip.freeze
barNumberVisibility = #all-bar-numbers-visible
TEXT
OVERRIDE_BARNUM_DIR = <<~'TEXT'.strip.freeze
\override BarNumber.direction = #%s
TEXT

FIRST_MEASURE_NUMBER = <<~'TEXT'.strip.freeze
currentBarNumber = #%s
TEXT

# Ordre des booleans : fin de ligne, cours de ligne, début de ligne
# Valeur "t" ou "f"
OVERRIDE_BARNUM_VISIBILITY = <<~'TEXT'.strip.freeze
\override BarNumber.break-visibility = ##(#%s #%s #%s)
TEXT
# OVERRIDE_BARNUM_INVISIBLE = <<~'TEXT'.strip.freeze
# \override BarNumber.break-visibility = #end-of-line-invisible
# TEXT

def options_system_count_per_page
  if ( n = (options[:system_count]||options[:system_count_per_page]) )
    # "system-count = ##{n}" # ne fonctionne pas : met tout dans ce nombre sur une seule page
    'max-systems-per-page = #%s'.freeze % n.to_s
  end  
end

def option_global_staff_size
  if options[:staff_size] && options[:staff_size].to_i > 0
    "#(set-global-staff-size #{options[:staff_size]})"
  end
end


def code_extraction_fragment
  return ''
  <<-TEXT
  clip-regions
  = #(list
      (cons
       (make-rhythmic-location 5 1 4)
       (make-rhythmic-location 12 1 4)))
  TEXT
end

def footer
  <<~LILYPOND

  LILYPOND
end
#/footer

def option_page_numbers
  if options[:page_numbers] === false
    <<~TEXT.strip
    print-page-number = ##f
    TEXT
  elsif options[:page_numbers]
    <<~TEXT.strip
    print-page-number = ##t
    page-number-type = #'#{options[:page_numbers]}
    TEXT
  else
    ""
  end
end

# Espacement entre les systèmes
# (pour l’espace entre les portées, cf. ci-dessous)
def option_vspace_between_systems
  return "" unless options[:systems_vspace]
  <<~TEXT
  system-system-spacing = #'(
    (basic-distance . #{options[:systems_vspace]})
    (minimum-distance . #{options[:systems_vspace]})
    (padding . 1)
    (stretchability . 10))
  TEXT
end

# Espacement entre les portées
# (pour l’espacement entre les systèmes, cf. ci-dessus)
def option_staves_vspace
  if options[:staves_vspace]
    <<~'TEXT' % [options[:staves_vspace]]
    \Staff
    \override VerticalAxisGroup
      .staff-staff-spacing.basic-distance = %s
    TEXT
  else "" end
end

def option_page_format
  options[:page] ||= '"a0" \'landscape'
  options[:page] = "\"#{options[:page]}\"" unless options[:page].start_with?('"')
  return options[:page].downcase
end

def option_num_mesure
  options[:mesure] ? premier_numero_mesure : ""
end
def premier_numero_mesure
  <<~'TXT'.freeze
  \bar "" % pour que le premier numéro de mesure s'affiche
  TXT
end
# Il y avait ça, avant, ci-dessus
# \\set Score.currentBarNumber = ##{options[:mesure]}
# J’ai essayé de le mettre dans le \layout Score

def option_no_time
  case options[:time]
  when true then ''
  when nil, false  then '\\omit Staff.TimeSignature'
  else '\\time ' + options[:time]
  end
  # options[:time] ? '' : '\\omit Staff.TimeSignature'
end
def option_no_stem
  options[:no_stem] ? '\\override Voice.Stem.transparent = ##t' : ''
end

# @return le texte pour indiquer la tonalité
def option_tonalite
  if options[:key]
    options[:formated_key]
  else '' end
end

##
# Méthodes quand on doit transposer le fragment
def markin_transposition
  options[:transpose] ? "\\transpose #{options[:transpose]} " : "" 
end


private

  def translate_shortcuts_from_mus(str)
    
    str = str.gsub(/(?<mark>tie|slur|stem)Off/.freeze, '\k<mark>Neutral'.freeze)

    if options[:no_fingers]
      puts "L’option no_fingers est activtée".jaune
      str = str.gsub(REG_DOIGTE,EMPTY_STRING)
    else
      # Substitution de doigté
      str = str.gsub(REG_SUBSTITUTION_DOIGTE) do
        '%s\finger \markup \tied-lyric "%s~%s"'.freeze \
          % [$~[:pos], $~[:doigt1],$~[:doigt2]]
      end
    end

    return str
  end


  def translate_octaves_from_ms(str)
    # Les marques d'octave se font par \8ve, \15ve, \-15ve, \-8ve, \0ve
    str = str.gsub(/ \\(\-?(8|15|0))ve /) do
      mark = $1.freeze
      ' \\ottava #' + case mark
      when '8'    then '1'
      when '15'   then '2'
      when '-8'   then '-1'
      when '-15'  then '-2'
      when '0'    then '0'
      end + ' '
    end

    return str
  end

  def translate_armure_from_mus(str)
    return str unless str.match?(/(tune|key)/)
    # puts "str avant : #{str.inspect}".jaune
    str = str.gsub(/\\(?<mark>tune|key) (?<key>#{Parser::BlockCode::REG_TUNE}) /i) do
      k = $~[:key].freeze
      barres = ($~[:mark] == 'key' && k.match?(REG_PUR_TUNE)) ? ' ' : ' \bar "||" '
      barres + formate_tune(k) + ' '
    end
    # puts "str après : #{str.inspect}".bleu
    return str
  end

  def formate_tune(str)
    Parser::BlockCode.formate_tune(str)
  end

  def translate_keys_from_ms(str)
    # Les clés, qui peuvent être précisées par '\cle F' et '\cle G'
    # '\clef F3'
    str.gsub(/\\clef? ((?:F|G|UT)[1-5]?) /){
      mark_cle = $1.freeze
      "\\clef \"#{CLE_TO_CLE_LILY[mark_cle]}\" "
    }
  end

  def translate_percents_from_ms(str)
    str.gsub(/\{ (.+?) \}x([2-4]) /){
      "\\repeat percent #{$2} { #{$1} } "
    }
  end

  def translate_nuplets_from_ms(str)
    # Les triolets et autres quintolets qui peuvent 
    # s'écrire '3{note note note}', '5{note note note note note}'
    str.gsub(/([357])\{(.+?)\}/){
      notes = $2.strip.freeze
      deno  = $1.to_i.freeze
      sur   = deno - 1
      "\\tuplet #{deno}/#{sur} { #{notes} }"
    }    
  end


  # === LES TRILLES ===
  #
  # Les trilles sont marquées de deux façons générales différentes :
  # 
  #   1. Avec le code réduit ’\tr(...)’
  # 
  #   2. Avec les mots ’\startTr’ et ’\stopTr’ (en cas de trilles
  #      qui s’enchainent par exemple)
  # 
  def translate_trilles_from_ms(str)
    # Remplacer les marques \startTr et \stopTr
    str = str.gsub(/(?<pos>[\^_]?\\)(?<what>start|stop)Tr /.freeze, '\k<pos>\k<what>TrillSpan ')
    return str unless str.match?(REG_TRILL_START)
    # Si l’expression comporte des trilles longue (repérables à
    # leur écriture ’\tr(...)- ... \-tr’) on s’assure qu’elles aient
    # bien leur terminaison ’\-tr’
    if str.match?(REG_LONG_TRILL_START)
      offset_in   = -1
      offset_out  = -1
      begin
        while offset_in = str.index(REG_LONG_TRILL_START, offset_in + 1)

          # Si le décalage trouvé est maintenant inférieur à la marque
          # de fin de la trille, c’est qu’il manque une fermeture
          if offset_in < offset_out
            raise ERREUR[1700]
          end
          offset_out = str.index(REG_TRILL_END, offset_out + 1)
          
          # Si aucune marque de fin n’a été trouvée, on signale une
          # erreur d’écriture
          if not(offset_out)
            raise ERREUR[1700]
          end
        end #/while
      rescue Exception => e
        if str.length > 300
          offset_in = offset_in - 10
          offset_in = 0 if offset_in < 0
          str = str[offset_in..offset_in + 100]
        end
        raise "#{e.message} in ’#{str}’"
      end
    end
    # La formule complexe 'a \tr-(gis32 a) b \-tr'
    # Ou plutôt : \tr(a'1)- (gis32 a)\-tr b1 
    # qui doit donner : \afterGrace a'1\startTrillSpan { gis32[ a]\stopTrillSpan } b1
    # 
    # On peut avoir au départ '\tr(cis dis)' pour triller avec une note étrangère
    str = str.gsub(REG_TRILLE_WITH_TERM){
      seq = [] # pour construire le texte
      seq << '\afterGrace '
      notesdep = $~[:notesdep].freeze.split(' ')
      note_depart = notesdep.shift
      note_trilled = notesdep.count > 0 ? notesdep[0] : nil
      if note_trilled
        seq << '\pitchedTrill '
      end
      seq << note_depart
      seq << "#{$~[:pos]}\\startTrillSpan "
      if note_trilled
        seq << note_trilled + ' '
      end
      inter_notes   = $~[:internotes].freeze
      seq << inter_notes
      gnotes  = $~[:gnotes].freeze.split(' ')
      seq << '{ '
      seq << gnotes.shift
      if gnotes.count > 0
        seq << '[ ' + gnotes.join(' ') + ']'
      end
      seq << '\stopTrillSpan }'
      # texte à retourner
      # puts "SEQ = #{seq.join('')}"
      seq.join('')
    }
    str = str.gsub(/\\(?<position>[\^_])?tr\((?<sujet>.*?)\) /){
      # n = $1.freeze.split(' ')
      n   = $~[:sujet].freeze.split(' ')
      pos = ($~[:position]||'').freeze
      if n.count == 1
        n.first + ' ' + pos + '\trill ' # ne pas oublier l'espace
      else
        # On a donné la note avec laquelle il faut triller
        '\pitchedTrill ' + n[0] + '\startTrillSpan ' + n[1] + '\stopTrillSpan ' # ne pas oublier l'
      end
    }
    str.gsub(/\\([\^_])?tr\((.*?)\)\-/, '\2 \1\startTrillSpan')
      .gsub(/\\\-tr/, '\stopTrillSpan')
      .gsub(/\\([\^_])?tr\((.*?)\)/, '\2 \1\trill')
  end


  # === LES GRACES NOTES ===
  # Notation : \gr(<note>) <note>
  # Exemple  : '\gr(b8) a g16 f e1' qui va faire de b8 une grâce
  # <note>:
  #   - peut se finir par '/-'  => acciaccatura
  #   - peut se finir par '-'   => appoggiatura
  #   - peut se finir par '/'   => shaded grace
  #   - peut contenir une ou plusieurs notes
  def translate_graces_notes_from_ms(str)
    str.gsub(/\\gr\((?<inner>.*?)\)/.freeze) do
      note = $~[:inner].freeze # Peut-être plusieurs notes
      only_notes = note.sub(/[\/\-]{1,2}$/,'').split(' ')
      # puts "only_notes = #{only_notes.inspect}"
      first_note = only_notes.shift
      all_notes = if only_notes.count > 0 
        '{ ' + first_note + ' ' + only_notes.join(' ') + ' }'
      else
        first_note
      end
      seq = if note.end_with?('/-')
        '\acciaccatura'
      elsif note.end_with?('/')
        '\slashedGrace'
      elsif note.end_with?('-')
        '\appoggiatura'
      else
        '\grace'
      end + ' ' + all_notes
      # puts "SEQ = #{seq}"
      seq
    end
  end

  # Changement de portée
  #  Phaut => \change Staff = "up"
  #  Pbas => \change Staff = "down"
  def translate_staff_change_from_ms(str)
    str = str.gsub(/(Phaut|\\up)\b/, '\change Staff = "haute"').gsub(/(Pbas|\\down)\b/, '\change Staff = "basse"')
  end

end #/<< self
end #/Lilypond
end #/MusicScore
