# encoding: UTF-8
module ScoreBuilder

  LIB_FOLDER = File.dirname(__dir__)
  APP_FOLDER = File.dirname(LIB_FOLDER)
  SCORE_SUITE_FOLDER = File.dirname(APP_FOLDER)
  TMP_FOLDER = FileUtils.mkdir_p(File.join(APP_FOLDER,'tmp'))

  PATH_TO_SCORE_IMAGE = File.expand_path(File.join(APP_FOLDER,'..','ScoreImage','score_image.rb'))

  #
  # Dossier dans lequel on a ouvert le Terminal
  # 
  CURRENT_FOLDER = ENV['CURRENT_FOLDER']||ENV['CUR_DIR']||File.expand_path('.')


  YAML_OPTIONS = {symbolize_names:true, permitted_classes: [Date, Time, Symbol]}

  #
  # Constantes à définir dynamiquement (à chaque chargement de l'app
  # au départ — mais pas au rechargement de la page HTML dans le 
  # browser). Elles seront accessibles par javascript.
  #
  DYNAMIC_JS_CONSTANTES = [
    ['APP_FOLDER'     , APP_FOLDER],
    ['CURRENT_FOLDER' , CURRENT_FOLDER]
  ]



  SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net"

end
