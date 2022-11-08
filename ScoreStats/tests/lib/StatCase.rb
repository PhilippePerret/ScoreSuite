# encoding: UTF-8
=begin

  class StatCase
  --------------
  Pour produire plus simplement des tests

  Instancier avec une table contenant :

    code:     Le code Lilypond à utiliser
    res:      La table attendue
    tempo:    Le tempo pour déterminer la durée

=end
class StatCase < MiniTest::Test

  attr_reader :code, :resultat, :tempo
  attr_reader :options

  def initialize(data)
    @code     = data[:code]
    @resultat = data[:res] || data[:result] || data[:resultat]
    @tempo    = data[:tempo]
    @options  = data[:options]||{
      piano: false
    }
    # Rectifications
    @code = [@code] if @code.is_a?(String)
  end

  ##
  # Méthode principale pour exécuter le cas statistique
  #
  def run
    prepare_fichier_mus
    run_statistiques
  end

  ##
  # Doit retourner true pour que le test soit valide
  def is_ok?
    #
    # Tous les fichiers ont été produits
    #
    all_file_have_been_produced
    #
    # On checke le fichier CSV
    # 
    fichier_csv_is_ok?
    #
    # On teste les autres fichiers
    # 
    # (note: ça consisterait à checker simplement l'ordre)
    # TODO

  rescue Exception => e
    puts e.message.rouge
    return false
  else
    return true    
  end

  ##
  # Préparation du fichier .mus
  #
  def prepare_fichier_mus
    File.open(mus_path,'wb') do |f| f.write mus_code end
  end

  ##
  # Lancer la production des statistiques
  #
  def run_statistiques
    Dir.chdir("#{TESTS_FOLDER}/sandbox") do
      cmd = "#{COMMAND_SCORE_STATE} --tempo=#{tempo||60}"
      res = `#{cmd} 2>&1`
      # puts "RES: #{res.inspect}"
    end
  end

  def all_file_have_been_produced
    [
      sorted_by_count_path,
      sorted_by_duree_path,
      sorted_by_note_path,
      csv_file_path
    ].each do |statfile|
      File.exist?(statfile) || raise("Fichier introuvable : #{statfile}")
    end
  end

  # @return TRUE si le fichier CSV contient bien les informations
  # attendues
  def fichier_csv_is_ok?
    lines = File.read(csv_file_path).split("\n")    
    lines.shift # entête
    lines.each do |line|
      note, nombre, duree = line.split(';')
      note_italienne = note_it(note)
      resultat.key?(note) || begin
        raise "La note '#{note_italienne}' n'est pas définie dans les résultats."
      end
      resultat[note][:count] == nombre.to_i || begin
        raise "Il devrait y avoir #{resultat[note][:count]} #{note_italienne}. Il y en a #{nombre}…"
      end
      resultat[note][:duree] == duree.to_f || begin
        raise "La durée de #{note_italienne} devrait être de #{resultat[note][:duree]} s, elle est de #{duree.to_f}…"
      end
    end
  end

  ############### USEFULL METHODS #################

  ##
  # Note allemande vers note italienne
  #
  def note_it(note_al)
    lettre = note_al[0]
    altera = note_al[1..-1] || ''
    "#{BATAVE_TO_ITALIENNE[lettre]}#{ALT_ALL_TO_ITA[altera]}"
  end

  ##
  # Production du code .mus
  def mus_code
    <<-CODE
--barres
#{'--piano' if piano?}
#{"--transpose #{transposition}" if transposition}
-> image_pour_test
#{code.join("\n")}
    CODE
  end


  ############### PATH #############

  # Fichier statistique classement par nombre
  def sorted_by_count_path
    @sorted_by_count_path ||= template_stats_file('per-count')
  end
  def sorted_by_duree_path
    @sorted_by_duree_path ||= template_stats_file('per-duree')
  end
  def sorted_by_note_path
    @sorted_by_note_path ||= template_stats_file('per-note')
  end
  def csv_file_path
    @csv_file_path ||= File.join(sandbox_folder,"code-stats.csv")
  end

  def template_stats_file(suffix)
    File.join(sandbox_folder,"code-stats-#{suffix}.txt")
  end

  # Fichier contenant le code mus
  def mus_path
    @mus_path ||= File.join(sandbox_folder,'code.mus')
  end

  def sandbox_folder
    @sandbox_folder ||= File.join(TESTS_FOLDER,'sandbox')
  end


  #################################################################

  #
  # Traitement des options 
  #


  def piano?
    options[:piano] == true
  end

  def transposition
    @transposition ||= options[:transpose]||options[:transposition]
  end
end #/class StatCase
