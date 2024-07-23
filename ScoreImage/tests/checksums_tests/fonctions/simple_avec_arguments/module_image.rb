module ScoreImage

  def mesure(octave)
    "c#{octave} d e f"
  end

  def motif(basse, contrebasse, notes_sup, params = {})
    ns = notes_sup.split(' ')
    key = params.key?(:mg_key) ? "\\\\cle #{params[:mg_key]} " : ''
    <<~TEXT.tap {|t| reffile.puts t}
    \\relative c'' { r8 #{ns[0]}16 #{ns[1]} #{ns[2]} #{ns[0]}, #{ns[1]} #{ns[2]} r8 #{ns[0]},16 #{ns[1]} #{ns[2]} #{ns[0]}, #{ns[1]} #{ns[2]} }
    #{key}<< r16 #{contrebasse}8.~ #{contrebasse}4 r16 #{contrebasse}8.~ #{contrebasse}4 // #{basse}2 #{basse}2 >>
    TEXT
  end

  # Pour débug
  def reffile
    @reffile ||= begin
      File.delete(refile_path) if File.exist?(refile_path)
      File.open(refile_path,'a').tap do |rf|
        rf.puts "# Ce fichier permet de calculer les notes et les \n# durées pour les statistiques.\n"
      end
    end
  end

  def refile_path
    @refile_path || File.join(__dir__,'code_mus_complet.txt')
  end

end #/module ScoreImage
