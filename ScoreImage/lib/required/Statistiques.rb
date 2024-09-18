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
require_relative 'regexp_lilypond'

class MusicScore

SEP = (' ' * 2).freeze

class Statistiques

  class StatNote
    class << self

      attr_reader :notes_groups

      # Pour les max dans l’affichage
      attr_accessor :note_max_len, :count_max_len, :duree_max_len

      # Pour pouvoir récupérer la valeur courante depuis partout
      # avec :
      #   [Statistiques::]StatNote.current_duration
      # 
      attr_reader :current_duration

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
        verbose? && puts("-> add(#{inote.inspect})".mauve)
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
      # 
      def check_note_duration(inote)
        # verbose? && 
        verbose? && puts("Check de la durée de #{inote.inspect}".jaune)
        if inote.duration
          @current_duration = inote.duration.dup
          verbose? && puts("Inote #{inote.inspect} met la durée à #{inote.duration}".jaune)
        else
          inote.duration=(@current_duration)
          verbose? && puts("Durée de #{inote.inspect} mise à #{inote.duration} (#{@current_duration})".jaune)
        end
        # - Cas particulier d’une durée qui doit être soustraite
        #   (cas des grâces notes) -
        # On prend l’avant-dernière note (puisque la dernière est 
        # celle traitée) et l’on regarde. On doit tenir compte du
        # fait que la précédente est peut-être elle-même une grâce-
        # note
        prec_note = @notes[-2]
        if not(inote.grace_note?) && prec_note && prec_note.grace_note?
          # Traitement de la durée en cas de grace-note
          # 

          # Il faut d’abord récupérer toutes les grâce-notes qui 
          # précèdent la note traitée (il n’y en a en général pas
          # plus de 2)
          grace_notes = []; n = 2
          while @notes[-n] && @notes[-n].grace_note?
            grace_notes << @notes[-n]
            n += 1
          end

          # Quelle que soit la durée définie pour les grâce note, 
          # leur durée (totale) doit valoir la moitié de la durée de
          # la note principale pour une note non barrée et le quart
          # pour une note barrée
          verbose? && puts("Durée absolue de la note courante : #{inote.abs_duration}".bleu)
          diviseur = prec_note.accacciatura? ? 4 : 2
          duree_pour_gns = inote.abs_duration.to_f / diviseur
          verbose? && puts("Durée pour les/la grace-note(s) : #{duree_pour_gns}")
          # Durée pour chaque grace-note :
          duree_gn = (duree_pour_gns / grace_notes.count).round(2)
          verbose? && puts("Durée pour chaque grace-note : #{duree_gn}")

          # On affecte la durée absolue à chaque grace-note
          grace_notes.each { |gn| gn.abs_duration = duree_gn }

          # On retire la durée pour la note courante
          # inote.duration_sub= duree_pour_gns
          inote.abs_duration = inote.abs_duration - duree_pour_gns
        end
      end

      # D’une durée absolue vers une durée LilyPond
      # 
      # Par exemple 4 var donnée 1
      def abs_duration_to_ll_duration(note, abs_duree)
        dduree = decompose_abs_duration(abs_duree)

        dduree.map do |llduree, nombre|
          next if nombre == 0
          "#{note}#{llduree}"
        end.compact.join('~ ')

      end
      def decompose_abs_duration(abs_duree)
        # puts "abs_duree (départ) : #{abs_duree}".jaune
        dduree = {1 => 0, 2 => 0, 4 => 0, 8 => 0, 16 => 0, 32 => 0, 64 => 0}
        llduree = abs_duree
        nombre_rondes = (llduree / 4).to_i
        # puts "nombre_rondes = #{nombre_rondes.inspect}".bleu
        dduree[1] = nombre_rondes
        llduree -= (nombre_rondes * 4)
        return dduree if llduree <= 0
        nombre_blanches = (llduree / 2).to_i
        # puts "nombre_blanches = #{nombre_blanches.inspect}".bleu
        dduree[2] = nombre_blanches
        llduree -= nombre_blanches * 2
        return dduree if llduree <= 0
        nombre_noires   = (llduree / 1).to_i
        # puts "nombre_noires : #{nombre_noires.inspect}".bleu
        dduree[4] = nombre_noires
        llduree -= nombre_noires * 1
        return dduree if llduree <= 0
        nombre_croches  = (llduree / 0.5).to_i
        # puts "nombre_croches : #{nombre_croches}".bleu
        dduree[8] = nombre_croches
        llduree -= (nombre_croches * 0.5)
        return dduree if llduree <= 0
        nombre_doubles = (llduree / 0.25).to_i
        # puts "nombre_doubles : #{nombre_doubles}".bleu
        dduree[16] = nombre_doubles
        llduree -= (nombre_doubles * 0.25)
        return dduree if llduree <= 0
        nombre_triples = (llduree / 0.125).to_i
        # puts "nombre_triples : #{nombre_triples}".bleu
        dduree[32] = nombre_triples
        llduree -= (nombre_triples * 0.125)
        return dduree if llduree <= 0
        nombre_quadru = (llduree / 0.0625).to_i
        # puts "nombre_quadru : #{nombre_quadru}".bleu
        dduree[64] = nombre_quadru
        llduree -= (nombre_quadru * 0.0625)

        # puts "reste : #{llduree.inspect}".bleu

        return dduree
      end

    end #/<< self


    # ==================== INSTANCE ==================== #


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

    def inspect
      @finspect ||= begin
        "#{as_note}"
      end
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

    # @obsolete
    # def sub_duration_to_next?; data[4] == 'STN' end

    def grace_note?
      :TRUE == @isgracenote ||= true_or_false(accacciatura? || data[4] == 'GRN')
    end

    def accacciatura?
      :TRUE == @isaccacciatura ||= true_or_false(data[4] == 'ACA')
    end
      
    def linked?     ; @islinked    ||= data[5] == '~' end
    
    # @return [Float] La durée musicale "absolue", c’est-à-dire 
    # exprimée en noires. Par exemple, une noire vaut 1, une ronde
    # vaut 4, une ronde pointée vaut 6 (4 + 4/2), une ronde pointée 
    # vaut 7 (4 + 4/2 + (4/2)/2), etc.
    def abs_duration
      @abs_duration ||= begin
        dur, prol = duration.match(/([0-9]+)(\.*)?/)[1..2]
        # - Cas spéciaux des n-olets -
        is_n_olet = dur.length > 1 && not([16,32,64,128].include?(dur.to_i))
        if is_n_olet
          diviseur  = dur[-1].to_i
          ref_dur   = 4.0 / dur[0...-1].to_i
          multiplicateur = 
            case diviseur
            when 3 then 2 # => triolet
            when 2 then 3 # => duolet
            else 1/2 # => n-olet (pour le moment)
            end
          dur = ((ref_dur.to_f * multiplicateur) / diviseur).round(2)
        else
          # Cas courant (hors n-olets)
          dur = 4.0 / dur.to_i
        end
        c = dur.dup
        prol.length.times { dur += (c = c / 2) }
        dur - duration_sub
      end
    end

    # On peut forcer la durée absolue dans certains cas, par 
    # exemple avec les grace-notes
    def abs_duration=(v)
      @abs_duration = v
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


    # StatNote.notes_groups.each do |note, notes_group|
    #   puts "- #{notes_group.text_line}"
    # end

    ary_groups_notes = StatNote.notes_groups.values.sort_by { |n| n.note }

    total_notes = ary_groups_notes.sum(&:count)
    total_duree = ary_groups_notes.sum(&:duree_secondes)
    # puts "total_duree brute: #{total_duree}"

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

  # Méthode principale qui parse (analyse) la ligne de code MUS 
  # +line+ pour en tirer les notes
  def parse_line(line, add_notes = true)

    # Mettre à true si l’on veut voir en console le traitement
    # effectué par chaque méthode de préparation
    decompose_debug = false

    # puts "Line à parser : #{line.inspect} #{' (sans ajout de note)' if !add_notes}".jaune
    decompose_debug && puts("LINE INITIALE : #{line.inspect}".jaune)

    # Pour simplifier, on essaie de supprimer les paramètres des
    # notes
    # @note
    #   Maintenant qu’on fait ça au tout départ, on pourrait
    #   simplifier énormément la suite.
    line = line.gsub(REG_NOTE_WITH_PARAMS) do
      "#{$~[:note]}#{$~[:alter]}#{$~[:duration]}"
    end
    decompose_debug && puts("[0]line : #{line.inspect}")

    # On remplace les silences positionnés par de simple silences
    # (sinon les notes de position sont prises en considération)
    line = simplifie_silence_positioned_in(line)
    decompose_debug && puts("[1.1]line : #{line.inspect}")

    # On remplace les silences R (silence sur mesure) par des r
    line = line.gsub(/R([1-8]+[.]+)/.freeze,'r\1'.freeze)
    decompose_debug && puts("[1.2]line : #{line.inspect}")

    # Pour pouvoir utiliser les espaces comment délimiteurs partout
    line = " #{line} "
    decompose_debug && puts("[1.3]line : #{line.inspect}")

    # On retire toutes les expressions lilypond qui peuvent comporter
    # des notes, à commencer par les \relative <note>
    line = epure_lily_expressions_with_notes_in(line)
    decompose_debug && puts("[2]line : #{line.inspect}")

    # Traitement des trilles avec terminaisons
    line = traite_trille_with_terminaisons_in(line)
    decompose_debug && puts("[3]line : #{line.inspect}")
    # Épuration des marques de trilles
    line = epure_trille_in(line)
    decompose_debug && puts("[4]line : #{line.inspect}")

    # Traitement des répétitions
    line = traitement_des_repetitions(line) 
    decompose_debug && puts("[5]line : #{line.inspect}")

    # On "sort" toutes les notes de leurs accords
    line = decompose_chords_in(line)
    decompose_debug && puts("[6]line : #{line.inspect}")

    # On épure certaines marques qui pourraient gêner ensuite
    # (typiquement, les triolets, duolet, etc. en ’3{...}’), ainsi
    # que les points d’exclamation et d’interrogation
    line = epure_expressions_speciales_in(line)
    decompose_debug && puts("[7]line : #{line.inspect}")

    # Traitement spécial des appogiatures
    line = traitement_des_graces_notes_in(line)
    decompose_debug && puts("[8]line : #{line.inspect}")

    # ======================================= #
    # ===     RÉCUPÉRATION DES NOTES      === #
    # ======================================= #
    notes_scaned = line.scan(REG_NOTE_DUREE)
    verbose? && begin
      puts("Line pour scan complet: #{line.inspect}".jaune)
      puts("Scan complet: #{notes_scaned.to_a}")
      puts "Rappel : une donnée note est composée de :\n[note, altération, octave, point, tilde]".gris
    end
    notes_scaned.map do |data_note|
      # puts "data_note = #{data_note}".bleu
      # exit 12
      inote = StatNote.new(data_note)
      StatNote.add(inote) if add_notes
      inote
    end

  end

  # On remplace les :
  #     <note><octave><duree>\rest 
  # par des :
  #     r<duree>
  # 
  def simplifie_silence_positioned_in(line)
    
    line = line.gsub(REG_POSITIONED_REST) do
      TEMP_POSITIONED_REST % {duree: $~[:duree]||''}    
    end

    return line
  end
  REG_POSITIONED_REST = /(?<note>[a-g])(?<octave>[’',]*)(?<duree>[0-9]*)\\rest/.freeze
  TEMP_POSITIONED_REST = 'r%{duree}'.freeze

  # Traitement d’expressions spéciales qui peuvent poser problème
  # 
  # La méthode a été initiée pour l’expression ’3{gis8 cis e} qui
  # ne prenait en compte que le cis et le e, pas les gis8
  # 
  def epure_expressions_speciales_in(line)
    line = line.gsub(REG_NOLET) do
      diviseur = $~[:diviseur].to_i.freeze # 2, 3, 4, 5, 7, 9
      notes    = $~[:notes].freeze
      notes = notes.split(' ')
      notes[0].match(/^#{REG_NOTE_WITH_DUREE_AND_REST}$/)
      duree = $~[:duration].freeze
      duree = "#{duree}#{diviseur}"
      notes[0] = "#{$~[:note]}#{$~[:alter]}#{duree}"
      notes = notes.join(' ')
      " #{notes} "
    end

    line = line.gsub(/[\!\?]/.freeze,'')

    return line
  end

  # Traite les appogiatures (pour pouvoir prendre leur durée et
  # la soustraire à la note principale suivante)
  # 
  # @note 
  #   Pour pouvoir soustraire à la note suivante, on utilise la
  #   marque "STN" après la durée (qui signifie "SousTraire à la
  #   Next") pour la supprimer dans la note suivante.
  # 
  def traitement_des_graces_notes_in(line)
    return line unless line.match?(/\\gr\(/.freeze)

    # TODO : sauf qu’il peut y en avoir plusieurs
    line = line.gsub(REG_GRACE_NOTES) do
      notes       = $~[:notes]
      is_slashed  = $~[:slash] == '/'
      is_linked   = $~[:link] == '-'
      curduree = StatNote.current_duration

      mark_gr = is_slashed ? 'ACA' : 'GRN'

      notes = notes.split(' ').map do |note_str|
        note_str.scan(REG_NOTE_WITH_PARAMS)
        if $~.nil?
          puts "C’est null avec notes = #{notes.inspect} de la ligne\n#{line}"
          exit 12
        end
        note        = $~[:note]
        alter       = $~[:alter]
        duration    = ($~[:duration]||curduree)
        curduree = duration
        note_params = $~[:note_params]
        "#{note}#{alter}#{duration}#{mark_gr}"
      end.join(' ')
      verbose? && puts("Grace-note(s) obtenue(s) : #{notes}".bleu)

      notes
    end

    return line  
  end


  # Traitement des notes dans les terminaisons de trilles.
  # 
  # Typiquement, si on a l’expression :
  # 
  #   ’\_tr(<n1>)- (<n2> <n3>)\-tr’
  # 
  # … alors il faut retirer à <n1> la durée donnée à <n2> et <n3>
  # 
  def traite_trille_with_terminaisons_in(line)
    return line unless line.match?(REG_TRILL_END)
    line = line.gsub(REG_TRILLE_WITH_TERM) do
      raw_note_trilled = $~[:notesdep].freeze.split(' ').shift
      inter_notes = $~[:internotes].freeze
      term_notes_ini  = $~[:gnotes].freeze
      term_notes = term_notes_ini.split(' ')

      raw_note_trilled.scan(REG_NOTE_DUREE_SIMPLE)
      note_trilled = StatNote.new([$~[:note],$~[:alter],$~[:octave],$~[:duration]])

      last_duration = note_trilled.duration

      # Les notes de la terminaison
      term_notes = term_notes.map do |raw_note|
        raw_note.scan(REG_NOTE_DUREE_SIMPLE)
        no_note = $~[:note]
        no_alte = $~[:alter]
        no_octa = $~[:octave]
        no_dure = $~[:duration] || last_duration
        last_duration = no_dure.dup
        StatNote.new([no_note, no_alte, no_octa, no_dure])
      end

      # On doit retirer à la durée de la note trillée la durée des
      # petites notes de terminaisons
      abs_duree_to_sup = term_notes.sum do |no|
        no.abs_duration
      end

      new_duree = note_trilled.abs_duration - abs_duree_to_sup
      new_note_trilled = StatNote.abs_duration_to_ll_duration(note_trilled.note_abs, new_duree)

      # On reconstitue ce qu’il faut garder
      "#{new_note_trilled} #{inter_notes} #{term_notes_ini}"
    end

    # puts "\nline = #{line.inspect}".bleu

    return line
  end

  # Traitement des trilles (après la précédente)
  # 
  # Pour retirer les \tr et autre \-tr
  # 
  def epure_trille_in(line)
    return line unless line.match?(REG_TRILL_START)

    line
      .gsub(REG_LONG_TRILL_START, '\k<inner>')
      .gsub(REG_TRILL_END, '')

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
    line = line.gsub(/key #{REG_NOTE}/,'')
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
  # (je crois que ça ne sert plus)
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

end #/class Statistiques
end #/class MusicScore
