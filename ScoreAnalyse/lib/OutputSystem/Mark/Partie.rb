# encoding: UTF-8
module ScoreAnalyse
class OutputSystem
class PartieMark < Mark

  def font_size
    32
  end

  def build_iadded_form
    # 
    # Le rectangle
    # 
    prepare_iadded_form
    # --- Dimensions ---
    top     = real_top + STROKE_WIDTH - padding
    bottom  = top + padding + real_font_size + 20 + padding
    left    = real_left - padding
    right   = left + padding + (1.2 * real_width) + padding
    # --- Le rectangle autour du nom ---
    iadded_form.rectangle(left, top, right, bottom)
    # 
    # La ligne verticale
    # 
    iadded_form.line(left, top, left, top + real_height)
  end


  def real_top
    @real_top ||= super - 100
  end

  def padding
    @padding ||= 20.freeze
  end

end #/class PartieMark
end #/class OutputSystem
end #/module ScoreAnalyse
