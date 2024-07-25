# encoding: UTF-8
# 
# ANCIENNE MÉTHODE POUR CALCULER LES STATISTIQUES
# Pourrait être employée pour vérifier la pertinence de la nouvelle
# méthode.
# 
# Pour le moment, le "filtrage" se fait en supprimant tous les
# termes qui ne sont pas des notes.
class MusicScore

  SttNoteStat = Struct.new(:note, :count, :duration) do
    SEP = ' ' * 4
  class << self
    attr_accessor :count_len, :duree_len, :duree_noire
  end
  def f_duree_secondes
    @f_duree_secondes ||= begin
      if duree_secondes
        duree_secondes.to_s + 's'
      end
    end
  end
  def duree_secondes
    @duree_secondes ||= begin
      if self.class.duree_noire
        (duration * self.class.duree_noire).round(2)
      end
    end
  end
  def txt_line
    @txt_line ||= begin
      "#{note.ljust(6)}#{SEP}#{count.to_s.ljust(self.class.count_len)}#{SEP}#{(f_duree_secondes||duration).to_s.ljust(self.class.duree_len)}\n"
    end
  end
  def csv_line
    @csv_line ||= begin
      "#{note};#{count};#{duree_secondes}\n"
    end
  end
end

class Statistiques

  attr_reader :music_score
  attr_reader :lines

  def initialize(music_score, lines)
    @music_score = music_score
    @lines = lines
  end

  attr_reader :tempo

  def tempo_noire
    @tempo_noire ||= begin
      if tempo.end_with?('T')
        tempo[0...-1]
      else
        tempo
      end
    end
  end

  def duree_noire
    @duree_noire ||= begin
      durn = 60.0 / tempo_noire.to_i
      durn = (2.0 / 3) * duree_noire if is_ternaire
      durn
    end
  end

  def is_ternaire
    @is_ternaire ||= begin
      tempo.end_with?('T')
    end
  end


  def produce
    # puts "à partir de #{lines}"
    mfile = music_score.mus_file

    # Le tempo est-il défini ? Sinon interrompre le programme
    # pour le demander
    tempo || return
    # puts "Tempo : #{tempo.inspect}"

    # 
    # 3 fichiers
    #   1 : par ordre des notes
    #   2 : par durée
    #   3 : au format CSV
    # 
    fpath_not = File.join(folder, "#{mfile.affixe}-stats-per-note.txt")
    File.delete(fpath_not) if File.exist?(fpath_not)
    fpath_dur = File.join(folder, "#{mfile.affixe}-stats-per-duree.txt")
    File.delete(fpath_dur) if File.exist?(fpath_dur)
    fpath_cpt = File.join(folder, "#{mfile.affixe}-stats-per-count.txt")
    File.delete(fpath_cpt) if File.exist?(fpath_cpt)
    fpath_csv = File.join(folder, "#{mfile.affixe}-stats.csv")
    File.delete(fpath_csv) if File.exist?(fpath_csv)

    sep = ' ' * 4

    # 
    # Déterminer les longueurs maximales
    # 
    max_lengths = {count: 0, duree: 0}
    table_structured.each do |dnote|
      count_len = dnote[:count].to_s.length
      duree_len = dnote[:duration].to_s.length
      max_lengths[:count] = count_len if count_len > max_lengths[:count]
      max_lengths[:duree] = duree_len if duree_len > max_lengths[:duree]
    end

    SttNoteStat.count_len = max_lengths[:count]
    SttNoteStat.duree_len = max_lengths[:duree]

    total_notes = table_structured.sum(&:count)
    total_duree = table_structured.sum(&:duration)

    # 
    # On indique la durée en secondes
    # 
    # puts "duree_noire: #{duree_noire.inspect}"
    SttNoteStat.duree_noire = duree_noire

    total_duree = total_duree * duree_noire
    mns = total_duree.to_i / 60
    scs = total_duree.to_i % 60
    total_duree = "#{mns} mns #{scs}s"

    #
    # Tableau classé par durée
    # + Tableau classé par nombre
    #
    tableau_per_duree = table_structured.sort_by{|dn| -dn.duration}
    tableau_per_count = table_structured.sort_by{|dn| -dn.count   }

    begin

      rf_not = File.open(fpath_not,'a')
      rf_dur = File.open(fpath_dur,'a')
      rf_cpt = File.open(fpath_cpt,'a')
      rf_csv = File.open(fpath_csv,'a')

      rf_csv.write "NOTE;NOMBRE;DURÉE\n"

      rf_cpt.write "Nombre total de notes : #{total_notes}\n"
      rf_dur.write "Durée totale : #{total_duree}\n"

      table_structured.each do |snote|
        rf_not.write snote.txt_line
        rf_csv.write snote.csv_line
      end

      tableau_per_duree.each do |snote|
        rf_dur.write snote.txt_line
      end

      tableau_per_count.each do |snote|
        rf_cpt.write snote.txt_line
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

  ##
  #
  def table_structured
    @table_structured ||= begin
      tableau_stats.values.sort_by{|dn| dn[:note]}.map do |dnote|
        SttNoteStat.new(dnote[:note], dnote[:count], dnote[:duration])
      end
    end
  end

  ##
  # @return le tableau qui contient les statistiques
  # C'est un tableau avec en clé les notes et en valeur une table
  # défissant le nombre (:count) et la durée totale (:duration) de
  # chaque note
  def tableau_stats
    @tableau_stats ||= begin
      stats = {}
      duree_courante      = duree_noire
      duree_courante_str  = '4'

      # Débug
      puts "Lines: #{lines}"
      puts "Le texte purifié : #{purified_lines.inspect}".bleu
      # /Débug

      purified_lines.each do |line|
        # puts "line: #{line.inspect}"
        line.split(' ').select do |note|
          note.match?(/^[a-grs]/)
        end.each do |note|

          # # Débug
          # puts "Traitement de note: #{note.inspect}"
          # # /Débug

          # Est-ce vraiment une note ?
          # On peut le savoir en testant les deux premières lettres :
          # - la première ne peut qu’être dans l’espace a-g
          # - la deuxième, si c’est une lettre, ne peut qu’être que
          #   "e" (du "es"), "i" (du "is") ou un chiffre de durée
          # 
          # @notes
          #   - les éventuelles indications d’octaves ont déjà été
          #     retirées.
          # 
          if note.length > 1 && note[1].match?(/[a-z]/) && note[1].match?(/[^ei]/)
            puts "#{note.inspect} ne semble pas être note valide… (je la passe)".rouge
            next
          end

          #
          # Est-ce une note liée ?
          # 
          # Dans ce cas, il y a un tilde, mais avec le traitement des
          # accords et des x-olets, le tilde peut se trouver à dif-
          # férents endroits. On teste donc sa présence dans la chai-
          # ne et on le retire.
          #
          has_liaison = note.match?('~')
          if has_liaison
            # puts "#{note} possède une liaison"
            note = note.gsub(/\~/,'')
          end

          #
          # On la décompose
          # 
          tout, tune, alter, duree_init, points = note.match(/^([a-grs])(isis|is|eses|es)?([0-9D]+)?(\.+)?/).to_a
          if tune.nil?
            raise "Problème avec : #{note.inspect} (tune = nil)"
          end
          
          

          # puts "duree = #{duree.inspect}"

          # La durée calculée ou reprise
          duree = nil
          if duree_init.nil?

            duree       = duree_courante
            duree_init  = duree_courante_str 

          else
            
            duree = 
              if duree_init.match?('D')
                valeur_ref, diviseur = duree_init.split('D')
                duree_of(valeur_ref) / diviseur.to_i
              else
                duree_of(duree_init)
              end
          
            # On la met en durée courante
            duree_courante_str  = duree_init.dup
            duree_courante      = duree.dup
          
          end

          # puts "tune: #{tune.inspect}"
          # puts "duree: #{duree.inspect}"
          # puts "points: #{points.inspect}"
          tune = "#{tune}#{alter}" if alter
          stats.key?(tune) || stats.merge!(tune => {note:tune, count:0, duration:0, plain_notes:[] })
          stats[tune][:count] += 1 unless has_liaison
          if points
            nombre_points = points.length
            # C’EST PAS BON, ÇA :
            duree += (duree / 2) * nombre_points
          end
          # puts "POUR:« #{tune}#{duree_init}#{points} » : duree_init: #{duree_init.inspect} / duree: #{duree.inspect}"
          stats[tune][:duration] += duree
          stats[tune][:plain_notes] << "#{tune}#{duree_init}#{points}"
        end
      end

      # On arrondit à 2 décimales toutes les durées
      stats.each do |n, dn|
        stats[n].merge!(duration: dn[:duration].round(2))
      end

      # puts "\n\n+++ stats:\n#{stats}\n\n"

      stats
    end
  end


  # Nouvelle façon de filtrer
  def parse_line(line)

    puts "\nLine au départ : #{line.inspect}".jaune

    # Pour pouvoir utiliser les espaces comment délimiteurs partout
    line = " #{line} "

    # On retire toutes les expressions lilypond qui peuvent comporter
    # des notes, à commencer par les \relative <note>
    line = epure_lily_expressions_with_notes_in(line)

    # On "sort" toutes les notes de leurs accords
    line = decompose_chords_in(line)

    # On ne conserve que les notes
    notes_scaned = line.scan(REG_NOTE_DUREE)
    puts "Scan complet: #{notes_scaned.to_a}"
    # ICI, AVANT, je reconstituais la note en lui recollant sa durée,
    # ses liaisons, etc. Mais c’est stupide puisque maintenant, dans
    # le scan, on a la note complètement "décortiquée". Il suffit
    # donc de faire une instance de note qu’on ajoutera ensuite aux
    # notes totales.
    # Avant:
    # line = notes_scaned.map { |quatro| "#{quatro[0]}#{quatro[3]}" }
    # puts "Scan de line produit : #{line.inspect}".bleu
    # line = line.join(' ')
    # puts "line après scan: #{line}"
    # /Avant
    # Maintenant:
    notes = notes_scaned.map do |data_note| 
      inote = StatNote.new(data_note)
      StatNote.add(inote)
    end
    # /Maintenant
  end

  # Ancienne méthode de filtre
  def ancient_line_filter(line)
    line = first_purify_line(line)
    line = duree_in_xiolet(line)
    # puts "line après duree_in_xiolet : #{line}"
    line = purify_line(line)
    # puts "line après purify_line : #{line}".jaune
    line = duree_in_accords(line, duree_courante)
    if line.match?('4D31')
      raise "PROBLÈME DE 4D31 dans #{line}"
    end
    return line
  end

  # ==== NOUVELLES MÉTHODES DE PURIFICATION ==== #

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
    # TODO: ICI AUSSI IL FAUT TENIR COMPTE DES ACCORDS LIÉS :
    # "<c e g>4.~ <c e g>8"
    line = line.gsub(REG_CHORD) do
      chord_exp = $~[:chord_exp]
      duration  = $~[:duration]
      chord_notes = parse_line(chord_exp)
      if duration
        chord_notes = chord_notes .split(' ')
                                  .map { |n| "#{n}#{duration}" }
                                  .join(' ')
      end
      chord_notes
    end

    return line
  end

  # ==== ANCIENNES MÉTHODES DE PURIFICATION ==== #



  LILYPOND_RESERVED_WORDS = [
    'alternative',
    'bar',
    'center',
    'column',
    'down',
    'fermata',
    'flat',
    'hspace',
    'markup',
    'mordent',
    'natural',
    'prall',
    'repeat',
    'sharp',
    'slurUp',
    'slurDown',
    'stemUp',
    'stemDown',
    'stemNeutral',
    'teeny',
    'turn',
    'upprall',
    'upmordent',
    'up',
    'vspace',
  ].freeze
  REG_RESERVED_WORDS = /(?:#{LILYPOND_RESERVED_WORDS.join('|')})/.freeze

  # Première méthode de purification qui retire des caractères
  #  et mots qui ne servent à rien pour ces statistiques
  def first_purify_line(line)
    line = line.strip
    line = line.gsub(/[\',\"\-\(\)\!\?]/,'')
    line = line.gsub(/(<<|>>| { )/,'')
    line = line.gsub(/\\#{REG_RESERVED_WORDS}/,'')
    line = line.gsub(/  +/,' ').strip
  end

  def purify_line(line)
    line = line.strip
    line = line.gsub(/volta [0-9]+/,'')
    line = line.gsub(/(fixed|relative) [a-g]/,'')
    line = line.gsub(/tune [a-g]/,'')
    line = line.gsub(/transpose #{REG_NOTE} #{REG_NOTE}/,'')
    line = line.gsub(/\-[.]/,'')
    line = line.gsub(/[\{\}\'\",\(\)\-_\^]/,'')
    line = line.gsub(/\\/,'')
    line = line.gsub(/  +/,' ')
    line.strip
  end

  # Prends '<a c e>8..' et remplace par 'a8.. c8.. e8..'
  def duree_in_accords(line, duree_courante = nil)
    return line unless line.match?('<')
    # puts "line = #{line.inspect}"

    # On doit trouver la première durée
    duree_courante = line.match(/([0-9]+)/)[1]
    # puts "Durée courante trouvée : #{duree_courante.inspect}".bleu
    duree_courante ||= 4
    # On corrige les problèmes d'accords collés
    line.gsub(/>([0-8]+\.*)?</) do
      '>' + $1.to_s + ' <'
    end.gsub(/<(.*?)>([0-8]+\.*)?( |$)/) do
      notes = $1.freeze
      duree = $2.freeze
      if duree.nil?
        duree = duree_courante
      else
        duree_courante = duree.dup
      end
      # puts "notes: #{notes.inspect}"
      # puts "duree: #{duree.inspect}"
      notes.split(' ').map{|n| "#{n}#{duree}"}.join(' ') + $3
    end
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

  # +x+ est transformé en noires
  # 
  def duree_of(x)
    return 4.0 / x.to_i
    # case x.to_i
    # when 1    then 4.0
    # when 2    then 2.0
    # when 4    then 1.0
    # when 8    then 1.0 / 2
    # when 16   then 1.0 / 4
    # when 32   then 1.0 / 8
    # when 64   then 1.0 / 16
    # when 128  then 1.0 / 32
    # end
  end

  def folder
    @folder ||= ensure_folder(File.join(music_score.mus_file.folder,'stats'))
  end

  REG_NOTE = /\b[a-g]([,'’]+)?(isis|eses|is|es)?\b/.freeze
  REG_NOTE_CAPT = /(?<note>[a-grs])(?<octave>[,']+)?(?<alter>isis|eses|is|es)?/.freeze

  REG_DUREE_CAPT = /(?<duration>[0-9]+\.*)/.freeze

  REG_NOTE_DUREE = /\b#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?(?<linked>\~)?[ \\\^$]/

  REG_CHORD = /\<(?<chord_exp>.+?)\>(?<duration>[0-9]+\.*)?(?<linked>\~)?/.freeze

end #/class Statistiques
end #/class MusicScore
