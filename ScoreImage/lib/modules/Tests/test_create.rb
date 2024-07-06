#
# Module pour gérer les tests.
# Ce patch lance les tests (en les filtrant si nécessaire)
# 
require_relative 'MusFile'

module ScoreImage
class Test
class << self

  def create_test
    # Proposer la liste des dossiers actuels (avec un choix
    # "autre" pour en créer un nouveau)
    mainfolder = choose_new_test_main_folder || return

    # Demander le nom du test
    test_name = ask_for_test_name || return

    # Chemin d’accès au fichier Mus
    musfile_path = File.join(tests_folder,mainfolder,test_name,'main.mus')

    # Créer le test avec les éléments minimum. En fait, pour faire
    # ça, on instancie un ScoreImage::Test::MusFile avec le path du
    # fichier mus qu’on doit créer
    musfile = MusFile.new(musfile_path)

    if musfile.exist?
      puts "Ce test existe déjà… (je l’ouvre)".orange
      musfile.open
      return
    end

    musfile.create
    if musfile.exist?
      puts "Test créé avec succès. Je l’ouvre dans le Finder.".vert
      musfile.open
    end

    # Donner des informations sur la façon de créer un test (le code
    # à écrire)
    puts "Je dois expliquer quoi faire ensuite.".jaune

    # Demander s’il faut ouvrir le dossier dans le finder ?
    # (ou le faire d’office ?)

  end

  private

  def choose_new_test_main_folder
    choices = Dir["#{tests_folder}/*"].map do |pth|
      if File.directory?(pth)
        File.basename(pth)
      end
    end.compact.map do |fname|
      {name: fname, value: fname}
    end

    choices.unshift({name: "Nouveau…".bleu, value: :new})

    case (choix = Q.select("Dossier principal du nouveau test :".jaune,choices,**{per_page:choices.count, filter:true, cycle:true}))
    when :new
      ask_for_new_main_folder
    else
      choix
    end
  end

  ##
  # Méthode pour demander un nouveau nom de dossier principal
  # 
  def ask_for_new_main_folder
    ask_only_valid_name('Nom du nouveau dossier principal')
  end

  def ask_for_test_name
    ask_only_valid_name("Nom du test")
  end

  def ask_only_valid_name(msg)
    clear
    nom = ""
    while true
      nom = Q.ask("#{msg}\n(lettres a-Z, tiret plat ou normal, chiffres)\n : ".jaune, **{value: nom})
      if nom.match?(/^[a-zA-Z\-\_0-9]+$/.freeze)
        return nom
      else
        bads  = nom.gsub(/[a-zA-Z\-\_0-9]/.freeze,'')
        nom   = nom.gsub(/[^a-zA-Z\-\_0-9]/.freeze,'')
        puts "Mauvais caractères : #{bads.split('').join(', ')}".bleu
      end
    end  
  end
end #/<< self class

class MusFile

  def create
    FileUtils.mkdir_p(folder)
    IO.write(path, SAMPLE_MUS_CODE)
  end


  SAMPLE_MUS_CODE = <<~MUS
  --barres
  --keep

  -> score
  c d e f
  MUS
end #/class MusFile
end #/class Test
end #/module ScoreImage
