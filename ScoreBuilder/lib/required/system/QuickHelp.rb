module WaaApp
class QuickHelp

  ##
  # Dois remonter le texte de l'aide spécifiée par data['path']
  # 
  def self.get_help_text(data)
    retour = {ok:true, msg: nil}

    help_path = data['path']
    unless File.exist?(help_path)
      help_path = File.join(APP_FOLDER, help_path)
    end
    if File.exist?(help_path)
      retour.merge!(help_text: "#{File.read(help_path)}")
    else
      retour[:ok] = false
      retour[:msg] = "Le fichier d'aide '#{data['path']}' est introuvable."
    end
    WAA.send(class:'QuickHelp',method:'onGetCode',data:retour)
  end

end #/class QuickHelp
end #/module WaaApp
