require 'yaml'
module ScoreBuilder
class App

  class << self

    # Le dossier dans lequel on a lancé l’application
    attr_accessor :current_folder


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
