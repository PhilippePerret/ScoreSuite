require 'yaml'
require 'timeout'
module ScoreBuilder
class MusCode
class << self

  def cleanupBackups(waa_data)
    muscode = MusCode.new(waa_data['mus_file'])
    wd = 
      if (err_msg = muscode.cleanup_backups)
        {ok: false, error: err_msg}
      else
        {ok: true, nombre_backups: muscode.get_nombre_backups}
      end

    WAA.send(class: "UI", method:"onCleanedUpBackup", data:wd)
  end

  # = main =
  # @api
  # 
  # Méthode principale, appelée côté client pour fabriquer le code
  # final et fabriquer les images qui seront ensuite renvoyées
  # 
  def save_and_evaluate(waa_data)
    # puts "waa_data reçu pour save = #{waa_data}"
    muscode = MusCode.new(waa_data['mus_file'])
    
    # # On fait toujours une copie provisoire du code actuel
    muscode.backup

    code = waa_data['code']

    if code.nil? || code.empty?

      waa_data.merge!(ok: false, error: "Le code transmis est vide.")
    
    else
    
      # Enregistrement du code transmis
      muscode.save(code)

      # Production des images SVG
      report = muscode.produce_svg
      waa_data.merge!(report)

      # Retour du résultat
      waa_data.merge!(
        ope:        "Enregistrement et évaluation du code MUS.",
        folder:     main_folder,
        affixe:     mus_file_affixe,
        svg_images: current_score_svgs,
        nb_backups: muscode.get_nombre_backups,
      )
    end
    WAA.send(class:"MusCode", method: "onSavedAndEvaluated", data: waa_data)
  end

  def get_and_sort_svg_in(dossier)
    return [] if not(File.exist?(dossier))
    Dir["#{dossier}/*.svg"].map do |pth| 
      File.basename(pth)
    end.sort
  end

  # Instancier le module ruby (sauf s’il existe déjà)
  def init_ruby_module(wdata)
    if File.exist?(ruby_module_path)
      wdata.merge!(ok:false, error: "Un module ruby ’mus_functions.rb’ existe déjà.")
    else
      IO.write(ruby_module_path, CODE_RUBY_MODULE_DEFAULT)
      wdata.merge!(ok: true)
    end
    WAA.send(class:"Outils", method: "onRubyModuleInitied", data:wdata)
  end

  # Ouvrir le module ruby (s’il existe)
  def open_ruby_module(wdata)
    if File.exist?(ruby_module_path)
      `subl "#{File.dirname(ruby_module_path)}"`
      wdata.merge!(ok: true)
    else
      wdata.merge!(ok: false, error: "Le module ruby (#{File.basename(ruby_module_path)}) est introuvable.")
    end
    WAA.send(class:"Outils", method: "onRubyModuleOpened", data:wdata)
  end

  def ruby_module_path 
    @ruby_module_path ||= File.join(main_folder,"mus_functions.rb").freeze
  end


  def produce_midi_file(wdata)
    muscode = MusCode.new(wdata['mus_file'])
    err = muscode.produce_midi_file
    wdata.merge!(ok: err.nil?, error: err)
    WAA.send(class:"Outils",method:"onMidiFileProduced", data:wdata)
  end


  # Retourne la liste des images SVG produites (soit une seule,
  # soit plusieurs si la partition est longue)
  def current_score_svgs
    get_and_sort_svg_in(svg_folder)
  end

  # @prop Chemin d’accès au dossier contenant les SVG
  def svg_folder
    @svg_folder ||= File.join(main_folder,mus_file_affixe)
  end

  # @prop Affixe du fichier .mus (qui déterminera le nom du dossier)
  def mus_file_affixe
    @mus_file_affixe ||= File.basename(mus_file_path,File.extname(mus_file_path))
  end

  # @prop Chemin d’accès au fichier .mus
  def mus_file_path
    @mus_file_path ||= Dir["#{main_folder}/*.mus"].first
  end

  # @prop Chemin d’accès au fichier principal dans lequel a été
  # jouée la commande.
  def main_folder
    @main_folder ||= App.current_folder.freeze
  end

end #/<< self


# === INSTANCE ===

attr_reader :mus_file

def initialize(mus_file)
  @mus_file = mus_file
end

# = main =
# @api
# 
# Produit le ou les images SVG à partir du code mus
# 
# @return [Hash] Un rapport d’erreur contenant notamment :ok et
# :error pour indiquer si tout s’est bien passé.
# 
def produce_svg
  remove_all_svg

  outputs = ScoreSuiteLauncher.launch(
    :score_image, File.basename(mus_file), {
      in: File.dirname(mus_file),
      return_output: true
    })

  allright = outputs[:err].empty? \
    && not(outputs[:out].match?('error')) \
    && outputs[:out].match?(/(success|succès)/)
  report = {
    ok:     allright,
    error:  allright||"+err:#{outputs[:err]}\n+ out:#{outputs[:out]}"
  }

  # puts "\n\nOUPUTS:\n#{outputs}"
  return report
end

# @return NIL en cas de succès ou l’erreur rencontrée
def produce_midi_file
  puts "Je passe par -> #produce_midi_file"
  nfile = File.basename(mus_file)
  cmd = 'cd "%s" && score-image --midi "%s"'.freeze % [folder, mus_file.filename]
  puts "cmd = #{cmd}"
  res = `#{cmd}`
  puts "res = #{res}"
  allright = res.match?(/(success|succès)/)

  return allright ? nil : res
end

# === Functional Methods ===


def save(new_code)
  IO.write(mus_file, new_code)
end

def backup
  backup_path = File.join(backup_folder, "#{affixe}-#{Time.now.to_i}.mus")
  FileUtils.mv(mus_file, backup_path)
end

def get_nombre_backups
  Dir["#{backup_folder}/*"].count
end

# @return [String] Nettoie le dossier des backups
def cleanup_backups
  return nil if get_nombre_backups < 6
  Dir["#{backup_folder}/*"].map do |bckup|
    {name: File.basename(bckup), path: bckup}
  end.sort_by do |dbck|
    dbck[:name]
  end.reverse[5..-1].each do |dbck|
    File.delete( dbck[:path] )
  end

  return nil
end

# Destruction de toutes les images SVG
def remove_all_svg
  Dir["#{svg_folder}/*.svg"].each{|pth|File.delete(pth)}
end

# Récupération de toutes les images SVG
# (pour affichage)
def get_all_svg_images
  ScoreBuilder::MusCode.get_and_sort_svg_in(svg_folder)
end

def nombre_current_svg
  get_all_svg_images.count
end


# === Path Methods ===


def svg_folder
  @svg_folder ||= File.join(folder,affixe).freeze
end
def affixe
  @affixe ||= File.basename(mus_file, File.extname(mus_file))
end
def backup_folder
  @backup_folder ||= File.join(folder,'xbackups').freeze.tap{|d|FileUtils.mkdir_p(d)}
end
def folder
  @folder ||= File.dirname(mus_file).freeze
end

CODE_RUBY_MODULE_DEFAULT = <<~RUBY
module ScoreImage

  # Utiliser ’fn_draw_notes((...))’ dans le code mus
  def draw_notes(notes)
    \# ... traitement ...
    return notes.map { |n| "\#{n}8" }.join(' ')
  end

end #/ module ScoreImage
RUBY

end #/class MusCode
end #/module ScoreBuilder
