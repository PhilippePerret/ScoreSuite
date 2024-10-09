module ScoreBuilder
class App
class << self

  # Le dossier dans lequel on a lancé l’application OU celui fourni
  # en premier argument.
  attr_accessor :current_folder

  # Méthode qui cherche le dossier courant. Il peut être défini
  # soit en premier argument de la commande ’score-builder’, soit en 
  # variable d’argument ’CUR_DIR’ ou ’CURRENT_FOLDER’, soit en
  # tant que dossier courant (dans cet ordre de préférence)
  def set_current_folder
    self.current_folder =
        get_folder_in_prompt \
        || ENV['CUR_DIR']  \
        || ENV['CURRENT_FOLDER'] \
        || File.expand_path(ENV['PWD'])
  end

  def get_folder_in_prompt
    ARGV.each do |arg|
      return arg if File.exist?(arg) && File.directory?(arg)
    end
    return nil
  end

  # Méthode qui s’assure, avant d’ouvrir la page, que le dossier
  # dans lequel l’application a été ouverte (ou en paramètre) est
  # un dossier correct.
  # 
  # Un dossier correct :
  #   - ne possède pas de ’#’ ou de ’/’ dans son nom
  #   - contient un fichier .mus
  #   - produit les SVG d’après le code MUS
  #   Optionnellement :
  #     - définit une partition originale
  # 
  def check_current_folder
    analyzer = FolderAnalyzer.new(current_folder)
    unless analyzer.valid?
      puts <<~TEXT.jaune
      Le dossier courant(*) n’est pas un dossier ScoreBuilder valide :
      ERREUR : #{analyzer.error.rouge}
      #{"(*) #{current_folder}".gris}#{''.jaune_}

      Si vous avez modifié de force un élément comme le nom du
      dossier ou le nom du fichier .mus, vous pouvez détruire le 
      fichier : score_builder.yaml pour forcer la prise en compte 
      de ces changements.
      
      TEXT
      return false if not(ScoreBuilder.interactive_mode?)
      return Q.yes?("Dois-je poursuivre ?".jaune)
    else
      #
      # Dossier valide
      # 

      # - En cas d’absence de la partition originale (ou ses pages) -
      if not(analyzer.original_score?)
        puts <<~TEXT.orange
        Il n’y a pas de partition originale. Vous allez donc travailler
        sans modèle pour établir votre partition.
        Si vous changez d’avis, il suffira de mettre le PDF de la par-
        tition de référence dans ce dossier pour que nous la traitions.
        TEXT
      end

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
      nombre_backups: MusCode.new(musfile).get_nombre_backups,
      config_sbuilder: get_config_sbuilder
    )
    WAA.send(class:"App", method:"onLoad", data: folder_data)
  end

  def get_config_sbuilder
    if File.exist?(config_path)
      YAML.safe_load(IO.read(config_path),**YAML_OPTIONS)
    else nil end
  end

  def save_config_sbuilder(wdata)
    IO.write(config_path, wdata['options'].to_yaml)
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
    puts "Enregistrement des notes…".jaune
    begin
      notes = wdata.delete('notes')
      if notes.empty?
        File.delete(notes_path) if File.exist?(notes_path)
      else
        IO.write(notes_path, notes.map{|n|CGI.unescape(n)}.to_yaml)
        puts "Notes enregistrées.".vert
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

  # Pour actualiser les manuels en ligne (ce sont les manuels qui 
  # sont affichés dans l’application)
  # 
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
