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
      mus_code: CGI.escape(IO.read(musfile)),
      affixe: File.basename(musfile, File.extname(musfile)),
      nombre_backups: MusCode.new(musfile).get_nombre_backups
    )
    WAA.send(class:"App", method:"onLoad", data: folder_data)
  end

  # @api
  # 
  # Chargement des notes
  def load_notes(wdata)
    notes = 
      if File.exist?(notes_path)
        YAML.safe_load(IO.read(notes_path),**YAML_OPTIONS)
      else
        ["Ma toute première note !"]
      end
    wdata.merge!(ok:true, notes: notes.map{|n|CGI.escape(n)})
    WAA.send(class:"BlocNotes", method:"onLoadedNotes", data:wdata)
  end

  def notes_path
    @notes_path ||= File.join(current_folder,'builder_notes.yaml').freeze
  end

  # @api
  def save_notes(wdata)
    begin
      notes = wdata.delete('notes')
      if notes.empty?
        File.delete(notes_path) if File.exist?(notes_path)
      else
        IO.write(notes_path, notes.map{|n|CGI.unescape(n)}.to_yaml)
      end
      wdata.merge!(ok: true)
    rescue Exception => e
      wdata.merge!(ok: false, error: e.message)
    end
    WAA.send(class:"BlocNotes",method:"onSavedNotes", data:wdata)
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

  DATA_MANUELS_ONLINE = [
    {
      id:           'code-mus', # id dans l’application
      name:         "Aide Code MUS",
      distant_name: "Manuel_code_MUS.pdf", 
      local_path:   File.absolute_path("#{APP_FOLDER}/../ScoreImage/Manuel/Manuel_code_MUS.pdf")
    },
    {
      id:           'score-builder',
      name:         "Manuel Score-Builder",
      distant_name: "Manuel_ScoreBuilder.pdf", 
      local_path:   File.join(APP_FOLDER,'Manuels','Manuel.pdf')
    },
    {
      id:           'quick-help',
      name:         "Aide Rapide Score-Builder", 
      distant_name: "ScoreBuilder_QuickHelp.pdf", 
      local_path:   File.join(APP_FOLDER,'Manuels','Aide_rapide.pdf')
    },
  ].freeze

  def update_manuels_online(wdata)
    ok        = true
    msgs_err  = []
    DATA_MANUELS_ONLINE.each do |dmanuel|
      src = dmanuel[:local_path]
      # Le manuel local doit exister
      if not(File.exist?(src))
        ok = false
        msgs_err << "Le fichier “#{src}“ est introuvable…"
        next
      end
      dst = "public/Manuels/#{dmanuel[:distant_name]}"
      cmd = "scp -p \"#{src}\" #{SERVEUR_SSH}:www/#{dst}"
      res = `#{cmd} 2>&1`
      if res == ""
        # OK
      else
        ok = false
        msgs_err << res
      end
    end
    wdata.merge!(ok:ok, error:msgs_err.join(", "))
    WAA.send(class:"Helper",method:"onUpdatedPdfOnline",data:wdata)
  end

  def edit_manuel(wdata)
    manuel_id = wdata['manuel_id']
    puts "ID du manuel à ouvrir : #{manuel_id}"
    DATA_MANUELS_ONLINE.each do |dmanuel|
      if dmanuel[:id] == manuel_id
        `open -a Typora "#{dmanuel[:local_path].sub(/\.pdf$/,'.md')}"`
        break
      end
    end
  end

end #/<< self
end #/class App
end #/module ScoreBuilder
