# encoding: UTF-8
module ScoreAnalyse
class OutputSystem
class DegreMark < Mark

  def vrectif
    -100
  end
  def hrectif
    38
  end

  def font
    PHILNOTE_FONT_BOLD
  end

  def font_weight
    Magick::BoldWeight
  end
  
  def font_size
    32
  end


end #/class DegreMark
end #/class OutputSystem
end #/module ScoreAnalyse
