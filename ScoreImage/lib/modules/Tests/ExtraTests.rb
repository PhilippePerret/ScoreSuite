# 
# EXTRA-TESTS
# 
# Les "extra-tests" sont des tests supplémentaires à exécuter sur les
# images produites pour ScoreImage.
# 
# Ils sont définis dans un fichier ruby ’extra_tests.rb’ créé à la
# racine du dossier principal du test (le nom peut être aussi 
# ’extra_test.rb’, ’extratest.rb’, ’extratests.rb’).
# 
# C’est un fichier définissant le module ExtraTestMethods
# 
#   module ExtraTestMethods
# 
# … contenant les méthodes de test.
# 
# Il doit obligatoirement contenir/définir la méthode #proceed qui
# est le point d’entrée des tests.
# 
#   module ExtraTestMethods
# 
#     def proceed
#       ... appel des autres méthodes
#       un_test
#     end 
# 
# Les méthodes mettent les erreurs dans la propriété-liste @errors,
# c’est de cette manière qu’on sait si les tests ont réussi ou 
# échoués.
# On peut ajouter cette erreur très simplement à l’aide de :
# 
#   def un_test
#     if false
#       errors << "Une erreur dans le système."
#     end
#   end
# 
# Ces tests ont directement accès à toutes les propriétés de MusFile
# (cf. MusFile.rb) par la propriété @musfile, à commencer par les 
# musfile.image_name, musfile.build_folder,
# musfile.folder (dossier principal)
# 
module ScoreImage
class Test
class MusFile
class ExtraTests

  # [ScoreImage::Test::MusFile] Instance créée à partir du fichier
  # .mus du test
  attr_reader :musfile

  # [Array<String>]
  attr_reader :errors

  def initialize(musfile)
    @musfile = musfile
    @errors  = []
  end


  # === PREDICATE METHODS ===

  # @api
  # @main
  # 
  # @return true si le test extra réussi ou s’il n’existe pas
  # 
  def ok?
    not(extra_tests_exist?) || extra_tests_ok?
  end

  # @return true si un test extra existe
  def extra_tests_exist?
    not(path.nil?)
  end

  # = main =
  # 
  # Méthode principale exécutant les tests supplémentaires
  # 
  def extra_tests_ok?
    require path
    extend ExtraTestMethods
    proceed
    return errors.empty?
  end


  # === PATH METHODS ===

  # Chemin d’accès au fichier des tests extra
  def path
    @path ||= search_extra_tests_file
  end


  private

    def search_extra_tests_file
      ['extra_test', 'extra_tests', 'extratest', 'extratests'
      ].each do |affix|
        ftested = File.join(musfile.folder, "#{affix}.rb").freeze
        return ftested if File.exist?(ftested)
      end
      return nil
    end


end #/class ExtraTests
end #/class MusFile
end #/class Test
end #/module ScoreImage
