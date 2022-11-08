# encoding: UTF-8
module ScoreAnalyse
class OutputSystem
class NoteMark < Mark

  def vrectif
    -100
  end

  def font
    ARIAL_NARROW_FONT
  end

  def font_size
    28
  end

  # Pour ajouter le tour du type de note
  def build_iadded_form
    prepare_iadded_form
    left  = real_left + 80
    top   = real_top + 100
    metrics = icontent.get_type_metrics(systeme.image, content)
    # puts "\nmetrics: #{metrics.inspect}".jaune
    # puts "w : #{w.inspect}".jaune
    w       = systeme.hratio * (metrics.width + 10)
    h       = systeme.vratio * (metrics.height + 5)
    iadded_form.ellipse(left, top, w, h, 0, 360)
  end

end #/class NoteMark
end #/class OutputSystem
end #/module ScoreAnalyse
