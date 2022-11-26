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
    # Rapatriement des images et modification des adresses
    # 
    images_folder = mkdir(File.join(analyse.folder_export,'images'))
    hcode = hcode.gsub(/<img(.*?)src=\"(.+?)\"/) do
      ent = $1.freeze
      src = $2.freeze
      nom = File.basename(src)
      dst = File.join(images_folder, nom)
      File.exist?(dst) || FileUtils.cp(src, dst)
       # remplacement
       "<img#{ent}src=\"images/#{nom}\""
    end

    #
    # Fontes
    #
    fonts_folder = mkdir(File.join(analyse.folder_export,'fonts'))
    Dir["#{APP_FOLDER}/assets/fonts/*.otf"].each do |src|
      font_name = File.basename(src)
      dst = File.join(fonts_folder, font_name)
      FileUtils.cp(src, dst)
    end

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

  def styles_css
    ['AMark','AObjet','Forme','main','Print'].map do |affixe|
      css_path = File.join(APP_FOLDER,'css',"#{affixe}.css")
      File.read(css_path).force_encoding('utf-8')
    end.join("\n")
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
          src: url("fonts/PhilNote2-Regular.otf");
        }
        @font-face {
          font-family:  PhilNote;
          src: url("/fonts/PhilNote2-Bold.otf");
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
end #/<< self class Analyse
end #/class Analyse
end #/module ScoreAnalyse
