=begin
  Module de création d'une nouvelle analyse
=end
module ScoreAnalyse
class Analyse
###################       CLASSE      ###################
class << self

  ##
  # Méthode qui procède à la création de l'analyse, avec les
  # données +data+ qui peuvent être fournies ou pas.
  # 
  # @return l'instance de la nouvelle analyse créée
  # 
  def create_new_analyse(data = nil, from_server = false)
    out("OPE: Je dois créer la nouvelle analyse avec #{data.inspect}")

    #
    # On doit avoir toutes les données
    # 
    data = complete_data(data)
    
    # 
    # Création des dossiers (dont le dossier des systèmes)
    # 
    create_folders(data)

    #
    # Première répartition des systèmes
    # 
    prepare_positions_systems(data)

    # 
    # Instanciation de l'analyse
    # 
    analyse = Analyse.new(data[:path])

    # 
    # Fichier de préférences par défaut
    # 
    FileUtils.cp(preferences_model, analyse.preferences_path)

    # 
    # Fichier infos.yaml
    # 
    analyse.save_infos(data)

    #
    # Fichier des premiers tags
    # 
    analyse.analyse_tags = first_tags_analyse
    analyse.save_analyse_tags

    #
    # Ouverture du dossier de l'analyse dans le Finder
    # 
    `open -a Finder "#{analyse.path}"`

    # 
    # Enregistrement comme analyse courante
    # 
    App.set_last_analyse(analyse)


    out("RES: Nouvelle analyse créée avec succès.")

    if from_server
      # Création en ligne de commande
      # 
      return analyse
    else
      # 
      # 
      # Création par le navigateur
      # 
      WAA.send(class:'Analyse',method:'onCreate',data:analyse.all_data_for_client)
    end

  rescue Exception => e
    if from_server
      out(e.message.rouge)
      puts e.backtrace[0..4].join("\n")
    else
      WAA.send(class:'App',method:'onError',data:{error:e.message})      
    end
  end


  ##
  # Retourne les premiers tags (explicatifs) à la création de
  # l'analyse.
  def first_tags_analyse
    ary = []
    MESSAGES[:first_tags_at_creation].each_with_index do |msg, idx|
      ary << {id:1, top:100, left: 220 * idx, width: 200, type:'txt', subtype:'size3', content:msg}
    end
    return ary
  end
  
  ##
  # Chemin d'accès au fichier modèle des préférences
  def preferences_model
    File.join(APP_FOLDER,'assets','models','preferences.yaml')
  end

  ##
  # Relève des systèmes et positionnements
  # 
  def prepare_positions_systems(data)
    require 'dimensions'
    folder_systems = File.join(data[:path],'systems')
    curtop = 400
    dsys = []
    Dir["#{folder_systems}/*.*"].sort.each do |path|

      dsys << {image_name: File.basename(path), top: curtop, left: 0}
      # 
      # On calcule le prochain top en fonction de la hauteur du
      # système courant
      # 
      h = Dimensions.height(path)
      curtop += h + 100
    end
    # 
    # On consigne ces systèmes
    # 
    data.merge!(systems: dsys)
  end

  ##
  # Création des dossiers principaux de l'analyse
  # 
  def create_folders(data)
    # 
    #   Dossier principal
    # + Dossier des systèmes
    # (mkdir crée la hiérarchie jusqu'au dossier)
    # 
    sys_folder = mkdir(File.join(data[:path],'systems'))

    # 
    # Existe-t-il des systèmes à prendre ?
    # 
    original_sys_folder = File.join(CURRENT_FOLDER,'systems')
    if File.exist?(original_sys_folder) && Q.yes?(MESSAGES[:ask_use_systems_folder].jaune)
      Dir["#{original_sys_folder}/*.{jpg,jpeg,png,svg}"].each do |fsys|
        `mv "#{fsys}" "#{sys_folder}/"`
      end
      if Dir["#{original_sys_folder}/**/*.*"].count == 0
        FileUtils.rm_rf(original_sys_folder)
      end
    else
      mkdir(sys_folder)
    end

  end

  ##
  # Pour compléter les données (infos)
  # 
  def complete_data(data)
    clear unless debug?
    data ||= {
      # Juste pour voir toutes les données
      folder:         nil,
      analyse_id:     nil,
      path:           nil, # folder+analyse_id
      piece_title:    nil,
      composer:       nil,
      analyse_title:  nil,
      analyste:       nil,
      created_at:     nil,
      updated_at:     nil,
      waa_version:    nil,
      app_version:    nil
    }

    get_and_check_folder(data)
    while not(analyse_id_conform?(data))
      data[:analyse_id]     ||= Q.ask('Identifiant de l’analyse'.jaune)
    end
    data[:piece_title]    ||= Q.ask("Titre de l'œuvre".jaune)
    data[:composer]       ||= Q.ask("Compositeur de l'œuvre".jaune)
    data[:analyse_title]  ||= Q.ask('Titre de l’analyse'.jaune)
    data[:analyste]       ||= Q.ask("Analyste".jaune)
    data.merge!({
      path:         File.join(CURRENT_FOLDER, data[:analyse_id]),
      created_at:   Time.now.to_i,
      updated_at:   Time.now.to_i,
      waa_version:  WAA.version,
      app_version:  App.version
    })

    return data
  end

  ##
  # Définit le dossier de l'analyse en vérifiant qu'il soit
  # conforme.
  # 
  def get_and_check_folder(data)
    folder = data[:folder] || CURRENT_FOLDER
    folder != APP_FOLDER  || raise(ERRORS[:no_analyse_in_app_folder])
    File.exist?(folder)   || raise(ERRORS[:folder_unfound] % folder)
    # 
    # L'application ne doit pas déjà exister
    # 
    File.exist?(File.join(folder,data[:analyse_id])) && begin
      raise(ERRORS[:analyse_already_exists] % [data[:analyse_id], folder])
    end
    # 
    # On prend ce dossier
    # 
    data.merge!(folder: folder)
  end

  # @return true si l'identifiant d'analyse est conforme
  def analyse_id_conform?(data)
    id = data[:analyse_id]
    id || return
    id.gsub(/[a-zA-Z0-9_\-]/,'') == '' || raise(ERRORS[:analyse_id_invalid] % id)
  rescue Exception => e
    out(e.message.rouge)
    return false
  else
    return true
  end

end #/<< self
###################       INSTANCE      ###################
  
end #/class Analyse
end #/module ScoreAnalyse
