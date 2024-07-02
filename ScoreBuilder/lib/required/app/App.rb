require 'yaml'
module ScoreBuilder
class App

  class << self

    # Le dossier dans lequel on a lancé l’application OU celui fourni
    # en premier argument.
    attr_accessor :current_folder

    # Méthode qui s’assure, avant d’ouvrir la page, que le dossier
    # dans lequel l’application a été ouverte (ou en paramètre) est
    # un dossier correct.
    def check_current_folder
      analyzer = FolderAnalyzer.new(current_folder)
      unless analyzer.valid?
        return Q.yes?("Le dossier courant n’est pas valide… Dois-je poursuivre ?".jaune)
      else
        return true
      end
    end

    # Méthode appelée au chargement de l’application, après que la
    # fenêtre du navigateur a été ouverte.
    # 
    # @note
    #   On a déjà checké pour voir si le dossier était valide.
    # 
    def load(waa_data)
      data_path = File.join(current_folder,'score_builder.yaml').freeze
      folder_data = YAML.safe_load(IO.read(data_path),**YAML_OPTIONS)
      musfile = folder_data[:mus_file]
      folder_data.merge!(
        mus_code: IO.read(musfile),
        affixe: File.basename(musfile, File.extname(musfile))
      )
      WAA.send(class:"App", method:"onLoad", data: folder_data)
    end

    # @return Les paramètres pour WAA.goto
    def goto_params
      if File.exist?(config_path)
        YAML.safe_load(IO.read(config_path),**YAML_OPTIONS)
      end  
    end

    def config_path
      @config_path ||= File.join(APP_FOLDER,'config.yaml')
    end

  end #/<< self

end #/class App
end #/module ScoreBuilder
