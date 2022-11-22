# encoding: UTF-8

module ScoreCutting
  class App
    def self.run_bash_code(data)
      code = data['code']
      puts "Code : #{code.inspect}"
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
      path = ARGV[0]
      begin
        # 
        # S'il n'y a pas d'argument, on cherche la première image
        # (note : est-ce qu'on ne pourrait pas faire ça au démarrage ?)
        # 
        if path.nil?
          path = Dir["#{CURRENT_FOLDER}/*.{jpg,jped,png,tiff}"][0]
        end
        not(path.nil?) || raise("Image non définie.")
        path = File.join(CURRENT_FOLDER,path) if not(path.start_with?('/'))
        File.exist?(path) || raise("Image introuvable : #{path}.")
        retour[:path] = path
      rescue Exception => e
        puts e.message
        puts e.backtrace.join("\n")
        retour[:ok] = false
        retour[:error] = e.message
      end
      WAA.send({class:'App', method:'askForScore', data: retour })
    end

  end #/class App
end #/module ScoreCutting
