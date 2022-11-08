# encoding: UTF-8
=begin

  Module devant permettre d'exporter l'analyse dans la meilleure
  résolution possible (suivant la taille de l'image du système
  initial)

=end
require 'rmagick'

require_relative 'OutputSystem'


module ScoreAnalyse
class Analyse

  ##
  # = main =
  #
  # @param params {Hash}
  #   'path'      Chemin d'accès à l'analyse
  #   'systems'   Définition des systèmes à produire
  #   'one_image_per_system'  {Boolen} Si true, on doit produire une
  #               image par système.
  # 
  def produce_image_analyse(params)
    result = {ok: true, error: nil} # pour le retour à js

    options = {
      format: 'png'
    }

    #
    # Systems à produire
    # 
    all_systems, only_systems = required_systems(params)    

    #
    # On passe en revue tous les systèmes retenus
    #
    params['systemsData'].select do |isystem, dsystem|
      all_systems || only_systems.include?(isystem.to_i)
    end.each do |isystem, dsystem|
      systeme = OutputSystem.new(self, dsystem)
      systeme.export_image(options)
    end

    result[:ok] = true
  rescue Exception => e
    result[:ok]     = false
    result[:error]  = e.message
    puts e.message.rouge
    puts e.backtrace.join("\n").rouge
  ensure
    WAA.send({class:'Analyse',method:'onExportedImage',data:result})
  end

  ## 
  # Pour déterminer les systèmes à prendre en compte
  # 
  # @return [all_systemes, only_systems]
  #         Si all_systemes est true, on traite tous les systèmes,
  #         sinon on ne fait que les systèmes de only_systems
  # 
  def required_systems(params)
    req_systems = params['systems']  
    only_systems = nil
    all_systems = req_systems.nil? || req_systems.empty?
    all_systems || begin
      only_systems = []
      req_systems.split(/[, ]/).each do |seg|
        seg = seg.strip
        if seg.numeric?
          only_systems << seg.to_i
        elsif seg.match?('-')
          first, last = seg.split('-').map{|i|i.to_i}
          only_systems += (first..last).to_a
        end
      end
      puts "Seulement les systèmes : #{only_systems}"
    end
    return [all_systems, only_systems]
  end

end #/class Analyse
end #/module ScoreAnalyse
