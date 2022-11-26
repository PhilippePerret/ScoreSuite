module ScoreAnalyse
class Analyse
class << self
  
  def proceed_export_to_html(analyse, data)
    retour = {ok: true, error: nil}
    puts "code_html : #{data['code_html']}"

    # 
    # Le code HTML initial
    # 
    hcode = data['code_html']

    # 
    # Rapatriement des images
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

    full_code = head + hcode + '</body></html>'

    html_path = File.join(analyse.folder_export, "analyse.html")
    retour.merge!(path: html_path)

    File.write(html_path, full_code)

    WAA.send(
      class:  'Analyse', 
      method: 'onExportedCurrentToHtml',
      data: retour
    )

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
        #{styles_css}
      </style>
    </head>
    <body>
      
    HTML
  end
end #/<< self class Analyse
end #/class Analyse
end #/module ScoreAnalyse
