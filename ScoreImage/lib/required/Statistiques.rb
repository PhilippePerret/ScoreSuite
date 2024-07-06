# encoding: UTF-8

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
    # puts "music score : #{music_score.inspect}"
    @lines = lines
  end

  attr_reader :tempo

  def tempo_noire
    @tempo_noire ||= begin
      if tempo
        if tempo.end_with?('T')
          tempo[0...-1]
        else
          tempo
        end
      end
    end
  end

  def duree_noire
    @duree_noire ||= begin
      if tempo
        durn = 60.0 / tempo_noire.to_i
        durn = (2.0 / 3) * duree_noire if is_ternaire
        durn
      end
    end
  end

  def is_ternaire
    @is_ternaire ||= begin
      if tempo
        tempo.end_with?('T')
      end
    end
  end

  def produce
    # puts "à partir de #{lines}"
    mfile = music_score.mus_file

    # Le tempo est-il défini ? Sinon, le demander
    @tempo = music_score.options[:tempo] || begin
      puts "Je ferai des statistiques sans durée exacte, car le tempo n'est pas défini.".jaune
      puts "Pour le définir, ajouter l'option -t/--tempo=<val>".jaune
      puts "<val> est le tempo à la noire.".jaune
      puts "Ajouter 'T' collé au tempo pour une métrique ternaire.\nPar exemple -t=60T".jaune
    end
    # puts "Tempo : #{tempo.inspect}"

    # 
    # 3 fichiers
    #   1 : par ordre des notes
    #   2 : par durée
    #   3 : au format CSV
    # 
    fpath_not = File.join(mfile.folder, "#{mfile.affixe}-stats-per-note.txt")
    File.delete(fpath_not) if File.exist?(fpath_not)
    fpath_dur = File.join(mfile.folder, "#{mfile.affixe}-stats-per-duree.txt")
    File.delete(fpath_dur) if File.exist?(fpath_dur)
    fpath_cpt = File.join(mfile.folder, "#{mfile.affixe}-stats-per-count.txt")
    File.delete(fpath_cpt) if File.exist?(fpath_cpt)
    fpath_csv = File.join(mfile.folder, "#{mfile.affixe}-stats.csv")
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
    # Si le tempo est défini, on indique la durée en secondes
    # 
    if @tempo

      # puts "duree_noire: #{duree_noire.inspect}"
      SttNoteStat.duree_noire = duree_noire

      total_duree = total_duree * duree_noire
      mns = total_duree.to_i / 60
      scs = total_duree.to_i % 60
      total_duree = "#{mns} mns #{scs}s"
      
    end

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
      purified.each do |line|
        # puts "line: #{line.inspect}"
        line.split(' ').select do |note|
          note.match?(/^[a-grs]/)
        end.each do |note|
          # puts "Traitement de note: #{note.inspect}"

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

  ##
  # @retourne la version purifiée des lignes. C'est une liste
  # de strings qui ne contiennent plus que leur nom (a-g) et leur
  # durée — la durée est parfois exprimée par 'xDx' lorsqu'on à
  # affaire à un triolet ou autre.
  def purified
    @purified ||= begin
      lines.map do |line|
        line = first_purify_line(line)
        line = duree_in_xiolet(line)
        # puts "line après duree_in_xiolet : #{line}"
        line = purify_line(line)
        # puts "line après purify_line : #{line}"
        line = duree_in_accords(line)
        if line.match?('4D31')
          raise "PROBLÈME DE 4D31 dans #{line}"
        end
        # puts "line après duree_in_accords : #{line}"
        line
      end
    end
  end

  # Première méthode de purification qui retire des caractères
  # qui ne servent à rien pour ces statistiques
  def first_purify_line(line)
    line = line.strip
    line = line.gsub(/[\',\"\-\(\)\!\?]/,'')
    line = line.gsub(/(<<|>>| { )/,'')
    line = line.gsub(/\\(stemUp|stemDown|stemNeutral|down|up|fermata)/,'')
    line = line.gsub(/  +/,' ').strip
  end

  def purify_line(line)
    line = line.strip
    line = line.gsub(/(fixed|relative) [a-g]/,'')
    line = line.gsub(/\-[.]/,'')
    line = line.gsub(/[\{\}\'\",\(\)\-]/,'')
    line = line.gsub(/\\/,'')
    line = line.gsub(/  +/,' ')
    line.strip
  end

  # Prends '<a c e>8..' et remplace par 'a8.. c8.. e8..'
  def duree_in_accords(line)
    return line unless line.match?('<')
    # puts "line = #{line.inspect}"
    duree_courante = 4
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
      motif     = $2.freeze
      if motif.match?(/<(.*?)>/)
        # <= Il y a des accords dans ce xiolet
        # => Il faut le traiter
        motif = duree_in_accords(motif)
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
  def duree_of(x)
    case x.to_i
    when 1    then 4.0
    when 2    then 2.0
    when 4    then 1.0
    when 8    then 1.0 / 2
    when 16   then 1.0 / 4
    when 32   then 1.0 / 8
    when 64   then 1.0 / 16
    when 128  then 1.0 / 32
    end
  end

end #/class Statistiques
end #/class MusicScore
