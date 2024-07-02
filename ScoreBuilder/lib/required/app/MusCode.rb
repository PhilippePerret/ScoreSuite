require 'yaml'
require 'timeout'
module ScoreBuilder
class MusCode
class << self

  def execute_mus_code_from_file(mus_file_path)
    muscode = MusCode.new(mus_file_path)
    muscode.produce_svg
  end

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
      muscode.produce_svg

      # Retour du résultat
      waa_data.merge!(
        ok:         true, 
        ope:        "Code enregistré et évalué.",
        folder:     main_folder,
        affixe:     mus_file_affixe,
        svg_images: current_score_svgs,
        )
    end
    WAA.send(class:"MusCode", method: "onSavedAndEvaluated", data: waa_data)
  end

  # Retourne la liste des images SVG produites (soit une seule,
  # soit plusieurs si la partition est longue)
  def current_score_svgs
    Dir["#{svg_folder}/*.svg"].map { |pth| File.basename(pth) }
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
def produce_svg

  remove_all_svg

  cmd = 'cd "%s";score-image %s -v 2>&1'.freeze % [File.dirname(mus_file),File.basename(mus_file)]
  # puts "Command : #{cmd.inspect}"
  resultat = `#{cmd}`
  
  # On attend que les images ait été produites et rognées
  Timeout.timeout(40) do
    until nombre_current_svg > 0
      sleep 0.5
    end
  end

rescue Timeout::Error => e
  return false # Aucune image produite
else
  return true
end


# === Functional Methods ===


def save(new_code)
  IO.write(mus_file, new_code)
end

def backup
  backup_path = File.join(backup_folder, "#{affixe}-#{Time.now.to_i}.mus")
  FileUtils.mv(mus_file, backup_path)
end


# Destruction de toutes les images SVG
def remove_all_svg
  Dir["#{svg_folder}/*.svg"].each{|pth|File.delete(pth)}
end

# Récupération de toutes les images SVG
# (pour affichage)
def get_all_svg_images
  Dir["#{svg_folder}/*.svg"].map{|pth|File.basename(pth)}
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


end #/class MusCode
end #/module ScoreBuilder
