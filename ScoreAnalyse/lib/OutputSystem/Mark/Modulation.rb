# encoding: UTF-8
module ScoreAnalyse
class OutputSystem
class ModulationMark < Mark


  def build_icontent
    icontent.translate(real_left + 40, real_top)
    icontent.rotate(-26)
    @real_left = 0
    @real_top  = 0
    super
  end


  def font
    police_philnote
  end

  def font_size
    32
  end

  # Construction des lignes pour la marque de modulation
  def build_iadded_form
    iadded_form.stroke_width(STROKE_WIDTH)
    iadded_form.stroke(NOIR_MARQUE)
    top     = real_top - 20
      # Noter que le @real_top ici est plus bas que le real_top
      # pour les autres marques
    bottom  = top + real_height + 150
    left    = real_left - 20
    # La ligne vertical
    iadded_form.line(left, top, left, bottom)
    # La ligne de travers sur la tonalité
    iadded_form.line(left, top, left + 400, top - 200)
  end

  # Le texte d'une modulation doit être placé plus bas
  def real_top
    @real_top ||= begin
      systeme.vratio * abs_top + V_ADJUST + 220
    end
  end

end #/class ModulationMark
end #/class OutputSystem
end #/module ScoreAnalyse
