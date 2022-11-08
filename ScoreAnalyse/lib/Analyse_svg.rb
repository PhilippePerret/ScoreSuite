# encoding: UTF-8
=begin

  Module de production de l'image SVG de l'analyse (ou d'une portion
  d'analyse) à l'aide de la gem VICTOR

  OBSOLÈTE

=end
module ScoreAnalyse
require 'victor'

class Analyse

  ##
  # = main =
  # 
  # Production de l'image SVG de l'analyse, avec les données +data+
  # 
  # @param params {Hash}
  #   'path'      Chemin d'accès à l'analyse
  #   'systems'   Définition des systèmes à produire
  #   'one_image_per_system'  {Boolen} Si true, on doit produire une
  #               image par système.
  # 
  def produce_svg_image(params)
    result = {ok: true, error: nil} # pour le retour à js

    result[:ok]     = false
    result[:error]  = "Je ne sais pas encore exporter l'analyse en SVG."
    return WAA.send({class:'Analyse',method:'onExportedToSvg',data:result})

    puts "Je dois apprendre à produire l'image SVG de l'analyse avec :".jaune
    puts params.inspect.jaune

    # Pour essai
    isystem = 1
    produce_system(isystem, params['systemsData'][isystem.to_s])

    result[:ok] = true
  rescue Exception => e
    result[:ok]     = false
    result[:error]  = e.message
    puts e.message.rouge
    puts e.backtrace.join("\n").rouge
  ensure
    WAA.send({class:'Analyse',method:'onExportedToSvg',data:result})
  end

  ##
  # Pour produire un système
  # 
  def produce_system(isystem, dsystem)
    img_width   = dsystem['width']
    img_height  = dsystem['full_height']

    svg_system_path = File.join(folder_systems, "system-#{isystem}.svg")

    view_box_width  = 100
    view_box_height = 100

    # svg = Victor::SVG.new(width: img_width, height: img_height, style:{background:'white'}) 
    svg = Victor::SVG.new width:'100%', height:'100%', viewBow:"0 0 #{view_box_width} #{view_box_height}"

    svg.build do
      css['.acc'] = {
        font_family: 'PhilNote2',
        font_size:   '32pt',
        padding:     '8px'
      }
      css['.har'] = {
        font_family: 'PhilNote2',
        font_size:   '32pt',
        padding:     '8px'
      }
      css['.deg'] = {
        font_family: 'PhilNote2',
        font_weight: 'bold',
        font_size:   '32pt',
      }



      #
      # Écriture des objets de la partition
      # 
      dsystem['marks'].each do |dmark|
        text dmark['content'], x:dmark['left'] + 8, y:dmark['top'], class:dmark['type']
      end

    end

    #
    # On produit l'image
    # 
    svg_path = File.join(svg_folder, "system-#{isystem}.svg")
    svg.save svg_path

    # 
    # On va ajouter le code de l'image du système
    #
    image_top   = 10
    code_image  = "<image xlink:href=\"systems/system-#{isystem}.jpg\" y=\"#{image_top}\" x=\"0\" width=\"#{img_width}\" height=\"#{dsystem['height']}\" preserveAspectRatio=\"xMinYMin meet\" />"

    # 
    # On insert le code de l'image dans l'image SVG
    # 
    code_svg = File.read(svg_path)
    dec = code_svg.index('<svg')
    dec = code_svg.index('>', dec + 4) + 1
    avant = code_svg[0..dec]
    apres = code_svg[dec..-1]
    code_svg = avant + "\n#{code_image}\n" + apres
    File.open(svg_path,'wb'){|f|f.write code_svg}

    puts "Image produite dans #{svg_path}".vert
  end



  def svg_folder
    @svg_folder ||= mkdir(File.join(path,'svg'))
  end


end #/class Analyse
end #/module ScoreAnalyse
