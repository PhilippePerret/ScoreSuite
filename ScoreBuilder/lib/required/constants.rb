# encoding: UTF-8
module ScoreBuilder

  LIB_FOLDER = File.dirname(__dir__)
  APP_FOLDER = File.dirname(LIB_FOLDER)
  SCORE_SUITE_FOLDER = File.dirname(APP_FOLDER)
  TMP_FOLDER = FileUtils.mkdir_p(File.join(APP_FOLDER,'tmp'))

  PATH_TO_SCORE_IMAGE = File.expand_path(File.join(APP_FOLDER,'..','ScoreImage','score_image.rb'))


  YAML_OPTIONS = {symbolize_names:true, permitted_classes: [Date, Time, Symbol]}


  SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net"

  class AbandonException < StandardError; end
  
end
