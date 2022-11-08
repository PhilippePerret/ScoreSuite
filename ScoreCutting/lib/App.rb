# encoding: UTF-8

module ScoreCutting
  class App

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
          path = Dir["#{current_folder}/*.{jpg,jped,png,tiff}"][0]
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

        # 
        # On vérifie que le fichier soit valide, donc que ce soit
        # bien une image et pas autre chose (pas un PDF)
        # 
        if path.nil?
          raise ERRORS[:image_not_defined]
        elsif not(File.exist?(path))
          raise ERRORS[:unfound_file] % path
        elsif File.extname(path).downcase == '.pdf'
          raise ERRORS[:not_a_pdf]
        elsif not(['.jpg','.jpeg','.tiff','.png'].include?(File.extname(path).downcase))
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
      rescue Exception => e
        puts e.message
        puts e.backtrace.join("\n")
        retour[:ok] = false
        retour[:error] = e.message
      end
      WAA.send({class:'App', method:'askForScore', data: retour })
    end

    def self.current_folder
      @@current_folder
    end

    def self.current_folder=(value)
      @@current_folder = value
    end

  end #/class App
end #/module ScoreCutting
