# encoding: UTF-8

module ScoreWriter
  class App

    ##
    # Appelée à l'ouverture pour charger le bout de partition
    # courant, s'il existe.
    # Il peut exister par l'argument donné en ligne de commande, par
    # exemple 'score-writer affixe' ou par utilisation de la dernière
    # édition effectuée, qui garde en mémoire cette édition.
    # 
    def self.get_code(data)
      @@errors  = []
      ok        = true
      muscore   = get_current_edition
      data = {
        ok:       @@errors.empty?,
        err_msg:  @@errors
      }
      if muscore
        data = data.merge(muscore.data_for_client)
      end

      #
      # Envoi des données au client
      #
      WAA.send({
        class:  'App',
        method: 'onGetCode',
        data: data
      })

      if muscore
        set_last_use_to(muscore)
      end
    end

    ##
    # Pour récupérer au chargement l'édition courante
    # - soit en argument de la ligne de commande, en affixe par 
    #   rapport au dossier courant
    # - soit en argument de la ligne de commande en chemin complet
    # - soit la dernière utilisée
    # 
    # @return {MusScore} Une instance définissant les valeurs
    def self.get_current_edition
      affixe = CommandLine.affixe_partition
      if affixe && affixe.start_with?('/') && File.exist?(affixe)
        # 
        # En argument, en chemin absolu
        # 
        return MusScore.new(affixe)

      elsif affixe && File.exist?(File.join(CURRENT_FOLDER,affixe))
        # 
        # En argument, en affixe par rapport au dossier courant
        # 
        return MusScore.new(File.join(CURRENT_FOLDER,affixe))
      
      elsif affixe
        #
        # L'argument ne correspond pas à une image, c'est donc
        # une nouvelle image
        # 
        return MusScore.new(File.join(CURRENT_FOLDER,affixe))

      end

      # 
      # Soit on n'a pas trouvé le fichier demandé, soit il n'a pas
      # été défini en argument. On recherche le dernier utilisé.
      #
      if last_use && File.exist?(last_use[:path]) 
        score = MusScore.new(last_use[:path])
        score.config = last_use[:config]
        return score
      end

      return nil # pas d'édition courante
    end

    ##
    # Appelé côté client pour traiter le code envoyé (construire 
    # la nouvelle image de la partition)
    def self.build_score(data)
      @@errors = []
      affixe = data['affixe']||'default'

      # L'instance {MusScore} de la partition à construire
      muscore = MusScore.new(File.join(CURRENT_FOLDER,affixe))

      # 
      # Destruction des images existantes
      # 
      muscore.erase_images

      # 
      # Mise du code dans le fichier .mus
      # 
      muscore.write_code(data["code"])

      # 
      # Exécution de score-image pour produire la ou les images
      # 
      muscore.produce_images

      #
      # Données à retourner
      # 
      data = {ok: @@errors.empty?, err_msg: @errors}
      data.merge!(muscore.data_for_client)
      
      #
      # Message de retour au client
      # 
      WAA.send(class:'App', method:'onScoreBuilt', data: data)

      #
      # Enregistrer cette dernière utilisation
      # 
      set_last_use_to(muscore)

    end #/build_code

    ##
    # Construction du fichier 'mesures_data.rb' avec les
    # données transmises par le client.
    # 
    def self.build_mesures_data_file(data)
      result = {ok:true, error:nil}
      mesures_data_file = File.join(CURRENT_FOLDER,data['affixe'],'data_mesures.rb')

      ruby_code = data['code']
                  .gsub(/__DBLSLASH__/,'\\\\\\\\')
                  .gsub(/__SLASH__/,'\\')
      puts "\n\n*** ruby_code: #{ruby_code}"

      File.open(mesures_data_file,'wb') do |f|
        f.write ruby_code
      end
      
      if File.exist?(mesures_data_file)
      else
        result[:ok] = false
        result[:error] = 'Le fichier n’a pas été construit…'
      end
      WAA.send(class:'App', method:'produceMesureDataFile',data:result)
    end

    ##
    # Enregistre la configuration courante pour la partition
    # courante.
    # 
    def self.saveConfig(data)
      muscore = MusScore.new(data['path'])
      muscore.config = data['config']
    end

    ##
    # Permet de lancer un script du dossier 'scripts'
    # (pour le moment inutilisé)
    def self.run_script(script_name)
      puts "Je dois apprendre à jouer un script."  
    end

    ##
    # Permet d'ouvrir le manuel Markdown
    # (appelé par WAA)
    def self.open_manuel_md
      src = File.join(APP_FOLDER,'Manuel','Manuel.md')
      if File.exist?(src)
        `open -a Typora "#{src}"`
        puts "Manuel Markdown ouvert".vert
      else
        puts "Impossible de trouver le manue au format Markdown (#{src}).".rouge
      end
    end

    # --------------- SOUS-MÉTHODES -----------------------

    ##
    # Pour charger le script +script_name+ qui doit se trouver dans
    # le dossier lib/scripts
    def self.require_script(script_name)
      require_relative "scripts/#{script_name}"
    end

    ##
    # Retourne la table ({Hash}) de dernière utilisation si elle
    # existe. C'est un fichier 'score_writer_config.yaml' qui doit se 
    # trouver à la racine du dossier du Terminal
    def self.last_use
      if File.exist?(last_use_path)
        YAML.load_file(last_use_path)
      end
    end

    ##
    # Pour définir la dernière utilisation fait de 
    # score-writer
    # 
    def self.set_last_use_to(muscore)
      save_last_use({
        path:     muscore.affixe_path,
        config:   muscore.config,
        used_at:  Time.now.to_i
      })
    end

    ##
    # Pour enregistrer les données de la dernière utilisation
    def self.save_last_use(data)
      File.open(last_use_path,'wb'){|f| f.write data.to_yaml}
    end

    def self.last_use_path
      @@last_use_path ||= File.join(APP_FOLDER,'config.yaml')
    end

  end #/class App
end #/module ScoreWriter
