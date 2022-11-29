=begin

Pour convertir une font en un fichier .json dont le code pourra
être chargé :
  https://github.com/gero3/facetype.js
  https://gero3.github.io/facetype.js/

Initialement, les fonts étaient placées dans un dossier 'fonts' et
chargées dans le code par :
@font-face {
  font-family:  PhilNote;
  src: url("fonts/PhilNote2-Regular.otf");
}
@font-face {
  font-family:  PhilNote;
  src: url("/fonts/PhilNote2-Bold.otf");
  font-weight: bold;
}

=end
module ScoreAnalyse
class Analyse
class << self
  
  def proceed_export_to_html(analyse, data)
    retour = {ok: true, error: nil}
    # puts "code_html : #{data['code_html']}"

    # 
    # Le code HTML initial
    # 
    hcode = data['code_html']

    #
    # Traitement des images
    # (pour qu'elles soient moins gourmandes et les mettre dans un
    #  dossier dédié avec le code)
    # 
    hcode = traite_images_in(analyse, hcode)

    # #
    # # Fontes
    # #
    # fonts_folder = mkdir(File.join(analyse.folder_export,'fonts'))
    # Dir["#{APP_FOLDER}/assets/fonts/*.otf"].each do |src|
    #   font_name = File.basename(src)
    #   dst = File.join(fonts_folder, font_name)
    #   FileUtils.cp(src, dst)
    # end

    full_code = head + page_titre(analyse) + hcode + '</body></html>'

    html_path = File.join(analyse.folder_export, "analyse.html")
    retour.merge!(path: html_path)

    File.write(html_path, full_code)

    retour[:ok] = File.exist?(html_path)

    #
    # Ouvrir le dossier du fichier
    #
    `open -a Finder "#{File.dirname(html_path)}"`

    WAA.send(
      class:  'Analyse', 
      method: 'onExportedCurrentToHtml',
      data: retour
    )

  end

  ##
  # Rapatriement des images et modification des adresses
  # 
  # Si on veut EMBEDDER LES IMAGES, utiliser :
  #   > base64 -i from.jpg -o to.txt
  # … pour obtenir le code puis remplacer l'image dans le code par :
  #   <img src="data:image/png;base64,<<ligne rassemblées>>">
  #   Note : remplacer 'image/png' par le format de l'image
  # 
  # 1. resizer les images pour qu'elles soient de la taille utilisée
  #    dans l'analyse, pas plus grandes.
  # 2. Essayer de les alléger, peut-être pour en faire des webp
  # 
  def traite_images_in(analyse, hcode)

    #
    # Remplacement du code HTML et relève des images (toutes les
    # images, pas seulement les systèmes)
    # 
    hcode = hcode.gsub(/<img(.*?)src=\"(.+?)\"(.*?)>/) do
      ent = $1.freeze
      src = $2.freeze
      fin = $3.freeze
      # images << src
      nom = File.basename(src)
      ext = File.extname(src)
      if nom.match?(/^system-/)
      
        # 
        # Traitement des systèmes -> webp
        # 
        traite_image_system(analyse, src)
        "<img#{ent}src=\"data:image/webp;base64,#{code_base64(src)}\"#{fin}>"

      elsif ext == '.svg'
      
        #
        # Traitement des images SVG
        #
        code_svg_in(src)

      else
      
        #
        # Traitement d'une image "normale"
        #
      
        "<img#{ent}src=\"data:image/webp;base64,#{code_base64(src)}\"#{fin}>"
      
      end
    end

  end


  ##
  # @return le code BASE64 du fichier de chemin d'accès +src+ en
  # le transformant si nécessaire en fichier .webp (plus léger)
  # 
  def code_base64(src)
    dos = File.dirname(src)
    ext = File.extname(src)
    nom = File.basename(src)
    cbase64 = nil
    Dir.chdir(dos) do
      # 
      # Fabrication du fichier webp si nécessaire
      # 
      `convert "#{nom}" "#{nom}.webp"` unless File.exist?("#{nom}.webp")
      # 
      # Transformation en code 64
      # 
      cbase64 = `base64 -i "#{nom}.webp"`
    end

    return cbase64.gsub(/\n/,'')
  end

  ##
  # @return le code SVG (<svg ... </svg>) du fichier +src+
  # 
  def code_svg_in(src)
    c = File.read(src)
    idx = c.index('<svg')
    return c[idx..-1].strip
  end

  #
  # Traitement de l'image système
  # 
  # Reçoit le path absolu de l'image et retourne son code base64
  # pour être embeddé dans le code
  # - redimensionne l'image
  # - la reconvertit en webp
  # - produit son code base64
  # 
  def traite_image_system(analyse, src)

    # 
    # Taille de l'image dans l'application
    # 
    @image_width ||= analyse.preferences['systeme_width']

    dos     = File.dirname(src)
    nom     = File.basename(src)
    nom_web = "#{nom}.webp"

    Dir.chdir(dos) do
      # 
      # Production de l'image .WEBP, à la bonne taille sauf
      # si elle existe
      # 
      unless File.exist?(nom_web)
        `convert -resize #{@image_width}x "#{nom}" #{nom_web}`
      end
    end

  end


  # @return la page de titre pour l'analyse
  def page_titre(analyse)
    <<~HTML
    <div id="page_titre">
      <div class="mot">Analyse de</div>
      <div id="titre_oeuvre">#{analyse.infos['piece_title']}</div>
      <div class="mot">de</div>
      <div id="composer_oeuvre">#{analyse.infos['composer']}</div>
      <div id="titre_analyse">#{analyse.infos['analyse_title']}</div>
      <div class="mot">par</div>
      <div id="analyst">#{analyse.infos['analyst']}</div>
    </div>
    HTML
  end

  # Retourne tous les code CSS
  def styles_css
    ['AMark','AObjet','Forme','main','Print'].map do |affixe|
      css_path = File.join(APP_FOLDER,'css',"#{affixe}.css")
      File.read(css_path).force_encoding('utf-8')
    end.join("\n")
  end


  def font_source(url)
    if true # embeddé en dur
      font_path = File.join(APP_FOLDER,'assets', url)
      ba64_path = "#{font_path}.b64.txt"
      `base64 "#{font_path}" > "#{ba64_path}"` unless File.exist?(ba64_path)
      b64 = File.open(ba64_path,'rb').read.gsub(/\s\n/,'').strip
      "data:font/otf;base64,#{b64}"
    else
      url
    end
  end

  def head
    <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Analyse </title>
      <style type="text/css">
        @font-face {
          font-family:  PhilNote;
          src: url(#{font_source("fonts/PhilNote2-Regular.otf")});
        }
        @font-face {
          font-family:  PhilNote;
          src: url(#{font_source("/fonts/PhilNote2-Bold.otf")});
          font-weight: bold;
        }
        .philnote {
          font-family: PhilNote;
          font-size: 32px;  
        }

        div#page_titre {
          padding:4em;
          margin-bottom:4em;
          font-size:32pt;
        }
        div#page_titre > div {
          text-align: center;
          margin-top:1em;
          margin-bottom:1em;
        }
        div#page_titre div.mot {font-size:0.75em}
        section#content {
          position:relative;
        }
        #{styles_css}
      </style>
    </head>
    <body>
      
    HTML
  end

  # Rien de ci-dessous ne fonctionne…
  # def code_fonte(filename)
  #   # require 'charlock_holmes/string'
  #   font_path = File.join(APP_FOLDER,'assets','fonts',filename)
  #   # dencode = CharlockHolmes::EncodingDetector.detect(File.read(font_path))
  #   return File.binread(font_path).encode('utf-8')
  #   # contents = File.read(font_path)
  #   # contents.detect_encoding!
  #   # return contents.to_s.split("\n").join('')

  #   # puts "dencode : #{dencode.inspect}"
  #   # c = nil
  #   # File.open(font_path,"r:#{dencode[:encoding]}:UTF-8") do |f|
  #   #   c = f.read
  #   # end
  #   # # c = File.binread(font_path)
  #   # return c.split("\n").join(' ')
  # end

  # # Je ne sais pas utiliser ça
  # def code_json_for_fonts
  #   Dir["#{APP_FOLDER}/assets/fonts/*.js"].map do |src|
  #     File.read(src)
  #   end.join("\n")
  # end

end #/<< self class Analyse
end #/class Analyse
end #/module ScoreAnalyse
