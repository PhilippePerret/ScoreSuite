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
    after_create_ok(musfile) if musfile.exist?

  end

  private

  def after_create_ok(musfile)
    clear
    # Donner des informations sur la façon de créer un test (le code
    # à écrire)
    puts EXPLICATION_POST_CREATION

    # Demander s’il faut ouvrir le dossier dans le finder ?
    # (ou le faire d’office ?)
    choices = [
      {name:"Ouvrir le dossier du test dans le Finder", value: :open_finder},
      {name:"Ouvrir le test dans l’éditeur", value: :open_ide},
      {name:"Ne rien faire", value: :noting}
    ]
    case Q.select("Dois-je ouvrir le dossier du test".jaune, choices, **{per_page:choices.count, cycle:true, filter:true})
    when :open_finder then musfile.open
    when :open_ide    then musfile.open_in_ide
    else
      # Ne rien faire
    end
  end

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
      if nom.match?(/^[a-zA-Z\-\_0-9 ]+$/.freeze)
        return nom.gsub(/ /,'_')
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
--keep

-> score
c d e f
MUS
end #/class MusFile

def self.cmd(str)
  str.jaune + "\033[0;96m"
end
EXPLICATION_POST_CREATION = <<~TEXT.bleu
TEST CRÉÉ AVEC SUCCÈS !
Pour le lancer, jouer la commande :
    #{cmd('score-image tests _')}
Si vous ne voulez jouer que ce test, vous pouvez utiliser le filtre
par expression régulière :
    #{cmd('score-image tests /.../')} 
(avec par exemple un bout du nom)

Une fois le code du test déterminé, il a le statut "pending" c’est-à-
dire qu’il n’existe pas encore en tant que test. 
Lancer alors les tests pour produire le CHECKSUM de référence.
Regarder si l’image SVG produite correspond aux attentes. Si ça n’est
pas le cas, détruire le fichier CHECKSUM pour repasser le test au
statut pending, modifier son code ou corriger l’application et recom-
mencer jusqu’à obtenir l’image SVG conforme.

Une fois l’image SVG conforme obtenue, garder le fichier CHECKSUM 
pour déterminer que le test est au statut test. La prochaine fois que
le test sera lancé, l’image SVG devrai correspondre au checksum du 
fichier conforme.

Enjoy!

TEXT


end #/class Test
end #/module ScoreImage
