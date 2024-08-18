module ExtraTestMethods

  def proceed
    if not(File.exist?(lilypond_file_path))
      errors << "Le fichier #{lilypond_file_path.inspect} devrait exister."
    end
  end

  def lilypond_file_path
    @lilypond_file_path ||= File.join(musfile.build_folder,"score-untrimed.ly")
  end

end #/module ExtraTestMethods
