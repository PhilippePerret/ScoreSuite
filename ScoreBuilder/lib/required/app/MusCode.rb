require 'yaml'
module ScoreBuilder
class MusCode
class << self

  def save_and_evaluate(waa_data)
    puts "waa_data = #{waa_data}"
    # Enregistrement du code transmis

    # Évaluation par ScoreImage

    # Retour du résultat
    waa_data.merge!(
      ok:       true, 
      ope:      "Code enregistré et évalué.",
      folder:   main_folder,
      mus_file: mus_file_path,
      affixe:   mus_file_affixe,
      svgs:     current_score_svgs,
      )
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
end #/class App
end #/module ScoreBuilder
