#
# Classe qui permet d’analyse le dossier dans lequel la commande
# a été jouée.
# 
# Au mieux, on cherche un fichier score_builder.yaml
# 
# Si un fichier PDF a été trouvé, on suppose que c’est la partition
# originale. On propose d’en extraire les pages
# 
# 
module ScoreBuilder
class FolderAnalyzer

  attr_reader :path

  # Instanciation avec le dossier courant (dans lequel a été jouée
  # la commande, ou transmis en argument)
  def initialize(path)
    @path = path
  end

  # @return true si le dossier dans lequel est joué la commande est
  # valide, c’est-à-dire s’il :
  # - contient un fichier .mus
  # - définit une partition originale
  # - produit les svg d’après le code
  # 
  def valid?
    # Analyse du dossier
    data = analyze

    mus_file_path = data[:mus_file] && File.join(data[:folder],data[:mus_file])
    
    err_msg =
      if mus_file_path.nil?
        "Fichier .mus indéfini."
      elsif not(File.exist?(mus_file_path))
        "Fichier .mus inexistant."
      elsif File.extname(mus_file_path) != '.mus'
        "Fichier .mus avec mauvaise extension."
      elsif data[:original_score_folder].nil?
        "Dossier de la partition originale inexistant."
      elsif data[:svg_images].nil?
        "Images SVG non définies."        
      elsif data[:svg_images].empty?
        "Aucune image SVG (il devrait y en avoir au moins 1)."
      else
        nil
      end

    puts err_msg.rouge unless err_msg.nil?
      
    return err_msg.nil?
  end

  # = main =
  # = entry =
  # @api
  # 
  # Pour demander l’analyse du dossier courant
  # 
  # @return [Hash] Table de tous les éléments récoltés
  # 
  def analyze
    data =
      if File.exist?(data_file_path)
        YAML.safe_load(IO.read(data_file_path),**YAML_OPTIONS)
      else
        {
          folder:                 path,
          mus_file:               search_for_mus_file,
          original_pdf_score:     search_for_original_pdf_score,
          original_score_folder:  nil,
          original_score_pages:   nil,
          svg_folder:             nil,
          svg_images:             nil,
        }
      end

    data[:mus_file]               ||= search_for_mus_file
    data[:original_pdf_score]     ||= search_for_original_pdf_score
    data[:original_score_folder]  ||= File.basename(original_score_folder)

    # Si le dossier de la partition originale n’existe pas (celui qui
    # devrait contenir les pages) et qu’un fichier PDF de la 
    # partition original existe, alors on extrait en JPEG les pages
    # de la partition.
    # 
    if  not( File.exist?(original_score_folder) )
      if data[:original_pdf_score] && File.exist?(data[:original_pdf_score])
        extract_from_pdf(data[:original_pdf_score])
      end
    end

    # On fait toujours la liste des images des pages du score
    # original
    if File.exist?(original_score_folder)
      # Extraire les images du score original s’il le faut
      if Dir["#{original_score_folder}/*"].count == 0
        extract_from_pdf(data[:original_pdf_score])
      end
      data.merge!(original_score_pages: get_original_score_pages)
    end
    
    if data[:mus_file]

      affixe = File.basename(data[:mus_file], File.extname(data[:mus_file]))
      svg_folder = File.join(path, affixe)
      data.merge!(svg_folder: svg_folder)

      # S’il le faut, on exécute le code pour produire la ou les
      # images de la partition
      data.merge!(svg_images: get_svg_images_from(svg_folder))

      if not(File.exist?(svg_folder)) || data[:svg_images].empty?
        MusCode.execute_mus_code_from_file(File.join(path, data[:mus_file]))
        data.merge!(svg_images: get_svg_images_from(svg_folder))
      end

      # puts "data = #{data}"

      # On enregistre les données dans un fichier YAML
      IO.write(data_file_path, data.to_yaml)

    end # /s’il y a un file .mus



    return data
  end


  # Chercher le fichier .mus
  # 
  def search_for_mus_file
    candidats = Dir["#{path}/*.mus"]
    if candidats.count == 1
      return File.basename(candidats[0])
    elsif candidats.count == 0
      if Q.yes?("Aucun fichier .mus n’a été trouvé… Dois-je l’initier ?".jaune)
        IO.write(File.join(path,'build_code.mus'), FIRST_CODE)
        return 'build_code.mus'
      else
        return nil
      end
    else
      # S’il existe plusieurs candidats, on cherche celui qui 
      # pourrait avoir un dossier de même nom, contenant les fichiers
      # SVG. Ici, on prend le premier.
      candidats.each do |pth|
        affixe = File.basename(pth, File.extname(pth))
        dossier_svg = File.join(path, affixe)
        if File.exist?(dossier_svg) && File.directory?(dossier_svg)
          return File.basename(pth)
        end
      end
      choices = candidats.map do |pth|
        {name: File.basename(pth), value: pth}
      end
      Q.select("Quel fichier de code choisir ?".jaune, choices, **{per_page:choices.count, cycle:true, filter:true})
    end
  end

  # Cherche le fichier PDF de la partition originale
  def search_for_original_pdf_score
    candidats = Dir["#{path}/*.pdf"]
    case candidats.count
    when 0 then return nil
    when 1 then return candidats[0]
    else
      choices = candidats.map do |pth|
        {name: File.basename, value: pth}
      end
      Q.select("Quel est le fichier de la partition originale ?".jaune, choices, **{per_page:choices.count, cycle:true, filter:true})
    end
  end

  # Retourne la liste des pages du score original
  # 
  def get_original_score_pages
    Dir["#{original_score_folder}/*.jpg"].map { |pth| File.join('original_score',File.basename(pth)) }
  end

  # Retourne la liste des images SVG de la partition
  # 
  def get_svg_images_from(dossier)
    return [] if not(File.exist?(dossier))
    Dir["#{dossier}/*.svg"].map { |pth| File.basename(pth) }  
  end

  # Extraire des images JPEG du score original
  def extract_from_pdf(pdf_path)
    cmd = 'magick "%s" -density 300 "%s/page.jpg"' % [pdf_path, original_score_folder]
    result = `#{cmd} 2>&1`
  end

  def original_score_folder
    @original_score_folder ||= File.join(path, 'original_score').freeze.tap { |d| FileUtils.mkdir_p(d) }
  end

  def data_file_path
    @data_file_path ||= File.join(path,'score_builder.yaml').freeze
  end

FIRST_CODE = <<~MUS
--piano
--barres
--tune Eb
--time 3/4

-> partition
c8 d ees f g ees :||
c2.

MUS
end #/class FolderAnalyzer
end #/module ScoreBuilder
