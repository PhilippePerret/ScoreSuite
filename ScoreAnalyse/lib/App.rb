# encoding: UTF-8
=begin

  class ScoreAnalyse::App
  -----------------------
  Gestion de l'application.

=end
module ScoreAnalyse
class App

  def self.aide
    require_relative 'Aide'
    less(AIDE)  
  end

  def self.version
    @@version ||= File.read(File.join(APP_FOLDER,'VERSION')).strip
  end

  ##
  # Pour définir la dernière analyse
  # 
  def self.set_last_analyse(analyse)
    set_preferences(last_analyse_path: analyse.path)
  end

  ##
  # Redéfinit les préférences et les sauve
  #
  def self.set_preferences(data)
    preferences # pour forcer la définition
    @@preferences = @@preferences.merge(data)
    save_preferences
  end

  ##
  # @return true s'il faut charger la dernière analyse
  #
  def self.load_last_analyse?
    preferences[:load_last_analyse] === true
  end

  def self.last_analyse_path
    @@last_analyse_path ||= preferences[:last_analyse_path]
  end

  ##
  # Retourne une table des préférences de l'application
  #
  def self.preferences
    @@preferences ||= begin
      if File.exist?(preferences_path)
        YAML.load_file(preferences_path)
      else
        DEFAULT_PREFERENCES
      end
    end 
  end

  def self.save_preferences
    File.open(preferences_path,'wb'){|f|f.write preferences.to_yaml}
  end


  def self.preferences_path
    @@preferences_path ||= File.join(APP_FOLDER,'prefs.rb')
  end


DEFAULT_PREFERENCES = {
  load_last_analyse: true,
  last_analyse_path: nil,
}

end #/class App
end #/module ScoreAnalyse
