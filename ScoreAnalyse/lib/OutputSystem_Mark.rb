# encoding: UTF-8
=begin

  class ScoreAnalyse::OutputSystem::Mark
  --------------------------------------
  Marques pour le système exporté

=end
module ScoreAnalyse
class OutputSystem
class Mark

  #
  # {OuputSystem} Système contenant la marque
  # 
  attr_reader :systeme
  #
  
  # Données initiales de la marque
  # 
  attr_reader :data

  def initialize(systeme, data)
    @systeme = systeme
    @data = data
  end

  ##
  # Construction de l'image et ajout à image
  # 
  # @param {RMagick::imageList} image
  # 
  def build(image)
    if has_content?
      build_icontent
      icontent.draw(image)
    end    
    if has_prolongline?
      build_iprolong_line
      iprolong_line.draw(image)
    end
    if has_added_form?
      build_iadded_form
      iadded_form.draw(image)
    end
  end

  ######### MÉTHODES GRAPHIQUES ##############

  def build_icontent
    icontent.font(font)
    icontent.font_weight(font_weight)
    icontent.pointsize(systeme.hratio * font_size)
    icontent.fill(font_color)
    icontent.gravity(content_gravity)
    icontent.text(real_left, real_top, content_deligatured)
  end

  def build_iprolong_line
    iprolong_line.stroke_width(STROKE_WIDTH)
    iprolong_line.stroke(NOIR_MARQUE)
    top   = real_top  + 100 + prolong_vrectif
    left  = real_left + 150 + prolong_hrectif
    right = left + real_width
    iprolong_line.line(left, top, right, top)
  end

  def prepare_iadded_form
    iadded_form.stroke_width(STROKE_WIDTH)
    iadded_form.stroke(NOIR_MARQUE)
    iadded_form.fill_opacity(0)
  end

  # @return le {Magick::Draw} du contenu de la marque 
  def icontent
    @icontent ||= Magick::Draw.new
  end

  # @return le {Magick::Draw} de la ligne (s'il y a lieu)
  def iprolong_line
    @iprolong_line ||= Magick::Draw.new
  end

  # @return le {Magick::Draw} de la forme ajoutée (if any)
  def iadded_form
    @iadded_form ||= Magick::Draw.new
  end

  ########### DONNÉES GRAPHIQUES ##############
  # (note : chacune de ces méthodes peut être surclassée
  #  par une sous-classe)

  def font            ; ARIAL_NARROW_FONT         end
  def font_weight     ; Magick::NormalWeight      end
  def font_size       ; 42                        end
  def real_font_size
    @real_font_size ||= systeme.vratio * font_size 
  end
  def font_color      ; NOIR_MARQUE               end
  def content_gravity ; Magick::NorthWestGravity  end


  ##
  # Certains contents doivent utiliser une police différente
  # en fonction du fait qu'ils ont été modifiés 
  # Cela est dû au fait que ImageMagic ne gère par les ligatures sans
  # Pango et que je ne sais pas utiliser Pango avec ImageMagic.
  # J'ai donc dû créer un font PhilNoteExport qui permet de produire
  # toutes les marques sans aucune ligature
  def police_philnote
    @police_philnote ||= begin
      if content != content_deligatured
        PHILNOTE_FONT_EXPORT
      else
        PHILNOTE_FONT_REGULAR
      end
    end
  end

  ##
  # Rectification des top et left de la marque (en fonction du type
  # de marque — cf. chaque sous-classe)
  def vrectif
    0
  end
  def hrectif
    0
  end

  ##
  # Rectification des top et left de la ligne de prolongation
  # en fonction du type de la marque
  def prolong_vrectif
    0
  end
  def prolong_hrectif
    0
  end

  ########### STATES ###############

  def has_content?
    not(content.nil?)
  end

  def has_prolongline?
    data['prolong']
  end

  def has_added_form?
    respond_to?(:build_iadded_form)
  end

  ########### DONNÉES TRAITÉES #############

  # @return {String} le +content+ de la marque, mais sans aucune
  #                  ligature.
  # Car :
  # Je ne sais pas utiliser Pango avec RMagick, donc les ligatures
  # ne sont pas traitées.
  # Pour palier ce problème, j'ai créé la font PhilNoteExport qui
  # ne contient plus aucune ligature. Il faut donc remplacer tous
  # les textes contenant '+', '-' ou '*'
  # Et changer la police
  def content_deligatured
    @content_deligatured ||= begin
      txt = content.dup
      if txt.match?(/[\+\-\*]/)
        LIGA_ORDER_1.each do |src|
          txt = txt.gsub(src, TABLE_LIGA_TO_CHAR[src])
          # puts "#{src.inspect} remplacé par #{TABLE_LIGA_TO_CHAR[src].inspect} => #{txt.inspect}"
        end
        TABLE2_LIGA_TO_CHAR.each do |src, dst|
          txt = txt.gsub(src, dst)
          # puts "#{src.inspect} remplacé par #{dst.inspect} => #{txt.inspect}"
        end
      end
      TABLE3_LIGA_TO_CHAR.each do |src, dst|
        txt = txt.gsub(src, dst)
      end
      txt
    end
  end

  ########### DONNÉES CALCULÉES ##############
  
  def real_top
    @real_top ||= systeme.vratio * abs_top + V_ADJUST + vrectif
  end

  def abs_top
    @abs_top ||= top - systeme.topest
  end

  def real_left
    @real_left ||= systeme.hratio * left + H_ADJUST + hrectif
  end

  def real_width
    @real_width ||= systeme.hratio * width + W_ADJUST
  end

  def real_height
    @real_height ||= systeme.vratio * height
  end

  ########### DONNÉES FIXES ################
  
  def id;       data['id']      end
  def top;      data['top']     end
  def left;     data['left']    end
  def right;    data['right']   end
  def width;    data['width']   end
  def height;   data['height']  end
  def content;  data['content'] end

end #/class Mark
end #/class OutputSystem
end #/module ScoreAnalyse
