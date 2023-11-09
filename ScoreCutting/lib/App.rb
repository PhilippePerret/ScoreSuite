# encoding: UTF-8

module ScoreCutting
  class App

    IMG_EXTENSIONS = %w{jpg jpeg png tiff}

    # Pour trouver le numéro de page suivant
    REG_SYSTEM_NAME = /^([^0-9]+)([0-9]+?)([^0-9]+)$/


    ##
    # Méthode appelée pour charger la page suivante (pour la découper
    # sans avoir à tout recharger)
    # waadata ressemble à :
    # {"folder"=>"/Users/philippeperret/__Current_Work__/Bernard_Waterlot/Partitions/Schubert/Traited-test", "source"=>"page-01.jpg"}
    def self.get_other_page(waadata)
      retour = {ok:true, msg:nil}
      for_next = waadata["for_next"]
      puts "Page #{for_next ? "suivante" : "précédente"} avec : #{waadata.inspect}"
      begin
        fname   = waadata["source"]
        ffolder = waadata["folder"]
        raise "Ne contient pas de chiffre…" unless fname.match?(REG_SYSTEM_NAME)
        pref, nombre, suf = fname.scan(REG_SYSTEM_NAME).to_a[0]
        len_nombre = nombre.length
        nombre = nombre.to_i
        next_nombre = for_next ? nombre + 1 : nombre - 1
        othername = "#{pref}#{next_nombre}#{suf}"
        otherpath = File.join(ffolder, othername)
        unless File.exist?(otherpath)
          othername = "#{pref}#{next_nombre.to_s.rjust(len_nombre,'0')}#{suf}"
          otherpath = File.join(ffolder, othername)
        end
        if File.exist?(otherpath)
          retour.merge!(other_page: {folder: ffolder, source:othername})
        else
          raise "Le fichier #{otherpath} est introuvable. Pas de page suivante."
        end

      rescue Exception => e
        retour.merge!(ok:false, msg:"Impossible de passer à la page #{for_next ? "suivante" : "précédente"} : #{e.message}")
      end
      WAA.send(class:"App", method:"onLoadOtherPage",data:retour)
    end


    ##
    # Au tout chargement de l'application, on vérifie que les
    # informations aient été bien fournies pour produire le 
    # découpage.
    # -> Il faut qu'une image ait été précisée et que ce soit
    #    vraiment une image.
    # @return {String} Le chemin d'accès à l'image, pour que la
    # méthode serve aussi bien au lancement qu'à l'appel de l'UI
    # @return NIL en cas d'échec
    def self.check_and_get_partition
      path = ARGV[0]
      begin
        # 
        # S'il n'y a pas d'argument, on cherche la première image
        # (note : est-ce qu'on ne pourrait pas faire ça au démarrage ?)
        # 
        if path.nil?
          # 
          # Pas d'argument => on cherche la première image
          # 
          path = Dir["#{current_folder}/*.{jpg,jpeg,png,tiff}"][0]
        elsif path.start_with?('./')
          # 
          # Un argument qui commence par ./ => image dans le dossier
          # 
          path = File.expand_path(path)
        elsif File.exist?(File.join(current_folder, path))
          # 
          # Un nom de fichier dans le dossier => on prend son path
          # 
          path = File.join(current_folder, path)
        end

        raise ERRORS[:image_not_defined] if path.nil?

        if File.extname(path) == "" || not(IMG_EXTENSIONS.include?(File.extname(path).downcase[1..-1]))
          IMG_EXTENSIONS.each do |ext|
            if File.exist?("#{path}.#{ext}")
              path = "#{path}.#{ext}"
              break
            end
          end
        end
        path = File.expand_path(path)

        # 
        # On vérifie que le fichier soit valide, donc que ce soit
        # bien une image et pas autre chose (pas un PDF)
        # 
        if not(File.exist?(path))
          raise ERRORS[:unfound_file] % path
        elsif File.extname(path).downcase == '.pdf'
          raise ERRORS[:not_a_pdf]
        elsif not(IMG_EXTENSIONS.include?(File.extname(path).downcase[1..-1]))
          raise ERRORS[:not_a_image] % path
        end
      rescue Exception => e
        puts e.message.rouge
        return nil
      else
        return path # ok
      end
    end

    def self.run_bash_code(data)
      code = data['code']
      # puts "Code : #{code.inspect}"
      # 
      # Le dossier qui contiendra les systèmes
      # 
      sys_folder = File.join(data['folder'],'systems')

      # NON : il ne faut surtout pas le détruire car il peut déjà
      # contenir les systèmes d'une page précédente
      # FileUtils.rm_rf(sys_folder) if File.exist?(sys_folder)

      #
      # On crée le dossier si c'est nécessaire
      # 
      `mkdir -p "#{sys_folder}"`
      
      res = `#{code}`
      if res != ''
        puts "Un problème est survenu :".rouge
        puts res.rouge
        data = {ok:false, error: res}
      else
        puts "La partition a été découpée.".vert
        data = {ok: true}
      end
      # Message au client
      WAA.send(class:'App',method:'onCutScore',data:data)
    end

    def self.get_score_path
      retour = {ok: true, error: nil, path: nil}
      begin
        path = check_and_get_partition || raise('Abandon')
        puts "Partition : #{path}".jaune
        retour[:path] = path
        retour.merge!({
          path:         path,
          next_system_number:  get_next_system_number
        })
      rescue Exception => e
        puts e.message
        puts e.backtrace.join("\n")
        retour[:ok] = false
        retour[:error] = e.message
      end
      WAA.send({class:'App', method:'askForScore', data: retour })
    end

    def self.get_next_system_number
      if File.exist?(File.join(current_folder, "systems"))
        lessys = Dir["#{current_folder}/systems/system-*.jpg"].map { |pa| File.basename(pa) }
        if lessys.empty?
          return 1
        else
          lessys.sort.last.sub(/^system\-/,'').sub(/\.jpg$/,'').to_i + 1
        end
      else
        return 1
      end
      
    end

    def self.current_folder
      @@current_folder
    end

    def self.current_folder=(value)
      @@current_folder = value
    end

  end #/class App
end #/module ScoreCutting
