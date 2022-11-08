# encoding: UTF-8

module ScoreExtraction

  class Score

    ##
    # = main =
    # 
    # Méthode appelée pour extraire le code.
    # 
    def self.extract
      clear
      if mesures_defined?
        puts "*** Extraction du fragment entre les mesures #{first_mesure} et #{last_mesure}…".bleu
        puts "    Dans '#{titre_id}.svg'".bleu

        # 
        # On détruit les éléments qui peuvent déjà exister
        # 
        remove_similar_elements

        # Pour le débug
        # puts "CODE:««««««««««««\n#{code_for_extrait}\n»»»»»»»»»»»»»»»»»"

        # 
        # Création du code dans le fichier .mus
        #
        File.open(mus_path,'wb'){|f| f.write code_for_extrait}

        #
        # Lancement de la commande de transformation
        # 
        scorize

        # 
        # Déplacement du ou des fichiers svg pour le ou les ramener
        # à la racine de ce dossier
        # 
        move_extrait_svg || return

        #
        # On détruit les choses inutiles (sauf si keep)
        # 
        remove_useless_things unless CommandLine.options[:keep]

        puts "Opération exécutée avec succès.".vert

      elsif File.exist?(data_mesures_path)

        puts "La données DATA_MESURES est introuvable dans le fichier data_mesures.rb".rouge
      
      else
      
        puts "Le fichier data_mesures.rb (définissant les mesures) est introuvable. Impossible d'extraire un fragment.".rouge
        File.open(data_mesures_path,'wb'){|f| f.write "# Données des mesures\n" }
        puts "Je l'ai fabriqué. Tu n'as plus qu'à y mettre la donnée DATA_MESURES\nque tu peux récupérer dans MusicScoreWriter par exemple.".bleu

      end

    end

    def self.scorize
      # 
      # Options pour scorize
      # 
      opt_stats = CommandLine.options[:stats] ? '--stats ' : ''
      opt_tempo = CommandLine.options[:tempo] ? "--tempo=#{CommandLine.options[:tempo]} " : ''
      # 
      # La commande scorize à jouer
      # 
      cmd = "#{SCORISE_CMD} \"#{mus_path}\""
      cmd = "cd '#{CURRENT_FOLDER}' && #{SCORISE_CMD} #{opt_stats}#{opt_tempo}./#{titre_id}.mus"

      # Débuggage
      # puts "cmd = #{cmd.inspect}"

      res = `#{cmd} 2>&1`
      puts res.rouge if res != ''
    end

    def self.move_extrait_svg
      @@images_indexes = nil
      if only_one_image?
        `mv "#{svg_infolder_path}" "#{svg_path}"`
      elsif several_images?
        images_indexes.each do |img_index|
          src = svg_infolder_template_path % img_index
          dst = svg_template_path % img_index
          `mv "#{src}" "#{dst}"`
        end
      else
        puts "Un problème est survenu, aucune image n'a été produite".rouge
        return nil
      end

      return true
    end

    # Avant de procéder, on détruit tous les éléments similaires
    # 
    # Note : ça sert surtout à détruire des fichiers .svg lorsqu'il
    # y en a plusieurs, et que là il va y en avoir moins. Par exemple
    # si au tour d'avant, on a mis une valeur haute pour proximity
    # qui produisait 3 images svg et que maintenant seulement 2 vont
    # être produite avec une valeur de proximity plus faible, sans 
    # cette méthode, il resterait la troisième image et ça créerait
    # de la confusion.
    # 
    def self.remove_similar_elements
      # Le fichier .mus
      File.delete(mus_path) if File.exist?(mus_path)
      # Le ou les fichiers .svg
      if only_one_image?
        File.delete(svg_path) if File.exist?(svg_path)
        File.delete(svg_infolder_path) if File.exist?(svg_infolder_path)
      elsif several_images?
        images_indexes.each do |img_index|
          dst = svg_template_path % img_index
          File.delete(dst) if File.exist?(dst)
        end
      else
        # Il n'y a aucun fichier
      end
      # Le dossier
      FileUtils.rm_rf(svg_folder) if File.exist?(svg_folder)
    end

    # À la fin, on détruit tout ce qui ne sert à rien
    def self.remove_useless_things
      FileUtils.rm_rf(svg_folder)
      File.delete(mus_path)      
    end


    # @return true si une seule image a été produite
    def self.only_one_image?
      File.exist?(svg_path) || File.exist?(svg_infolder_path)
    end

    # @return true si plusieurs images ont été produites
    def self.several_images?
      File.exist?(svg_infolder_template_path % '1') || File.exist?(svg_template_path % '1')
    end

    # @return Array des index des fichiers images existants
    def self.images_indexes
      @@images_indexes ||= begin
        i = 1
        ary = []
        while true 
          infolder_path   = svg_infolder_template_path % i.to_s
          outfolder_path  =  svg_template_path % i.to_s
          if File.exist?(infolder_path) || File.exist?(outfolder_path)
            ary << i.to_s
          else
            break
          end
          i += 1
        end

        ary
      end
    end

    def self.code_for_extrait
      @@code_for_extrait ||= begin
        main_droite = []
        main_gauche = []
        (first_mesure..last_mesure).to_a.each do |num|
          mesure = data_mesures[num]||['','']
          main_droite << mesure[0]
          main_gauche << mesure[1]
        end

        <<-LILYPOND #.gsub(/\\/,'\\\\')
#{CommandLine.options[:keep] ? '--keep' : ''}
--page a4
--piano
--barres
--tune D
--time 3/4
#{numero_premiere_mesure}
#{options_proximity}
-> #{titre_id}
\\fixed c' { #{main_droite.join(' ')} }
\\fixed c { #{main_gauche.join(' ')} }
        LILYPOND
      end
    end

    def self.numero_premiere_mesure
      CommandLine.options[:mesure] ? '--mesure' : ''
    end

    def self.options_proximity
      if CommandLine.options[:proximity]
        "--proximity #{CommandLine.options[:proximity]}"
      end
    end

    # -----------------------------------------------------------

    def self.mus_path
      @@mus_path ||= File.join(CURRENT_FOLDER,"#{titre_id}.mus")
    end

    def self.svg_infolder_path
      @@path_svg_in_folder = File.join(svg_folder, "#{titre_id}.svg")
    end

    def self.svg_path
      @@svg_path = File.join(CURRENT_FOLDER, "#{titre_id}.svg")      
    end

    def self.svg_infolder_template_path
      @@svg_infolder_template_path = File.join(svg_folder, "#{titre_id}-%s.svg")
    end
    def self.svg_template_path 
      @@svg_template_path = File.join(CURRENT_FOLDER, "#{titre_id}-%s.svg")      
    end

    def self.svg_folder 
      @@svg_folder ||= File.join(CURRENT_FOLDER, titre_id)
    end


    def self.titre_id
      @@titre_id ||= "#{prefix}_mm#{first_mesure}-#{last_mesure}"
    end


    def self.prefix
      @@prefix ||= CommandLine.options[:prefix] || 'score_extrait'
    end

    def self.first_mesure
      @@first_mesure ||= CommandLine.first_mesure || 1
    end
    def self.last_mesure
      @@last_mesure ||= CommandLine.last_mesure || nombre_mesures
    end


    def self.mesures_defined?
      File.exist?(data_mesures_path) && not(data_mesures.nil?)
    end

    def self.nombre_mesures
      @@nombre_mesures ||= data_mesures.count
    end

    def self.data_mesures
      @@data_mesures ||= begin
        require data_mesures_path
        DATA_MESURES if defined?(DATA_MESURES)
      end
    end

    def self.data_mesures_path
      @@data_mesures_path ||= File.join(CURRENT_FOLDER, 'data_mesures.rb')
    end

  end #/class Score
end #/module ScoreExtraction
