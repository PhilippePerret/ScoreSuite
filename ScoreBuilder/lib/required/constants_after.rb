# encoding: UTF-8
module ScoreBuilder

  def self.interactive_mode?
    :TRUE == @interactivemode ||= true_or_false(CLI.option(:interactive))
  end

  # Dossier courant pour l’application (le dossier dans
  # lequel doivent se trouver les éléments du builder)
  CURRENT_FOLDER = ScoreBuilder::App.set_current_folder

  #
  # Constantes à définir dynamiquement (à chaque chargement de l'app
  # au départ — mais pas au rechargement de la page HTML dans le 
  # browser). Elles seront accessibles par javascript.
  #
  DYNAMIC_JS_CONSTANTES = [
    ['APP_FOLDER'     , APP_FOLDER],
    ['CURRENT_FOLDER' , CURRENT_FOLDER]
  ]


end #/module ScoreBuilder
