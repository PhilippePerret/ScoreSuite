# encoding: UTF-8
=begin

  Module permet d'exporter un système (avec ses marques) en image JPEG

=end
require 'rmagick'

require_relative 'OutputSystem_Mark'
Dir["#{__dir__}/OutputSystem/**/*.rb"].each{|m|require(m)}

module ScoreAnalyse
require_relative 'OutputSystem_Constants'
class OutputSystem

  #
  # L'analyse contenant le système
  # 
  attr_reader :analyse

  #
  # Les données initiales du système
  # 
  # Table contenant :top, :left, :marks
  attr_reader :data

  #
  # Options pour l'exportation
  # 
  attr_reader :options


  def initialize(analyse, data)
    @analyse = analyse
    @data = data
  end

  ################# MÉTHODES PUBLIQUES PRINCIPALES #################

  def export_image(options = nil)
    @options = defaultize_options(options)
    File.delete(fin_image_path) if File.exist?(fin_image_path)

    #
    # On étire l'image (qui pour le moment fait la taille du système)
    # pour pouvoir y mettre toutes les marques
    # 
    wrap_operation("Extension de l'image") do
      @image = image.extent(sys_width, real_full_height, 0, -real_top)
    end

    wrap_operation("Construction des marques") do 
      each_mark do |mark|
        mark.build(image)
      end
    end

    #
    # On redimensionne et on ré-échantillonne l'image
    # à 300ppi
    # 
    resize_and_resample

    # Attention : si l'image a été redimensionnée, à partir d'ici,
    # @image n'est plus une Magick::ImageList mais une Magick::Image

    wrap_operation("Écriture de l'image") do
      image.write(fin_image_path)
    end

    #
    # Confirmation de exportation (ou pas…)
    # 
    confirm_export

  end

  ##
  # Redimensionner et resampler l'image à 300ppi
  # 
  # Si l'image est supérieure à une certaine taille on la 
  # redimensionne (pour ne pas obtenir un fichier trop volumineux)
  # 
  # On doit obtenir une image de 3000 pixels en 300ppi
  def resize_and_resample
    if sys_width > SYSTEM_MAX_WIDTH
      wrap_operation("Resizing", " (from #{sys_width}x#{sys_height})", Proc.new{" (to #{image.columns}x#{image.rows})"}) do
        @image = image.resize(3000.0 / sys_width)
      end
    end

    wrap_operation("Resampling (-> 300ppi)") do
      @image = image.resample(300.0)
    end
  end

  ################ MISCELLANOUS ####################

  ##
  # Méthode confirmation de l'export (si tout est OK)
  def confirm_export
    if File.exist?(fin_image_path)
      msg = "Image #{fin_image_name} construite avec succès."
      puts msg.vert
      msg = "#{msg}\nMerci de patienter pour la suite…"
      WAA.notify(msg)
    else
      msg = "Un problème est survenu avec l'image #{fin_image_name}. Elle n'a pas pu être produite." 
      WAA.notify(msg, 'error')
      puts msg.rouge
    end    
  end

  ##
  # Juste pour le suivi en console, pour entourer une opération
  # 
  def wrap_operation(name, add_before = nil, add_after = nil, &block)
    # Message d'opération
    add_before = add_before.call if add_before.is_a?(Proc)
    STDOUT.write "* #{name}#{add_before}".bleu
    # Jouer l'opération
    begin
      yield
    rescue Exception => e
      puts "\nErreur au cours de l'opération #{name.inspect} : #{e.message}".rouge
      raise e
    end
    # Message de fin d'opération
    add_after = add_after.call if add_after.is_a?(Proc)
    puts "\r= #{name} OK #{add_after}".vert
  end

  ################# MÉTHODES D'IMAGE #####################

  # Largeur de l'image réelle du système
  def sys_width
    @img_width ||= image.first.columns
  end

  # Hauteur de l'image réelle du système
  def sys_height
    @img_height ||= image.first.rows
  end


  ################# MÉTHODES SUR LES MARQUES ###############

  # Boucle (du bloc) sur toutes les marques
  # 
  def each_mark &block
    marks.each do |mark|
      yield mark
    end
  end

  ################# DONNÉES CALCULÉES ###############

  # Ratios vertical et horizontal à appliquer à toute valeur browser
  # 
  def vratio
    @vratio ||= sys_height.to_f / height
  end
  def hratio
    hratio ||= sys_width.to_f / width
  end

  # @return le point le plus haut (en pixel) du système
  # et de ses marques. Permet de définir le zéro absolu
  def topest
    @topest ||= begin
      t = top
      each_mark do |mark|
        t = mark.top if mark.top < t
      end
      t
    end
  end

  ################# DONNÉES VOLATILES ######################

  # Hauteur réelle entière de l'image
  # Note : le "+100" est une marge de sécurité
  def real_full_height
    @real_full_height ||= vratio * full_height + 100
  end

  # Top réel du système
  def real_top
    @real_top ||= vratio * (top - topest)
  end

  # L'image sur laquelle seront taguées toutes les marques
  def image
    @image ||= Magick::ImageList.new(img_systeme_path)
  end

  # Chemin d'accès à l'image du système
  def img_systeme_path
    @img_systeme_path ||= File.join(analyse.folder_systems, "system-#{id}.jpg")
  end

  # Chemin d'accès à l'image du système produite
  def fin_image_path
    @fin_image_path ||= File.join(analyse.folder_export, "system-#{id}.#{options[:format]}")
  end
  def fin_image_name
    @fin_image_name ||= File.basename(fin_image_path)
  end

  ################# DONNÉES FIXES ###################

  def id;     data['id'] end
  def top;    data['top'] end
  def width;  data['width'].to_i  end
  def height; data['height'].to_i end
  def full_height; data['full_height'].to_i end

  ##
  # @return Les marques du système, sous forme d'instances 
  # OutputSystem::Mark
  def marks
    @marks ||= begin
      data['marks'] ||= []
      data['marks'].map do |dmark| 
        classe = case dmark['type']
        when 'acc' then AccordMark
        when 'cad' then CadenceMark
        when 'har' then HarmonieMark
        when 'ped' then PedaleMark
        when 'deg' then DegreMark
        when 'prt' then PartieMark
        when 'mod' then ModulationMark
        when 'emp' then EmpruntMark
        when 'not' then NoteMark
        else
          raise "Le type #{dmark['type']} est inconnu…"
        end
        classe.new(self, dmark)
      end
    end
  end


  def defaultize_options(options)
    options ||= {}
    options.key?('format') || options.merge!('format' => 'png')

    # Symboliser toutes les clés
    options.each do |k, v|
      options.merge!(k.to_sym => v)
    end

  end

end #/class OutputSystem
end #/module ScoreAnalyse
