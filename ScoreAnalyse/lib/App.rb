# encoding: UTF-8
=begin

  class ScoreAnalyse::App
  -----------------------
  Gestion de l'application.

=end
module ScoreAnalyse
class App

  def self.aide
    require_relative 'Aide'
    less(AIDE)  
  end

  def self.version
    @@version ||= File.read(File.join(APP_FOLDER,'VERSION')).strip
  end

  ##
  # Pour définir la dernière analyse
  # 
  def self.set_last_analyse(analyse)
    set_preferences(last_analyse_path: analyse.path)
  end

  ##
  # Redéfinit les préférences et les sauve
  #
  def self.set_preferences(data)
    preferences # pour forcer la définition
    @@preferences = @@preferences.merge(data)
    save_preferences
  end

  ##
  # Pour charger les thèmes et leurs données
  # et les remonter côté serveur
  def self.load_themes(data)
    folder_themes = mkdir(File.join(APP_FOLDER,'assets','themes'))
    themes = Dir["#{folder_themes}/*.yaml"].map do |pth|
      dtheme = YAML.load_file(pth, aliases:true)
      dtheme.merge!(name: File.basename(pth, File.extname(pth)))
    end
    WAA.send(class:'Preferences', method:'onLoadedThemes', data:{themes: themes})
  end

  ##
  # Pour charger un thème (ses données)
  #
  def self.load_theme(data)
    folder_themes = mkdir(File.join(APP_FOLDER,'assets','themes'))
    theme_path = File.join(folder_themes,data['theme_name'])
    data_theme = YAML.load_file(theme_path, aliases:true)
    data = data.merge!(theme_data: data_theme)
    WAA.send({class:'Preferences',method:'onLoadedTheme', data:data})
  end


  ##
  # @return true s'il faut charger la dernière analyse
  #
  def self.load_last_analyse?
    preferences[:load_last_analyse] === true
  end

  def self.last_analyse_path
    @@last_analyse_path ||= preferences[:last_analyse_path]
  end

  ##
  # Retourne une table des préférences de l'application
  #
  def self.preferences
    @@preferences ||= begin
      if File.exist?(preferences_path)
        YAML.load_file(preferences_path)
      else
        DEFAULT_PREFERENCES
      end
    end 
  end

  def self.save_preferences
    File.open(preferences_path,'wb'){|f|f.write preferences.to_yaml}
  end


  def self.preferences_path
    @@preferences_path ||= File.join(APP_FOLDER,'prefs.rb')
  end


  ##
  # Méthode appelée depuis le panneau des outils, pour construire
  # rapidement une image en code muscore et en faire une image svg
  # 
  def self.build_image_from_code(data)
    retour = {ok: true, image_name: nil, error:nil}

    images_folder   = File.join(data['path'],'images')
    chantier_folder = mkdir(File.join(images_folder,'_Chantier'))
    code = data['code']
    
    # 
    # Noms et paths de l'image
    # 
    image_affixe = 
      if code.match?(/^-> ([a-z\-_0-9]+)$/i)
        code.match(/^-> ([a-z\-_0-9]+)$/i)[1]
      else
        "img-#{Time.now.to_i}"
      end 
    code_mus_name     = "#{image_affixe}.mus"
    code_mus_path     = File.join(chantier_folder,code_mus_name)
    built_image_path  = File.join(chantier_folder,image_affixe,"#{image_affixe}.svg")
    File.delete(built_image_path) if File.exist?(built_image_path)
    final_image_path  = File.join(images_folder,"#{image_affixe}.svg")
    File.delete(final_image_path) if File.exist?(final_image_path)
    # 
    # Écriture du code dans le fichier .mus
    # 
    File.write(code_mus_path, code)
    # 
    # On construit l'image
    # 
    res = produce_score_image(chantier_folder, code_mus_name)
    # puts "Retour production : #{res.inspect}"
    ok  = res.match?(/produite avec succès/) 
    # 
    # Vérification
    # 
    if ok && File.exist?(built_image_path)
      FileUtils.mv(built_image_path, final_image_path)
      retour.merge!({
        ok: true,
        image_name: "#{image_affixe}.svg"
      })
    else
      retour.merge!({
        ok:     false,
        error:  "Problème : #{res}"
      })
    end
    # 
    # Nom de l'image dans le presse-papier
    # 
    `echo "#{image_affixe}.svg" | pbcopy`
    # 
    # Retourner le nom de l'image
    # 
    WAA.send({class:'Tools', method:'onBuiltScoreImage', data:retour})
  end

  ##
  # Méthode qui produit l'image SVG à partir du code contenu dans le
  # fichier +image_name+ qui se trouve dans +folder+
  def self.produce_score_image(folder, image_name)
    cmd = "#{SCORE_SUITE_FOLDER}/ScoreImage/score_image.rb"
    cmd = "cd \"#{folder}\" && #{cmd} ./#{image_name}" # TODO stats ?
    return `#{cmd} 2>&1`
  end


  def self.run_score_writer(data)
    infolder  = data['folder']
    image     = data['image']
    image = nil if image.nil? || image.empty?
    # 
    # On cherche la première image '.mus' qu'on peut trouver, pour
    # l'ouvrir
    # 
    images = Dir["#{infolder}/**/*.mus"]
    if images.count
      chantier  = File.dirname(images.first)
      if image.nil?
        image = images.first
        image = File.basename(image, File.extname(image))
      end
    else
      chantier = File.join(infolder,'images','_Chantier')
      `mkdir -p "#{chantier}"`
    end
    image ||= 'new_image'

    `osascript -e 'Tell application "Terminal" to do shell script "cd \\"#{chantier}\\";score-writer \\"#{image}\\""'`

    WAA.send(class:'Tools',method:'onRanScoreWriter',data:{ok:true})
  end


DEFAULT_PREFERENCES = {
  load_last_analyse: true,
  last_analyse_path: nil,
}

end #/class App
end #/module ScoreAnalyse
