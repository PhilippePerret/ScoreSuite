#
# Classe qui permet d’analyser le dossier courant de l’application
# (qui peut être déterminé de différentes manières)
# 
# Au mieux, on cherche un fichier score_builder.yaml
# 
# Si un fichier PDF a été trouvé, on suppose que c’est la partition
# originale. On propose d’en extraire les pages (mais seulement en
# mode interactif ScoreBuilder.interactive_mode?)
# 
# 
module ScoreBuilder
class FolderAnalyzer

  attr_reader :path
  attr_reader :error
  attr_reader :data # données de l’analyse

  # Instanciation avec le dossier courant (dans lequel a été jouée
  # la commande, ou transmis en argument)
  def initialize(path)
    @path = path
  end

  # @return true si le dossier dans lequel est joué la commande est
  # valide, c’est-à-dire s’il :
  # - contient un fichier .mus
  # - produit les svg d’après le code (avec ScoreImage)
  # Optionnel :
  # - définit une partition originale
  # 
  def valid?
    # Analyse du dossier
    data = analyze



    mus_file_path = data[:mus_file] && File.join(data[:folder],data[:mus_file])
    

    @error =
      if mus_file_path.nil?
        "Fichier .mus indéfini."
      elsif not(File.exist?(mus_file_path))
        "Fichier .mus inexistant."
      elsif File.extname(mus_file_path) != '.mus'
        "Fichier .mus avec mauvaise extension."
      elsif data[:svg_images].nil?
        "Images SVG non définies."        
      elsif data[:svg_images].empty?
        "Aucune image SVG (il devrait y en avoir au moins 1)."
      else
        nil
      end
      
    return error.nil?
  end

  def original_score?
    data[:original_score_pages] && !data[:original_score_pages].empty?
  end

  # = main =
  # 
  # Pour procéder à l’analyse du dossier courant
  # 
  # @return [Hash] Table de tous les éléments récoltés
  # 
  def analyze
    
    if File.exist?(data_file_path)
      # 
      # Quand un fichier de données existe déjà
      # 
      data = YAML.safe_load(IO.read(data_file_path),**YAML_OPTIONS)
      data[:mus_file] ||= search_for_mus_file
    else
      #
      # Fichier de données ScoreBuilder inexistant (par exemple
      # lors du premier lancement de ScoreBuilder dans le dossier)
      data = {
        folder:                 path,
        mus_file:               search_for_mus_file,
        original_pdf_score:     search_for_original_pdf_score,
        original_score_folder:  nil,
        original_score_pages:   nil,
        svg_folder:             nil,
        svg_images:             nil,
      }
    end

    data[:original_pdf_score]     ||= search_for_original_pdf_score
    data[:original_score_folder]  ||= File.basename(original_score_folder)

    if data[:original_pdf_score] && File.exist?(data[:original_pdf_score])

      # Si le dossier de la partition originale n’existe pas (celui qui
      # devrait contenir les pages) et qu’un fichier PDF de la 
      # partition original existe, alors on extrait en JPEG les pages
      # de la partition.
      # 
      # On fait toujours la liste des images des pages du score
      # original (s’il existe)
      if File.exist?(original_score_folder)
        # Extraire les images du score original s’il le faut
        if Dir["#{original_score_folder}/*"].count == 0
          extract_from_pdf(data[:original_pdf_score])
        end
        data.merge!(original_score_pages: get_original_score_pages)
      else
        extract_from_pdf(data[:original_pdf_score])
      end

    elsif data[:original_pdf_score] && File.exist?(original_score_folder)

      # Le fichier du score original n’existe pas, mais le dossier 
      # pour mettre ses pages oui. C’est donc que la partition origi-
      # nale a déjà été traitée et mise dans le backup/archive
      # => Rien à faire et rien à signaler.

    else

      # En cas d’inexistence ou d’indéfinition de la partition
      # originale. Ce qui est toujours possible et ne pose aucun 
      # problème. Mais on exposera quand même la chose.

    end

    if data[:mus_file]

      affixe = File.basename(data[:mus_file], File.extname(data[:mus_file]))
      svg_folder = File.join(path, affixe)
      data.merge!(svg_folder: svg_folder)

      # S’il le faut, on exécute le code pour produire la ou les
      # images de la partition
      data.merge!(svg_images: get_svg_images_from(svg_folder))

      if not(File.exist?(svg_folder)) || data[:svg_images].empty?
        mIn   = "Production des images SVG."
        mOut  = "🍺 Images SVG produites avec succès"
        do_with_message(mIn, mOut) do
          muscode = MusCode.new(File.join(path, data[:mus_file]))
          muscode.produce_svg
        end
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
      if ScoreBuilder.interactive_mode?
        if Q.yes?("Aucun fichier .mus n’a été trouvé… Dois-je l’initier ?".jaune)
          IO.write(File.join(path,'build_code.mus'), FIRST_CODE)
          return 'build_code.mus'
        end
      end
      return nil
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
  # 
  def extract_from_pdf(pdf_path)
    ok = true
    msg_start = "J’extrais les pages du fichier PDF #{File.basename(pdf_path).inspect}…"
    msg_end   = "🍺 Pages JPEG produites avec succès…"
    do_with_message(msg_start, msg_end) do
      cmd = 'magick "%s" -density 300 "%s/page.jpg"' % [pdf_path, original_score_folder]
      result = `#{cmd} 2>&1`
      # Si l’extraction a pu se faire avec succès, on déplace le
      # fichier PDF de la partition originale vers le dossier backup
      ok = Dir["#{original_score_folder}/*.jpg"].count > 0
      if ok
        # Déplacement du score original
        dst_path = File.join(backups_folder, File.basename(pdf_path))
        FileUtils.mv(pdf_path, dst_path)
        # Renommage des fichiers (car il commence à 0)
        Dir["#{original_score_folder}/page-*.jpg"].sort_by do |pth|
          File.basename(pth)
        end.reverse.each do |pth|
          dossier = File.dirname(pth)
          fname   = File.basename(pth)
          fname = fname.sub(/([0-9]+)/) { ($1.to_i + 1).to_s }
          FileUtils.mv(pth, File.join(dossier,fname))
        end
      end
    end #/do with message
    if ok
      puts "🍺 Partition originale déplacée vers le fichier des backups.".vert
      puts "Pensez à numéroter les mesures à l’aide de ’score-numbering’.".jaune
    else
      puts "Un problème est survenu, je ne trouve aucune page…".rouge
    end      
  end

  def backups_folder
    @backups_folder ||= File.join(path,'xbackups').freeze.tap{|d|FileUtils.mkdir_p(d)}
  end

  def original_score_folder
    @original_score_folder ||= File.join(path, 'original_score').freeze.tap { |d| FileUtils.mkdir_p(d) }
  end

  def data_file_path
    @data_file_path ||= File.join(path,'score_builder.yaml').freeze
  end

  # Pour exécuter un code assez long en affichant un premier message
  # (en jaune), en exécutant le code transmis par bloc puis en 
  # concluant avec un message vert qui efface le premier message
  # 
  # @usage
  # 
  #   msgStart = "Je commence"
  #   msgEnd   = "Fini !"
  #   do_with_message(msgStart, msgEnd) do
  #     ... ici le code à exécuter ...
  #     sleep 4
  #   end
  # 
  def do_with_message(start_msg, end_msg, &block)
    start_msg = "#{start_msg} Merci de patienter…"
    STDOUT.write start_msg.jaune
    yield
    puts "\r#{end_msg.ljust(start_msg.length + 10)}".vert
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
