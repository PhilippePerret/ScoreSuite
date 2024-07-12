module ScoreImage

  def mesure(octave)
    "c#{octave} d e f"
  end

  def motif(basse, contrebasse, notes_sup, params = {})
    ns = notes_sup.split(' ')
    key = params.key?(:mg_key) ? "\\\\cle #{params[:mg_key]} " : ''
    <<~TEXT
    \\relative c'' { r8 #{ns[0]}16 #{ns[1]} #{ns[2]} #{ns[0]}, #{ns[1]} #{ns[2]} r8 #{ns[0]},16 #{ns[1]} #{ns[2]} #{ns[0]}, #{ns[1]} #{ns[2]} }
    #{key}<< r16 #{contrebasse}8.~ #{contrebasse}4 r16 #{contrebasse}8.~ #{contrebasse}4 // #{basse}2 #{basse}2 >>
    TEXT
  end

end #/module ScoreImage
