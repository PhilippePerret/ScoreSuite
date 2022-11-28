# encoding: UTF-8
=begin

  Table d'analyse côté serveur.

=end
module ScoreAnalyse
class Analyse

  class << self

    # {Analyse} Analyse courante (détectée au démarrage, surtout,
    # sauf en cas de création depuis le navigateur)
    attr_accessor :current
  
  end

  ##
  # Pour demander le chargement de l'analyse au besoin.
  # 
  # Les différents cas dans l'ordre de précédence :
  # 
  #   ((s'il y a un argument en ligne de commande))
  #   - si cette analyse existe dans le dossier courant
  #     => on ouvre cette analyse
  #   - si cette analyse n'existe pas
  #     => on demande à l'utilisateur s'il veut créer la nouvelle
  #        analyse.
  #   ((s'il n'y a pas d'argument en ligne de commande))
  #   - le terminal a été ouvert dans un dossier contenant une 
  #     analyse => on la prend
  #   - le terminal a été ouvert dans un dossier contenant plusieurs
  #     analyses => on demande laquelle ouvrir
  #     (bien noter que dans ce cas, chaque analyse est un dossier
  #      qui contient ses fichiers d'analyse et son dossier systems)
  #   - le terminal a été ouvert dans un dossier d'analyse
  #     => On la prend comme analyse courante
  #   ((à partir d'ici, pas d'analyse dans le dossier courtant, ni 
  #     de dossier 'systems'))
  #   - pas d'argument mais une dernière analyse enregistrée
  #     => on prend la dernière analyse enregistrée
  #   - sinon : on indique qu'aucune analyse n'est chargée, on va
  #     afficher un panneau d'aide.
  # 
  def self.check_current

    affixe = ARGV[0]
    analyse_folder = nil

    if affixe

      analyse_folder = File.join(CURRENT_FOLDER,affixe)

      if File.exist?(analyse_folder)
        
        # 
        # On prend cette analyse
        # 
        self.current = new(analyse_folder)
        return true

      else
        
        # 
        # Nouvelle analyse à créer
        # 
        if Q.yes?("Dois-je créer la nouvelle analyse '#{affixe}' dans ce dossier ?".jaune)
          require_relative '../modules/create_analyse'
          self.current = create_new_analyse(
            {folder: CURRENT_FOLDER, analyse_id: affixe},
            true # pour indiquer que ça vient de la ligne de commande
          )
          return true
        else
          # Pour poursuivre
          affixe = nil
          analyse_folder = nil
        end
      end
    end

    #
    # Le dossier courant est-il une analyse ?
    # 
    if analyse_conform?(CURRENT_FOLDER)
      self.current = new(CURRENT_FOLDER)
      return true
    end

    #
    # Existe-t-il une analyse dans le dossier courant ? On la 
    # reconnait au fait qu'il y a un dossier contenant un fichier
    # infos.yaml et un dossier 'systems'
    # 
    analyses = Dir["#{CURRENT_FOLDER}/*"].select do |pth|
      analyse_conform?(pth)
    end.map do |path|
      new(path)
    end
    if analyses.count == 0
      # On passe à la suite
    elsif analyses.count == 1
      self.current = analyses.first
    else
      self.current = Q.select("Quelle analyse ouvrir ?") do |q|
        analyses.each do |analyse|
          q.choice analyse.name, analyse
        end
        q.choice "Aucune", nil
        q.per_page analyses.count
      end
    end

    #
    # En dernier recours on prend la dernière analyse
    # 
    self.current ||= last_analyse 
    
    return true # pour poursuivre
  end

  ##
  # @return true si le chemin +path+ est le dossier d'une analyse
  # 
  def self.analyse_conform?(path)
    return false if not File.directory?(path)
    return false if not File.exist?(File.join(path,'systems'))
    return false if not File.exist?(File.join(path,'infos.yaml'))
    return true
  end

  ##
  # Méthode appelée au chargement de la page HTML
  # (en cas de rechargement aussi)
  # 
  # [N0001]
  #   Même s'il existe une analyse courante, on refait une instance
  #   vierge pour forcer le rechargement des données. Car la même 
  #   peut être appelée après un rechargement forcé de la page HTML.
  #   Or, dans le cas d'un rechargement forcé, l'instance ruby reste-
  #   rait quand même la même (donc avec les toutes premières don-
  #   nées) et, en conséquence, les modifications survenues entre la
  #   première ouverture et ce rechargement ne seraient pas remontés
  #   et on aurait l'impression de repartir de la première ouverture.
  # 
  def self.get_analyse_if_exist

    # 
    # On cherche le fichier contenant les spécifications
    # courantes de l'application.
    # 
    if self.current

      # cf. [N0001]
      self.current = Analyse.new(File.expand_path(current.path))
      self.current.make_backup
      out("OPE: Chargement de l'analyse #{current.name.inspect} de la pièce #{current.piece_title.inspect}.")

      WAA.send({
        class:  'App',
        method: 'onload_analyse',
        data:   current.all_data_for_client
      })

    else

      out("OPE: Pas d'analyse courante.")

    end

  end

  def self.save_infos(data)
    # puts "-> save_infos(#{data.inspect})"
    analyse_id = data['infos']['analyse_id']
    analyse = Analyse.new(data['path'])
    data['infos'].merge!('updated_at' => Time.new.to_i)
    analyse.infos = data['infos']
    analyse.save_infos

    WAA.send(class:'AnalyseSaver',method:'onSavedInfos',data:{ok:true})
  end

  def self.save_preferences(data)
    # puts "-> save_preferences(#{data.inspect})"
    analyse = Analyse.new(data['path'])
    analyse.preferences = data['preferences']
    analyse.save_preferences

    WAA.send(class:'AnalyseSaver',method:'onSavedPreferences',data:{ok:true})
  end

  def self.save_tags(data)
    # puts "-> save_tags(#{data.inspect})"
    analyse_id = data['analyse_id']
    analyse = Analyse.new(data['path'])
    analyse.analyse_tags = data['tags']
    analyse.save_analyse_tags

    WAA.send(class:'AnalyseSaver',method:'onSavedAnalyseTags',data:{ok:true})
  end

  ##
  # Méthode appelée par la méthode client Analyse.refresh
  # +data+ contient le 'path' du dossier de l'analyse.
  # Pour le moment, cette méthode ne sert qu'à une chose : faire
  # la liste des systèmes une fois qu'ils ont été modifiés (ou pas)
  def self.refresh(data)

    #
    # Rafraichir les données systèmes de l'analyse (dans
    # le fichier enregistré) en tenant compte des ajouts et
    # des retraits éventuels.
    analyse = Analyse.new(data['analyse_path'])
    analyse.update_systems

    #
    # Renvoyer une donnée systèmes complète
    # 
    data.merge!('systems' => analyse.systems_for_client)

    WAA.send(
      class:'Analyse', method:'refreshCurrent', data:data
    )
  end


  ##
  # Pour exporter l'analyse sous forme de fichier HTML
  # 
  def self.exportToHTML(data)
    require_relative '../modules/export_to_html'
    analyse = Analyse.new(data['path'])
    proceed_export_to_html(analyse, data)
  end


  # @return true si une dernière analyse est définie et qu'elle
  # existe.
  def self.last_analyse?
    not(last_analyse.nil?) && last_analyse.exist?
  end

  def self.last_analyse
    @@last_analyse ||= begin
      if App.last_analyse_path
        Analyse.new(App.last_analyse_path)
      end
    end
  end

  #################################################################


  ###### INSTANCE 


  #################################################################

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def exist?
    File.exist?(path)
  end

  def window_size
    return [preferences['window_width']||1000,preferences['window_height']||1000]
  end

  def save_analyse_tags
    File.open(analyse_tags_path,'wb'){|f|f.write analyse_tags.to_yaml}    
  end

  def analyse_tags
    @analyse_tags ||= begin
      if File.exist?(analyse_tags_path)
        YAML.load_file(analyse_tags_path)
      else
        []
      end
    end
  end
  def analyse_tags=(data)
    @analyse_tags = data
  end
  def analyse_tags_path
    @analyse_tags_path ||= File.join(path,'analyse_tags.yaml')
  end

  # Sauver les infos (dont les données des systèmes)
  def save_infos(new_infos = nil)
    @infos = new_infos unless new_infos.nil?
    # puts "Infos enregistrées : \n#{infos.to_yaml}"
    File.open(infos_path,'wb'){|f|f.write infos.to_yaml}    
  end

  # Les infos
  def infos
    @infos ||= begin
      if File.exist?(infos_path)
        YAML.load_file(infos_path)
      else
        raise "Les infos sont introuvables !"
      end
    end
  end
  def infos=(data)
    @infos = data
  end
  def infos_path
    @infos_path ||= File.join(path,'infos.yaml')
  end

  def save_preferences
    File.open(preferences_path,'wb'){|f|f.write preferences.to_yaml}
  end
  def preferences
    @preferences ||= begin
      if File.exist?(preferences_path)
        YAML.load_file(preferences_path)
      else
        {
          autosave: true,
          animate:  false
        }
      end
    end
  end
  def preferences=(data)
    @preferences = data
  end
  def preferences_path
    @preferences_path ||= File.join(path,'preferences.yaml')
  end

  ##
  # Pour renseigner la donnée :data qui sera renvoyée au client et
  # lui permettra d'afficher l'analyse
  def all_data_for_client
    {
      infos:              infos,
      preferences:        preferences,
      systems:            systems_for_client,
      systems_in_folder:  systems_in_folder,
      analyse_tags:       analyse_tags,
      path:               path
    }
  end

  def systems_for_client
    data_systems
  end

  ##
  # Les noms de systèmes qui existent actuellement dans le 
  # dossier des systèmes, pour corrections éventuelles. Surtout
  # utile aux débuts de la création de l'analyse.
  #
  # C'est une liste de noms de fichiers, classés par ordre alphabé-
  # tique
  # 
  def systems_in_folder
    Dir["#{folder_systems}/*.{jpg,jpeg,png,svg}"].map do |p|
      File.basename(p)
    end.sort
  end

  ##
  # Méthode pour actualiser la liste des systèmes (appelée par le
  # bouton client "Rafraichir", par exemple)
  #
  def update_systems
    require 'dimensions'
    # 
    # Table avec en clé les systèmes actuels (pour voir
    # ceux qui existent et ceux qui ont été supprimés)
    # 
    table_per_image = {}
    data_systems.each do |dsystem|
      table_per_image.merge!(dsystem[:image_name] => dsystem)
    end

    current_top       = 0
    new_data_systems  = []

    systems_in_folder.each do |img|
      if table_per_image.key?(img)
        # Système connu
        dsys = table_per_image.delete(img)
      else
        # Ajouter ce système
        dsys = {image_name: img, left:0, top:current_top, height:Dimensions.height(img)}
      end
      new_data_systems << dsys
      current_top += dsys[:height]
    end

    #
    # S'il reste des systèmes dans table_per_image, c'est qu'ils
    # ont été supprimés. Mais on s'en fiche puisque la nouvelle
    # liste est établie en cherchant les nouveaux systèmes.
    # 
    @data_systems = new_data_systems
    @infos.merge!('systems' => @data_systems)
    save_infos

  end

  # --- Backups Methods ---

  def make_backup
    pth = mkdir(File.join(backup_folder,"#{Time.now.strftime('%Y%m%d-%H-%M')}-Backup"))
    [
      [analyse_tags_path  , File.join(pth,'analyse_tags.yaml')],
      [infos_path         , File.join(pth,'infos.yaml')],
      [preferences_path   , File.join(pth,'preferences.yaml')],
    ].each do |src, dst|
      FileUtils.cp(src, dst)
      # puts "Backup de\n#{src}\nvers :\n#{dst}"
    end
    # 
    # Faut-il supprimer un backup ? (on en garde seulement 30)
    # 
    backups = Dir["#{backup_folder}/*"]
    while backups.count > 50
      FileUtils.rm_rf(backups.sort.first)
      backups = Dir["#{backup_folder}/*"]
    end
  end

  def backup_folder
    @backup_folder ||= mkdir(File.join(path,'backups'))
  end

  # --- Data Systems Methods ---

  def data_systems
    @data_systems ||= infos['systems'] || []
  end

  # --- Paths Methods ---

  # Dossier contenant les images des systèmes (dans l'ordre)
  def folder_systems
    @folder_systems ||= File.join(path,'systems')
  end

  def folder_export
    @folder_export ||= mkdir(File.join(path,'export'))
  end


  def images_folder
    @images_folder ||= mkdir(File.join(path,'images'))
  end
  
  def piece_title
    @piece_title ||= infos['piece_title']||'-non défini-'
  end

  def affixe
    @affixe ||= File.basename(path)
  end
  alias :name :affixe

end #/class Analyse
end #/module ScoreAnalyse
