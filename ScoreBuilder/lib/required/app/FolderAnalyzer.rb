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
    @data = analyze
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
      # Quand un fichier de données existe déjà (c’est le fichier
      # score_builder.yaml qu’on trouve à la racine du dossier)
      # 
      data = YAML.safe_load(IO.read(data_file_path),**YAML_OPTIONS)
      data[:mus_file] ||= search_for_mus_file
      # Si les images de la partition originale n’existent plus, 
      # on va les rechercher.
      premiere_image = File.join(path,data[:original_score_pages][0])
      unless File.exist?(premiere_image)
        puts <<~TEXT.orange
        La première image définie(*) est introuvable. Je vais les
        chercher dans le dossier où elles peuvent se trouver.
        (*) #{File.basename(premiere_image)}
        TEXT
        data.delete(:original_score_pages)
      end
    else
      #
      # Fichier de données ScoreBuilder inexistant (par exemple
      # lors du premier lancement de ScoreBuilder dans le dossier)
      data = {
        folder:                 path,
        mus_file:               search_for_mus_file,
        original_pdf_score:     search_for_original_pdf_score,
        original_score_folder:  nil,
        original_score_pages:   [],
        svg_folder:             nil,
        svg_images:             nil,
      }
    end

    data[:original_pdf_score]     ||= search_for_original_pdf_score
    data[:original_score_folder]  ||= File.basename(original_score_folder)
    data[:original_score_pages]   ||= []

    original_score_existe = data[:original_pdf_score] && File.exist?(data[:original_pdf_score])
    dossier_scores_jpeg_existe = File.exist?(original_score_folder)
    pas_de_dossier_scores_jpeg = not(dossier_scores_jpeg_existe)
    pas_de_scores_jpeg = dossier_scores_jpeg_existe && Dir["#{original_score_folder}/*"].count == 0

    # Normalement, après l’extraction des pages JPEG, la score PDF 
    # original est mis dans le dossier backup. On considère donc que
    # si le score original est encore trouvé dans le dossier, et qu’il
    # n’y a plus de scores JPEG, c’est qu’il faut procéder à nouveau
    # à l’extraction.
    if original_score_existe && pas_de_scores_jpeg
      extract_from_pdf(data[:original_pdf_score])
    end

    if dossier_scores_jpeg_existe && data[:original_score_pages].empty?
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
        mIn   = "Production des images SVG.".freeze
        mOut  = "🍺 Images SVG produites avec succès".freeze
        mErr  = "🧨 Problème à la production des images".freeze
        do_with_message(mIn, mOut, mErr) do
          muscode = MusCode.new(File.join(path, data[:mus_file]))
          report = muscode.produce_svg
          raise report[:error] unless report[:ok]
        end
        data.merge!(svg_images: get_svg_images_from(svg_folder))
      end

      # puts "data = #{data}"

    end # /s’il y a un file .mus


    # On enregistre les données dans un fichier YAML
    data.merge!(updated_at: Time.now)
    IO.write(data_file_path, data.to_yaml)


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
    Dir["#{original_score_folder}/*.jpg"].map do |pth| 
      File.join('original_score',File.basename(pth))
    end.sort
  end

  # Retourne la liste des images SVG de la partition
  # 
  def get_svg_images_from(dossier)
    ScoreBuilder::MusCode.get_and_sort_svg_in(dossier)
  end

  # Extraire des images JPEG du score original
  # (en s’assurant qu’elles ne dépassent pas une certaine taille)
  def extract_from_pdf(pdf_path)
    ok = true
    puts "J’extrais les pages du fichier PDF #{File.basename(pdf_path).inspect}…".jaune
    # Avant de redimensionner si + de 3000px de large
    cmd = 'magick -density 300 "%s" "%s/page.jpg"' % [pdf_path, original_score_folder]
    # cmd = 'magick -density 300 "%s" -resize \'1500x3000>\' "%s/page.jpg"' % [pdf_path, original_score_folder]
    result = `#{cmd} 2>&1`
    puts "magick result: #{result}".rouge unless result.empty?
    # Si l’extraction a pu se faire avec succès, on déplace le
    # fichier PDF de la partition originale vers le dossier backup
    ok = Dir["#{original_score_folder}/*.jpg"].count > 0
    if ok
      # Déplacement du score original
      dst_path = File.join(backups_folder, File.basename(pdf_path))
      FileUtils.mv(pdf_path, dst_path)
      if File.exist?(dst_path)
        puts "\n🍺 Partition originale déplacée vers le fichier des backups.".vert
      end
      # Redimensionner les images si elles sont trop grandes
      cmd = 'magick "%{path}" -resize \'1500x3000>\' "%{path}"'.freeze
      Dir["#{original_score_folder}/page*.jpg"].each do |pth|
        cmdf = cmd % {path: pth}
        res = `#{cmdf} 2>&1`
        puts "res: #{res}".rouge unless res.empty?          
      end
      puts "🍺 Images redimensionnées à la bonne taille.".vert
      # Renommage des fichiers (car il commence à 0)
      @has_been_renumbered = false
      Dir["#{original_score_folder}/page-*.jpg"].sort_by do |pth|
        File.basename(pth)
      end.reverse.each do |pth|
        dossier = File.dirname(pth)
        fname   = File.basename(pth)
        fname = fname.sub(/([0-9]+)/) { ($1.to_i + 1).to_s }
        dst   = File.join(dossier,fname)
        FileUtils.mv(pth, dst)
        @has_been_renumbered = true
      end
      if @has_been_renumbered
        puts "🍺 Images renumérotées à partir de 1.".vert
      end
    end
    if ok
      puts "🍺 Pages JPEG produites avec succès…".vert
      puts <<~TEXT.jaune
      Penser à numéroter les mesures à l’aide de Score Numbering en 
      ouvrant un Terminal dans le dossier ./#{File.basename(original_score_folder)} et
      en jouant la commande ’score-number’.
      TEXT
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
  def do_with_message(start_msg, end_msg, err_msg = nil, &block)
    start_msg = "#{start_msg} Merci de patienter…"
    STDOUT.write start_msg.jaune
    begin
      yield
    rescue Exception => e
      puts "\r#{(err_msg||'ERREUR').ljust(start_msg.length + 10)}".rouge
      puts e.message.rouge
    else
      puts "\r#{end_msg.ljust(start_msg.length + 10)}".vert
    end
  end

FIRST_CODE = <<~MUS
--piano
--barres
--tune Eb
--time 3/4

-> score
c8 d ees f g ees :||
c2.

MUS
end #/class FolderAnalyzer
end #/module ScoreBuilder
