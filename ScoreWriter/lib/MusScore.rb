# encoding: UTF-8
=begin

  ScoreWriter::MusScore
  ---------------------
  Gestion de la partition courante

=end
module ScoreWriter
class MusScore

  attr_reader :affixe_path

  def initialize(affixe_path)
    @affixe_path = mkdir(affixe_path)
  end

  ##
  # @return Le Hash de donnée pour le côté client
  # 
  def data_for_client
    {
      code:   code,
      images: images,
      affixe: affixe_path,
    }
  end

  def new_image?
    not(File.exist?(file_mus_path))
  end

  ##
  # @return {Array} les lignes du fichier .mus s'il existe
  # (il n'existe pas lorsque c'est une nouvelle image)
  def code
    new_image? ? ["-> #{affixe}"] : get_code_of(file_mus_path)
  end

  ##
  # Pour écrire le code +muscode+ dans le fichier
  # .mus de la partition
  def write_code(muscode)
    File.delete(file_mus_path) if File.exist?(file_mus_path)
    File.open(file_mus_path,'wb') do |f|
      f.write muscode
    end
  end

  ##
  # @return la liste Array des images SVG du
  # dossier 
  # 
  def images
    Dir["#{affixe_path}/#{affixe}*.svg"]
  end

  def erase_images
    images.each {|i| File.delete(i) }
  end

  ##
  # Méthode qui va scoriser (score-image) le code
  # .mus pour produire la ou les images de la partition
  def produce_images
    File.delete(final_image_path) if File.exist?(final_image_path)
    puts "Image à produire : #{final_image_path}"
    cmd = "#{SCORE_SUITE_FOLDER}/ScoreImage/score_image.rb"
    cmd = "cd \"#{folder}\" && #{cmd} ./#{affixe}.mus" # TODO stats ?
    res = `#{cmd} 2>&1`
    if $?.success? # && res == ''
      puts "Image(s) produite(s) avec succès.\n(#{final_image_path.inspect})".vert
    else
      if $?.exitstatus == 101
        ScoreWriter::App.errors << "Aucune image n'a été produite"
      else
        puts "Retour de fabrication : #{res.inspect}".rouge
        ScoreWriter::App.errors << "Erreur retournée par la commande de fabrication (voir dans la fenêtre de Terminal)"
      end
    end
  end


  def config
    @config ||= begin
      if File.exist?(config_path)
        YAML.load_file(config_path, aliases:true)
      else {} end
    end
  end
  def config=(value)
    @config = value
    save_config
  end
  def save_config
    File.open(config_path,'wb'){|f| f.write config.to_yaml}
  end
  def config_path
    @config_path ||= "#{affixe_path}/#{affixe}.config"
  end

  def file_mus_path
    @file_mus_path ||= "#{affixe_path}.mus"
  end

  def final_image_path
    @final_image_path ||= "#{images_folder}.svg"
  end

  def images_folder
    @images_folder ||= File.join(affixe_path, affixe)
  end

  def affixe
    @affixe ||= File.basename(affixe_path)
  end

  def folder
    @folder ||= File.dirname(affixe_path)
  end


  private

    ##
    # @return le code .mus du fichier +fpath+ dont l'existence
    # a été vérifiée
    # 
    def get_code_of(fpath)
      note_tune_fixed = false
      txt = File.read(fpath)
      txt = txt.split(/\r?\n/).collect{|s|s.strip}
      # 
      # On doit retirer l'entête '\fixed ...' du code
      # (plus tard il faudra voir si c'est vraiment nécessaire
      #  et s'il ne vaut pas mieux le traiter côté client)
      txt = txt.map do |seg|
        if seg.start_with?('-')
          seg
        elsif seg.start_with?('\\fixed')
          note_tune_fixed = true
          offsetcroc = seg.index('{') + 2
          seg = seg.strip[offsetcroc..-2].strip
        else
          seg
        end
      end
      txt.unshift("--note_tune_fixed") if note_tune_fixed

      return txt # {Array}
    end #/get_code_of

end #/class MusScore
end #/module ScoreWriter
