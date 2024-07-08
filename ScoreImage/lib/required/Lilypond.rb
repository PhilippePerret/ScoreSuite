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

class << self

attr_reader :options

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
def compose(code, options)
  rationnalise_options(options)
  sep = "\n% --- %\n" # délimiteur de partie
  beautify_code(header + sep + body(code, options[:system]) + sep + footer)
end

# Méthode qui met en forme le texte du code pour qu’il soit plus
# lisible, mieux présenter.
def beautify_code(code)
  ary = []
  @indent_len = 0
  @indent_str = ""
  next_indent_len = nil # pour simplifier l’écriture (cf. ci-dessous)
  code.split("\n").each do |line|
    line = line.strip
    next if line.empty?
    puts "line: #{line}".bleu
    if line.end_with?('<<') || line.end_with?('{')
      next_indent_len = true
    elsif line.end_with?('>>')
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
  return ary.join("\n")
end

def crementize_indentation(adding)
  @indent_len += adding
  @indent_str =  "  " * @indent_len
  puts "indent: #{@indent_len}".orange
end

def rationnalise_options(options)
  # puts "options = #{options}"
  #
  # Si les clés des portées sont définies, il faut les dispatcher
  #
  if options.key?('staves_keys')
    options['staves_keys'] = options['staves_keys'].split(',').collect{|n|n.strip}.reverse
  end
  #
  # Si les noms des portées sont définies, il faut les dispatcher
  #
  if options.key?('staves_names')

    # TODO Maintenant, on peut avoir des regroupements forcés, avec
    # des croches ([…]). Il faut les traiter,
    # mais comment ? Il faudrait en fait arriver à quelque chose
    # comme : [[A,B], {C,D,E}]
    options['staves_names'] = options['staves_names'].split(',').collect{|n|n.strip}.reverse
  
    # Est-ce que ça correspond à un système avec piano ?
    if options['staves_keys'] && options['staves_keys'].count == 3 && options['staves_names'][1..2].join('').downcase == "pianopiano"
      options.merge!(system: 'sonate_with_piano')
    end
  end

  # Depuis JUILLET 2024, on analyse mieux les noms pour tenir compte
  # des éventuels groupements de portées
  if options.key?('staves_names')

    # Données générales
    options.merge!(staves_data: {
      staves: [], group_type: ""
    })

    # Étude du groupe général
    name1 = options['staves_names'][0]
    if name1
      letter1 = name1[0]
      if ['[','{'].include?(letter1)
        # Pour que ce soit vraiment une marque de groupe principal
        # (comprenant toutes les portées) il faut que le dernier nom
        # se termine par le dernier signe attendu
        expected_last_sign = letter1 == '[' ? ']' : '}'

        if options['staves_names'][-1][-1] == expected_last_sign
          letter2 = name1[1]
          # Le dernier nom
          options['staves_names'][-1] = options['staves_names'][-1][0..-2]
          # La mark du groupe
          group_mark = letter1 == '[' \
              ? ( letter2 == '-' ? 'ChoirStaff' : 'StaffGroup') \
              : ( letter2 == '-' ? 'GrandStaff' : 'GrandStaff')
          options[:staves_data][:group_type] = '\\new %s '.freeze % [group_mark]
          # Il faut corriger les noms
          name1 = name1[1..-1].strip
          name1 = name1[1..-1].strip if letter2 == '-'
          options['staves_names'][0] = name1
        end
      end
    end

    # Étude des sous-groupes
    # ----------------------
    # Maintenant qu’on a retiré les "[" ou "{" qu’on pouvait trouver
    # en tout début et en toute fin de la définition des noms, on 
    # peut étudier chaque nom pour trouver les sous-groupes éventuels
    # 
    options['staves_names'].each_with_index do |sname, idx|
      skey       = options['staves_keys'][idx] || 'G'.freeze
      group_mark = nil
      end_group  = false

      if sname
        letter1 = sname[0]
        letter2 = sname[1]
        letterx = sname[-1]
        if ['[','{'].include?(letter1)
          sname = sname[1..-1]
          group_mark = 
            if letter2 == '-' 
              # Barres de mesure non reliées
              sname = sname[1..-1]
              letter1 == '[' ? "ChoirStaff" : "GrandStaff"
            else
              # Barres de mesure reliées
              letter1 == '[' ? "StaffGroup" : "GrandStaff"
            end
        elsif [']','}'].include?(letterx)
          # Fermeture du système courant
          end_group = true
          sname = sname[0..-2]
        end
      end

      # Données pour cette portée
      staff_data = {
        key:              skey, 
        name:             sname, 
        group_mark:       group_mark, 
        is_ending_group:  end_group
      }
      options[:staves_data][:staves] << staff_data

    end
  end

  #
  # Si les clés ou les noms des portées sont définies, il faut
  # impérativement avoir les clés ET les noms. On ajoute donc la 
  # liste manquante.
  #
  if options.key?('staves_keys') && !options.key?('staves_names')
    options.merge!('staves_names' => [])
    # On met toujours la valeur de ’staves’ au nombre de clés
    options.merge!('staves' => options['staves_keys'].count)
  elsif options.key?('staves_names') && !options.key?('staves_keys')
    options.merge!('staves_keys' => [])
    # On met toujours la valeur de ’staves’ au nombre de noms
    options.merge!('staves' => options['staves_names'].count)
  end



  #
  #
  # On ajoute les clés symboliques (donc on aura les deux versions
  # des clés dans la table)
  #
  @options = options.to_sym
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
    send("system_for_#{system}", code)
  when Integer 
    system_for_x_staves(code)
  else
    raise EMusicScore.new("La valeur '#{system}' pour 'system' est intraitable… (inconnue)")
  end
end

def system_for_solo(code)
  <<~LILYPOND
  <<
  #{markin_transposition}\\relative c' {
    #{option_no_time}
    #{option_no_barre}
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
  \\new PianoStaff #{mark_staff_name(params)}<<
    \\new Staff = "haute" {
      % enforce creation of all contexts at this point of time
      \\clef "treble"
      #{markin_transposition}\\relative c' {
        #{option_no_time}
        #{option_no_barre}
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
        #{option_no_barre}
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
# (cf. https://lilypond.org/doc/v2.24/Documentation/notation/displaying-staves#grouping-staves)
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
# clés, on crée un ’options['staves_data']’ qui contient les données
# analysées (@note : ’staves_data’ a été choisi pour ne pas supprimer
# ’staves_names’ et ’staves’ — le nombre de portées — qui sont peut-
# être utilisés ailleurs)
# C’est fait dans la méthode #rationnalise_options de ce module.
# 
def system_for_x_staves(code)
  staves_data = options[:staves_data]
  c = []
  c << "\\score {"
  c << "  #{staves_data[:group_type]}<<"
  code.each_with_index do |code_portee, idx|
    staff_data = staves_data[:staves][idx]
    puts "code_portee : #{code_portee.inspect}".jaune
    puts "staff_data  : #{staff_data.inspect}".orange
    c << "    \\new #{staff_data[:group_mark]} <<" if staff_data[:group_mark]
    c << staff_for(code_portee, {name: staff_data[:name], key: staff_data[:key]})
    c << "  >>" if staff_data[:is_ending_group]
  end
  c << "  >>"
  c << "}"
  c = c.join("\n")
  puts "------------\nCODE LILYPOND:\n#{c}\n---------------".jaune
  return c
end
# Avant Juillet 2024
# def system_for_x_staves(code)
#   c = []
#   c << "\\score {"
#   c << "  \\new StaffGroup <<"
#   code.each_with_index do |code_portee, idx|
#     c << staff_for(code_portee, {name:options['staves_names'][idx], key:options['staves_keys'][idx]})
#   end
#   c << "  >>"
#   c << "}"
#   return c.join("\n")
# end
#/system_for_x_staves

def system_for_quatuor(code)
  <<-LILYPOND
\\score {
  \\new StaffGroup <<
    #{staff_for(code[0], {name:'Violon 1'})}
    #{staff_for(code[1], {name:'Violon 2'})}
    #{staff_for(code[2], {name:'Alto',  key: 'alto'})}
    #{staff_for(code[3], {name:'Cello', key: 'bass'})}
  >>
}
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
  \\new Staff #{mark_staff_name(params)} {
    #{markin_transposition}\\relative c#{relative} {
      #{staff_cle}
      #{option_no_time}
      #{option_no_barre}
      #{option_no_stem}
      #{option_tonalite}
      #{option_num_mesure}
      #{code}
    }
  }
  LILYPOND
end

# AVANT JUILLET 2024
# (la grande différence est l’utilisation ici d’une \new Voice alors
#  que ça n’est pas utile)
# def staff_for(code, params)
#   relative = case params[:key]
#   when 'F'    then ''
#   when /^UT/  then "'"
#   else "''"
#   end
#   staff_cle = params[:key] ? "\\clef #{CLE_TO_CLE_LILY[params[:key]]}\n" : ""
#   <<~LILYPOND
#   \\new Staff #{mark_staff_name(params)}<<
#     \\new Voice #{markin_transposition}\\relative c#{relative} {
#       #{staff_cle}
#       #{option_no_time}
#       #{option_no_barre}
#       #{option_no_stem}
#       #{option_tonalite}
#       #{option_num_mesure}
#       #{code}
#     }
#   >>
#   LILYPOND
# end

def mark_staff_name(params)
  if params[:name]
    '\with { instrumentName = "%s" } '.freeze % params[:name]
  else 
    '' 
  end
end

def header
  <<-LILYPOND
\\version "#{LILYPOND_VERSION}"

#(set-default-paper-size #{option_page_format})

\\paper{
  indent=0\\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f

  % Essai d’espacement entre les systèmes si nécessaire
  #{option_vspace_between_systems}
}

\\layout {
  \\context {
    #{option_staves_vspace}
    #{option_proximity}
    #{option_no_numero_mesure}
  }
  #{code_extraction_fragment}
}

  LILYPOND
end
#/header



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
  <<-LILYPOND

#{option_espacements}

  LILYPOND
end
#/footer

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
    <<-TEXT
    \\Staff
      \\override VerticalAxisGroup
      .staff-staff-spacing.basic-distance = #{options[:staves_vspace]}
    TEXT
  else "" end
end

def option_proximity
  if options[:proximity]
    <<-TEXT
    \\score
      \\override SpacingSpanner.common-shortest-duration = #(ly:make-moment 1/#{options[:proximity]})
    TEXT
  else "" end
end

def option_page_format
  options[:page] ||= '"a0" \'landscape'
  options[:page] = "\"#{options[:page]}\"" unless options[:page].start_with?('"')
  return options[:page].downcase
end
def option_no_numero_mesure
  if options[:mesure] === false
    '\\remove "Bar_number_engraver"'
  end
end
def option_num_mesure
  if options[:mesure] === false
    # '\\omit BarNumber'
    ''
  else
    options[:mesure] ? premier_numero_mesure : ""
  end
end
def premier_numero_mesure
  <<-TXT
\\set Score.barNumberVisibility = #all-bar-numbers-visible
\\set Score.currentBarNumber = ##{options[:mesure]}
\\bar "" % pour qu'il s'affiche
  TXT
end
def option_no_time
  case options[:time]
  when true then ''
  when nil, false  then '\\omit Staff.TimeSignature'
  else '\\time ' + options[:time]
  end
  # options[:time] ? '' : '\\omit Staff.TimeSignature'
end
def option_no_barre
  options[:barres] ? '' : '\\override Score.BarLine.break-visibility = #all-invisible'
end
def option_no_stem
  options[:no_stem] ? '\\override Voice.Stem.transparent = ##t' : ''
end
def option_tonalite
  return '' if not options[:key]
  tune = options[:key]
  if tune.length == 2
    note, nature = options[:key].split('')
  else
    note, nature = options[:key].split('')
  end
  alter  = case nature
  when '#' then 'is'
  when 'b' then 'es'
  when 'es', 'is' then nature
  else ''
  end
  "\\key #{note.downcase}#{alter} \\major"
end
def option_espacements
  subdiv = 
  if options[:biggest_hspace]
    256
  elsif options[:big_hspace]
    128
  elsif options[:hspace]
    64
  elsif options[:mini_hspace]
    32
  else
    nil
  end
  return '' if subdiv.nil?
  <<-LPOND
\\layout {
 \\context {
   \\score
   \\override SpacingSpanner.base-shortest-duration = #(ly:make-moment 1/#{subdiv})
 }
}

  LPOND
end


##
# Méthodes quand on doit transposer le fragment
def markin_transposition
  options[:transpose] ? "\\transpose #{options[:transpose]} " : "" 
end


# --- MÉTHODES DE TRANSLATION DU CODE MUSIC-SCORE VERS LILYPOND ---
##
# = main =
#
# Traduit un code music-score en un code Lilypond conforme
#
def translate_from_music_score(str)
  str = " #{str} "

  str = translate_octaves_from_ms(str)

  # str = translate_barres_from_ms(str)

  str = translate_armure_from_ms(str)

  str = translate_keys_from_ms(str)

  str = translate_percents_from_ms(str)

  str = translate_nuplets_from_ms(str)

  str = translate_trilles_from_ms(str)

  str = translate_graces_notes_from_ms(str)

  str = translate_staff_change_from_ms(str)

  # On échappe toutes les balances
  str = str.gsub(/\\/, '\\')

  return str
end

private

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

  # Maintenant, les barres sont traitées dans 
  # BlockCode_mus_code_module.rb
  # def translate_barres_from_ms(str)
  #   # Les barres de reprise sont simplement mises en '|:', ':|:' ou ':|'
  #   str = str.gsub(/:\|:/, '_DOUBLE_BARRES_REPRISE_')
  #         .gsub(/\|:/, '\bar ".|:"')
  #         .gsub(/:\|/, '_BARRES_REPRISE_FIN_')
  #         .gsub(/\|\./, '\bar "|."')
  #         .gsub(/\|\|/, '\bar "||"')
  #   str = str.gsub(/_DOUBLE_BARRES_REPRISE_/, '\bar ":|.|:"')
  #   str = str.gsub(/_BARRES_REPRISE_FIN_/, '\bar ":|."')
  #   return str
  # end

  def translate_armure_from_ms(str)
    str = str.gsub(/\\(?:tune|key) ([a-g])(es|is|d|b)? /i) do
      ton   = $1.downcase.freeze
      alte  = ($2||'').freeze
      alte = case alte
      when 'b' then 'es'
      when 'd' then 'is'
      else alte
      end
      "\\key #{ton}#{alte} \\major "
    end
    return str
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


  def translate_trilles_from_ms(str)
    # === LES TRILLES ===
    #
    # La formule complexe 'a \tr-(gis32 a) b \-tr'
    # Ou plutôt : \tr(a'1)- (gis32 a)\-tr b1 
    # qui doit donner : \afterGrace a'1\startTrillSpan { gis32[ a]\stopTrillSpan } b1
    # 
    # On peut avoir au départ '\tr(cis dis)' pour triller avec une note étrangère
    str = str.gsub(/\\tr\((.*?)\)\-(.*?)\((.*?)\)\\\-tr/){
      seq = [] # pour construire le texte
      seq << '\afterGrace '
      notesdep = $1.freeze.split(' ')
      note_depart = notesdep.shift
      note_trilled = notesdep.count > 0 ? notesdep[0] : nil
      if note_trilled
        seq << '\pitchedTrill '
      end
      seq << note_depart
      seq << '\startTrillSpan '
      if note_trilled
        seq << note_trilled + ' '
      end
      inter_notes   = $2.freeze
      seq << inter_notes
      gnotes  = $3.freeze.split(' ')
      seq << '{ '
      seq << gnotes.shift
      if gnotes.count > 0
        seq << '[ ' + gnotes.join(' ') + ']'
      end
      seq << '\stopTrillSpan }'
      # texte à retourner
      puts "SEQ = #{seq.join('')}"
      seq.join('')
    }
    str = str.gsub(/\\tr\((.*?)\) /){
      n = $1.freeze.split(' ')
      if n.count == 1
        n.first + ' \trill ' # ne pas oublier l'espace
      else
        # On a donné la note avec laquelle il faut triller
        '\pitchedTrill ' + n[0] + '\startTrillSpan ' + n[1] + '\stopTrillSpan ' # ne pas oublier l'
      end
    }
    str.gsub(/\\tr\((.*?)\)\-/, '\1 \startTrillSpan')
      .gsub(/\\\-tr/, '\stopTrillSpan')
      .gsub(/\\tr\((.*?)\)/, '\1 \trill')
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
    str.gsub(/\\gr\((.*?)\)/) do
      note = $1.freeze # Peut-être plusieurs notes
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
    str = str.gsub(/(Phaut|\\up)/, '\change Staff = "haute"').gsub(/(Pbas|\\down)/, '\change Staff = "basse"')
  end

end #/<< self
end #/Lilypond
end #/MusicScore
