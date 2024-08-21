# encoding: UTF-8
# 
# Fonctionnement en recherchant les notes (et les accords, les triolets, etc.)
# Il faut connaitre la forme ultime d’une note.
# C’est d’abord, obligatoirement, une lettre qui ne peut être que
# précédée par un ’<’ dans les accords.
# Par facilité, on pourrait d’abord traiter les accords, les rempla-
# cer par leurs notes isolées :
#   <c e g> => c e g
# mais surtout :
#   <c e g>4. => c4. e4. g4.
# 
# 
# Ce n’est pas forcément une espace ou la fin à la fin d’un note,
# on peut aussi trouver :
#   a\fermata  b_\prall c^\markup
# Donc ’\’, ’_’ et ’^’ sont aussi des délimiteurs de notes.
# 
class MusicScore

SEP = (' ' * 2).freeze

class Statistiques

  class StatNote
    class << self

      attr_reader :notes_groups

      # Pour les max dans l’affichage
      attr_accessor :note_max_len, :count_max_len, :duree_max_len

      # Initialisation, au départ du calcul des statistiques
      def init
        @notes = []
        @current_duration = '4'
        @notes_groups = {}
        self.count_max_len = 0
        self.duree_max_len = 0
        self.note_max_len  = 0
      end

      # Ajoute l’instance +inote+ à la liste des notes de la classe
      def add(inote)
        @notes << inote
        # Définition de la durée ou récupération de la nouvelle durée
        check_note_duration(inote)
        # Ajoute aussi la note à son groupe de notes. 
        # @note : il faut le faire après le check de la durée, car
        # le groupe en a besoin.
        add_to_group_note(inote)
      end

      def add_to_group_note(inote)
        unless @notes_groups.key?(inote.note_abs)
          @notes_groups.merge!(inote.note_abs => StatGroupNote.new(inote.note_abs, inote.formated_note))
        end
        @notes_groups[inote.note_abs].add(inote)
      end

      # Lors de l’ajout de la note à la liste, on lui affecte la
      # dernière durée rencontrée si elle n’en a pas, ou on récupère
      # sa durée pour la mettre en durée courante si elle est définie
      def check_note_duration(inote)
        if inote.duration
          @current_duration = inote.duration.dup
        else
          inote.duration=(@current_duration)
        end
        if @notes[-2] && @notes[-2].sub_duration_to_next?
          inote.duration_sub= @notes[-2].abs_duration
        end
      end

    end #/<< self


    attr_reader :data

    # Valeur absolue, en secondes, qu’il faut retirer à la note (par
    # exemple quand elle est précédée d’une "grace note")
    attr_accessor :duration_sub

    # Instantiation d’une nouvelle note
    # -------------
    # 
    # @param data_note [Array]
    #   Liste contenant [<nom note>, <alteration>, <durée>, <points>, <tilde>]
    # 
    def initialize(data_note)
      @data         = data_note
      # Par défaut, on ne doit retirer aucune durée à la note. Mais
      # ça peut arriver avec les petites notes (graces notes)
      @duration_sub = 0
    end

    # Par exemple "bes", "a" ou "cisis"
    def note_abs
      @note_abs ||= "#{note_name}#{alteration}".freeze
    end


    # = Helper Methods =

    # Nom pour les fichiers (c# plutôt que cis)
    # 
    # @note
    #   Maintenant, tient compte de la transposition
    # 
    def formated_note
      @formated_note ||= "#{note_name_transposed}#{f_alteration}".freeze
    end

    def note_name_transposed
      @note_name_transposed ||= begin
        if Statistiques.transposition?
          Statistiques.transpose("#{note_name}#{f_alteration}")
        else
          note_name
        end
      end
    end

    # Pour les accords
    def as_note
      @as_note ||= "#{note_abs}#{duration}#{'~' if linked?}"
    end

    def f_alteration
      @f_alteration ||= begin
        case alteration
        when 'is'   then '#'
        when 'isis' then 'x'
        when 'es'   then 'b'
        when 'eses' then 'bb'
        else ''
        end
      end
    end

    # = Fixed Data Methods =

    def duration=(v)      ; @duration = v     end

    def is_linked(v = true)
      data[5]   = v ? '~' : nil
      @islinked = v
    end


    # = Volatile Data =

    def sub_duration_to_next?; data[4] == 'STN' end

    def linked?     ; @islinked    ||= data[5] == '~' end
    
    # @return [Float] La durée musicale "absolue", c’est-à-dire 
    # exprimée en noires. Par exemple, une noire vaut 1, une ronde
    # vaut 4, une ronde pointée vaut 6 (4 + 4/2), une ronde pointée 
    # vaut 7 (4 + 4/2 + (4/2)/2), etc.
    def abs_duration
      @abs_duration ||= begin
        dur, prol = duration.match(/([0-9]+)(\.*)?/)[1..2]
        dur = 4.0 / dur.to_i
        c = dur.dup
        prol.length.times { dur += (c = c / 2) }
        dur - duration_sub
      end
    end

    # # = Fixed Data = #

    def note_name   ; @note_name   ||= data[0].freeze end
    def alteration  ; @alteration  ||= data[1].freeze end
    def octave      ; @octave      ||= data[2].freeze end
    def duration    ; @duration    ||= data[3].freeze end
  end



  # Instance pour chaque note : c, cis, cisis, d, des, deses, etc.
  class StatGroupNote

    attr_reader :note, :note_formated
    def initialize(note_abs, note_formated)
      @note           = note_abs
      @note_formated  = note_formated
      @notes          = []
    end

    # = Helper Methods =

    # Pour afficher le résultat sous forme de ligne de texte
    def text_line
      @text_line ||= begin
        "#{note_formated.ljust(StatNote.note_max_len)}#{SEP}#{count.to_s.ljust(StatNote.count_max_len)}#{SEP}#{"#{duree_secondes} s".to_s.rjust(StatNote.duree_max_len + 2)}\n".freeze
      end
    end

    # Pour afficher le résultat sous forme de ligne CSV
    def csv_line
      "#{note_formated};#{count};#{duree_secondes}\n"
    end


    # = Functional Methods =

    def add(inote)
      @notes << inote
    end


    # = Calc Methods =

    # Le nombre d’emploi de cette note, donc par exemple le nombre 
    # de ’cisis’ ou de ’bes’
    # La méthode doit tenir compte du fait que certaines notes sont
    # liées à d’autres.
    def count
      @count ||= begin
        @notes.reject { |n| n.linked? }.count.freeze
      end
    end
    # La durée d’emploi de cette note, exprimée en secondes
    def duree_secondes
      @duree_secondes ||= (duration * Statistiques.duree_noire).round(2)
    end
    # La durée musicale d’emploi de cette note, exprimées en noires
    def duration
      @duration ||= begin
        @notes.sum(&:abs_duration)
      end
    end

  end
  # /class StatGroupNote


  attr_reader :music_score
  attr_reader :lines
  attr_reader :main_options
  attr_reader :tempo

  def initialize(music_score, lines, **main_options)
    @music_score  = music_score
    @lines        = lines
    @main_options = main_options
    # Indiquer s’il y a une transposition
    self.class.transposition = main_options[:transpose]
  end


  # class Statistique (Classe)
  class << self
    attr_reader :tempo_noire, :is_ternaire, :duree_noire

    def tempo_noire ; @tempo_noire end
    def is_ternaire ; @is_ternaire end
    def duree_noire ; @duree_noire end
    def calc_duree_noire(tempo)
      @tempo_noire = 
        if tempo.end_with?('T')
          tempo[0...-1]
        else
          tempo
        end
      @is_ternaire = tempo.end_with?('T')
      @duree_noire = begin
        durn = 60.0 / tempo_noire.to_i
        durn = (2.0 / 3) * durn if is_ternaire
        durn
      end
    end

    attr_accessor :transpositor

    def transposition?
      :TRUE == @hastransposition
    end

    def transposition=(value)
      return if value.nil?
      self.transpositor = Transposition.new(value)
      @hastransposition = :TRUE
    end

    def transpose(note)
      self.transpositor.transpose(note)
    end

  end #/ class << self



  # = main =
  # 
  # PRODUIRE LES STATISTIQUES
  # 
  def produce
    # puts "à partir de #{lines}"
    mfile = music_score.mus_file

    # Le tempo est-il défini ? Sinon interrompre le programme
    # pour le demander
    tempo || return
    self.class.calc_duree_noire(tempo)
    # puts "Tempo : #{tempo.inspect}"

    StatNote.init

    # On parse et analyse chaque ligne de code
    lines.each { |line| parse_line(line) }

    # 
    # 4 fichiers
    #   1 : par ordre des notes
    #   2 : par durée
    #   3 : par nombre d’itérations de note
    #   4 : le tout au format CSV
    # 
    fpath_not = File.join(folder, "#{mfile.affixe}-stats-per-note.txt")
    File.delete(fpath_not) if File.exist?(fpath_not)
    fpath_dur = File.join(folder, "#{mfile.affixe}-stats-per-duree.txt")
    File.delete(fpath_dur) if File.exist?(fpath_dur)
    fpath_cpt = File.join(folder, "#{mfile.affixe}-stats-per-count.txt")
    File.delete(fpath_cpt) if File.exist?(fpath_cpt)
    fpath_csv = File.join(folder, "#{mfile.affixe}-stats.csv")
    File.delete(fpath_csv) if File.exist?(fpath_csv)


    # Déterminer les longueurs maximales pour les nombres de notes
    # et les durées.
    # (simplement pour avoir des tableaux plus beaux)
    StatNote.notes_groups.each do |note, notes_group|
      if StatNote.note_max_len < notes_group.note.length
        StatNote.note_max_len = notes_group.note.length.freeze
      end
      if StatNote.count_max_len < notes_group.count.to_s.length
        StatNote.count_max_len = notes_group.count.to_s.length.freeze
      end
      if StatNote.duree_max_len < notes_group.duree_secondes.to_s.length
        StatNote.duree_max_len = notes_group.duree_secondes.to_s.length.freeze
      end
    end


    StatNote.notes_groups.each do |note, notes_group|
      puts "- #{notes_group.text_line}"
    end

    ary_groups_notes = StatNote.notes_groups.values.sort_by { |n| n.note }

    total_notes = ary_groups_notes.sum(&:count)
    total_duree = ary_groups_notes.sum(&:duree_secondes)
    puts "total_duree brute: #{total_duree}"

    mns = total_duree.to_i / 60
    scs = total_duree - mns * 60
    total_duree = []
    total_duree << "#{mns} mn" if mns > 0
    total_duree << "#{scs} s"
    total_duree = total_duree.join(' ')

    # Tableau classé par durée
    # + Tableau classé par nombre
    #
    tableau_per_duree = ary_groups_notes.sort_by{|dn| -dn.duration}
    tableau_per_count = ary_groups_notes.sort_by{|dn| -dn.count   }

    begin

      rf_not = File.open(fpath_not,'a')
      rf_dur = File.open(fpath_dur,'a')
      rf_cpt = File.open(fpath_cpt,'a')
      rf_csv = File.open(fpath_csv,'a')

      rf_csv.write "NOTE;NOMBRE;DURÉE\n"

      rf_cpt.write "Nombre total de notes : #{total_notes}\n"
      rf_dur.write "Durée totale : #{total_duree}\n"

      ary_groups_notes.each do |snote|
        rf_not.write snote.text_line
        rf_csv.write snote.csv_line
      end

      tableau_per_duree.each do |snote|
        rf_dur.write snote.text_line
      end

      tableau_per_count.each do |snote|
        rf_cpt.write snote.text_line
      end

    rescue Exception => e

      puts e.message.rouge
      puts e.backtrace.join("\n").rouge

    ensure
      rf_not.close
      rf_dur.close
      rf_csv.close
      rf_cpt.close
    end
  end



  def tempo
    @tempo ||= begin
      music_score.options[:tempo] || CLI.options[:tempo] || begin
        puts <<~TEXT.orange
        Pour effectuer les statistiques, j’ai besoin de connaitre le tempo
        (moyen) de la pièce.
        Il peut être défini dans le fichier .mus lui-même, à l’aide de
        l’option ’--tempo <valeur>’ ou en ligne de commande à l’aide du
        code ’-t/--tempo=<valeur>’.

        <valeur> est le tempo à la noire (par exemple, avec 60, une noire
        aura une durée d’une seconde).

        Pour les RYTHMES TERNAIRE, ajouter 'T' au tempo.
        Par exemple ’-t=60T’ ou ’--tempo=60T’ ou ’--tempo 60T’ dans le 
        fichier .mus signifiera un tempo de 60 à la noire pointée (quand
        on est en 6/8 par exemple).
        TEXT
        # exit 12
      end
    end
  end

  def parse_line(line, add_notes = true)

    puts "Line à parser : #{line.inspect} #{' (sans ajout de note)' if !add_notes}".jaune

    # Pour pouvoir utiliser les espaces comment délimiteurs partout
    line = " #{line} "

    # On retire toutes les expressions lilypond qui peuvent comporter
    # des notes, à commencer par les \relative <note>
    line = epure_lily_expressions_with_notes_in(line)

    # Traitement des répétitions
    line = traitement_des_repetitions(line) 

    # On "sort" toutes les notes de leurs accords
    line = decompose_chords_in(line)

    # Traitement spécial des appogiatures
    line = traitement_des_appoggiatura_in(line)

    # ======================================= #
    # ===     RÉCUPÉRATION DES NOTES      === #
    # ======================================= #
    verbose? && puts("Line avant scan complet: #{line.inspect}".bleu)
    notes_scaned = line.scan(REG_NOTE_DUREE)
    verbose? && puts("Scan complet: #{notes_scaned.to_a}")
    notes_scaned.map do |data_note|
      # puts "data_note = #{data_note}".bleu
      # exit 12
      inote = StatNote.new(data_note)
      StatNote.add(inote) if add_notes
      inote
    end

  end

  # Traite les appogiatures (pour pouvoir réduire leur durée et
  # la soustraire à la note suivante)
  # 
  def traitement_des_appoggiatura_in(line)
    return line unless line.match?(/\\gr\(/.freeze)

    line = line.gsub(REG_GRACE_NOTE) do
      note        = $~[:note]
      alter       = $~[:alter]
      duration    = $~[:duration]
      is_slashed  = $~[:slash] == '/'
      is_linked   = $~[:link] == '-'
      if is_slashed
        duration = "#{(duration||4).to_i * 2}STN"
      end
      "#{note}#{alter}#{duration}"
    end

    return line  
  end


  # Traite les répétitions dans la ligne, car elles sont traitées en tant que
  # telles
  # 
  # Une répétition peut avoir ces formes connues :
  # 
  #   - un ’\bar ".|:"’ à la fin d’une partie à reprendre
  #   - un ’\bar ".|:" ... \bar ":|."’ autour des notes à reprendre
  #   - un ’\repeat unfold 3 { ... }, répétition (avec traitement particulier des octaves)
  #   - un ’\\repeat volta 2 { ... }, répétition sans alternative
  #   - un ’\\repeat volta 2 { c4 d e f  \\alternative { \\volta 1 { e2 d } \\volta 2 { d2 c } } }’, répétition avec alternative
  #   - autre ?
  def traitement_des_repetitions(line)
    line = line.gsub(/(?:\\bar "\.\|\:")?(?<contenu>.*?)(?:\\bar "\:\|\.")/) do
      contenu = $~[:contenu].strip.freeze
      " #{contenu} #{contenu}"
    end

    while line.match?(REG_START_REPEAT_MARK)

      line.match(REG_START_REPEAT_MARK)
      nombre_fois = $~[:fois].to_i
      # puts "nombre_fois: #{nombre_fois.inspect}"

      pre_offset = line.index(REG_START_REPEAT_MARK)
      offset = pre_offset + 15
      # puts "offset: #{offset}".bleu

      if (post_offset = line.index(/\\alternative/.freeze, offset) )

        contenu_repeat = line[offset...post_offset]

      else

        # On cherche la parenthèse de fin
        # Pour ce faire, on parcourt la ligne à partir d’offset 
        # jusqu’à trouver ce "}", en sachant qu’on pourra rencontrer
        # des "{" qui devront être refermés
        nombre_parentheses_ouvertes = 0
        len = 0
        # On cherche la parenthèse ouverte
        until nombre_parentheses_ouvertes == 1
          lettre = line[offset + len]
          if lettre == '{'
            nombre_parentheses_ouvertes += 1
          elsif lettre.nil?
            break
          end
          len += 1
        end
        contenu_repeat = []
        until nombre_parentheses_ouvertes == 0
          lettre = line[offset + len]
          if lettre == '{'
            nombre_parentheses_ouvertes += 1
          elsif lettre == '}'
            nombre_parentheses_ouvertes -= 1
          else
            contenu_repeat << lettre
          end
          len += 1
        end
        contenu_repeat  = contenu_repeat.join('')
        post_offset     = offset + len
      end
    
      # puts "post_offset: #{post_offset.inspect}".bleu
  
      # On remplace pour ne plus avoir \repeat
      line = line[0..pre_offset] + (" #{contenu_repeat}" * nombre_fois) + line[post_offset..-1]
      # puts "Line restant: #{line}"
    
    end

    return line
  end

  REG_START_REPEAT_MARK = /\\repeat (?:volta|unfold) (?<fois>[0-9]+)/.freeze

  # Retire les ’\relative <note><octave>’ et autre \transpose
  # 
  # @note
  #   Remarquer l’astuce ici : on n’a pas besoin de retirer toute
  #   la note, avec ses octaves et ses altérations puisque le simple
  #   retrait de la note (a-g) empêchera d’y voir une note, dans la
  #   nouvelle façon de procéder
  def epure_lily_expressions_with_notes_in(line)
    line = line.gsub(/(fixed|relative) [a-g]/,'')
    line = line.gsub(/tune [a-g]/,'')
    line = line.gsub(/transpose #{REG_NOTE} #{REG_NOTE}/,'')
    return line
  end

  # Méthode qui transforme "<c e g>4." en "<c4. e4. g4.>" dans 
  # la ligne de code mus +line+
  def decompose_chords_in(line)

    return line unless line.match?(REG_MAYBE_CHORD)

    verbose? && puts("Line avant décomposition accords: #{line.inspect}")

    line = line.gsub(REG_CHORD) do
      chord_exp = $~[:chord_exp]
      duration  = $~[:duration]
      is_linked = $~[:linked] == '~'
      chord_notes = parse_line(chord_exp, false)
      # Le false ci-dessus permet de ne pas ajouter les notes au
      # cours du parsing. Elles seront ajoutées à l’analyse de la
      # ligne qui contient cet accord. Ici, on ne fait que remplacer
      # les accords par les notes.
      if is_linked
        chord_notes.each { |n| n.is_linked }
      end
      if duration
        chord_notes.each { |n| n.duration = duration }
      end
      # On reconstitue une portion de ligne
      chord_notes.map { |n| n.as_note }.join(' ')
    end

    verbose? && puts("Line APRÈS décomposition accords: #{line.inspect}")

    return line
  end


  ##
  # Traite les formules comme 3{n16 n n}
  # 
  XIOLETS = {
    '3-8'   => '4D3',   # triolet de croches => une note vaut noire (4) divisé par 3
    '3-16'  => '8D3',   # triolet de doubles
    '3-32'  => '16D3',  # triolet de triples
    '3-4'   => '2D3',   # triolet de noires
    # ------------
    '2-8'   => '8',     # duolet de croches
    '2-4'   => '4',     # duolet de noires
    '2-16'  => '16',    # duolet de doubles
    # -------------
    '5-16'  => '4D5',
    '5-8'   => '2D5',
    '5-32'  => '8D5',
    # --------------
    '7-16'  => '4D7',
    '7-32'  => '8D7'
  }
  def duree_in_xiolet(line)
    return line unless line.match?(/[0-9]+\{/)
    # puts "line pour xiolet: #{line}"
    line.gsub(/([0-9]+)\{(.*?)\}/) do |tout|
      diviseur  = $1.freeze
      motif_ini = $2.freeze
      motif =
        if motif_ini.match?(/<(.*?)>/)
          # <= Il y a des accords dans ce xiolet
          # => Il faut le traiter
          duree_in_accords(motif_ini)
        else
          motif_ini.dup
        end
      notes     = motif.split(' ')
      # La durée à appliquer aux notes doit être sur la première 
      # note
      # NON, pas forcément. Par exemple : 3{c8 d16 e f8}
      # DONC : la durée de la première note n'est prise qu'à titre
      # de référence, mais il faut chercher la durée sur chaque note
      duree_courante = notes.first.gsub(/[^0-9\.]/,'')
      if duree_courante == ''
        raise "Il faut impérativement indiquer la sous-durée de la première note dans les x-iolets. La donnée '#{diviseur}{#{notes.first}' est incomplète."
      end
      # Maintenant qu’on a la durée courante, il faut retraiter le
      # motif initial si c’est un accord
      if motif_ini.match?(/<(.*?)>/)
        # TODO: LE CALCUL CI-DESSOUS N’EST VALIDE QUE POUR DES TRIOLETS…
        motif = duree_in_accords(motif_ini, (duree_courante.to_i * 2))
      end

      notes.map do |n|
        note, duree, liaison = n.match(/^([a-grs](?:isis|eses|is|es)?)([0-9]+\.*)?(\~)?/).to_a[1..3]
        duree ||= duree_courante
        key_xiolet = "#{diviseur}-#{duree}"
        duree_courante = duree.dup
        duree = XIOLETS[key_xiolet]
        if duree.nil?
          raise "Impossible de trouver la clé xiolet #{key_xiolet.inspect} \nDans: #{tout.inspect}…"
        end
        "#{note}#{duree}#{liaison}"
      end.join(' ')
    end
  end

  def folder
    @folder ||= ensure_folder(File.join(music_score.mus_file.folder,'stats'))
  end

  REG_NOTE = /\b[a-g]([,'’]+)?(isis|eses|is|es)?\b/.freeze
  REG_NOTE_CAPT = /(?<note>[a-grs])(?<alter>isis|eses|is|es)?(?<octave>[,']+)?/.freeze

  REG_DUREE_CAPT = /(?<duration>[0-9]+\.*)(?<sub_to_next>STN)?/.freeze

  # Expression régulière complète pour repérer une note et
  # sa durée
  # 
  # @notes
  #   - le "\" à la fin se trouve par exemple avant un ’\fermata’
  #   - le ")" à la fin se trouve à la fin d’une liaison
  #   - le "(" à la fin se trouve au début d’une liaison
  #   - le "/" à la fin se trouve dans les accaciatura
  # 
  REG_NOTE_DUREE = /\b#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?(?<linked>\~)?[ \\\^_\)\(\/$]/

  REG_GRACE_NOTE = /\\gr\(#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?(?<slash>\/)?(?<link>\-)?\)/.freeze

  REG_MAYBE_CHORD = /<[a-g]/.freeze

  REG_CHORD = /\<(?<chord_exp>.+?)\>(?<duration>[0-9]+\.*)?(?<linked>\~)?/.freeze

end #/class Statistiques
end #/class MusicScore
