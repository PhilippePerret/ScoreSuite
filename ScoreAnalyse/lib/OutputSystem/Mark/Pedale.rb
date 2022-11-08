# encoding: UTF-8
module ScoreAnalyse
class OutputSystem
class PedaleMark < Mark

  def font_size
    28
  end

  def prolong_hrectif
    10
  end

  # Dessine le rond autour de la pédale
  def build_iadded_form
    iadded_form.stroke_width(STROKE_WIDTH)
    iadded_form.fill_opacity(0)
    iadded_form.stroke(NOIR_MARQUE)
    top   = real_top  + 90
    left  = real_left + 40
    iadded_form.circle(left, top, left - 100, top)
  end

end #/class PedaleMark
end #/class OutputSystem
end #/module ScoreAnalyse
