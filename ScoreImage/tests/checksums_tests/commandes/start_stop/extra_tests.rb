module ExtraTestMethods

  def proceed
    main_image_has_good_name
    test_only_one_svg
  end

  # Pour s’assurer que ce n’est pas l’image "image_passee.svg" qui
  # est la principale
  def main_image_has_good_name
    good_one = File.join(musfile.folder, "score.svg")
    bad_one  = File.join(musfile.folder, "image_passee.svg")
    if File.exist?(bad_one)
      errors << "L’image principale ne devrait pas être ’image_passee.svg’"
    end
    if not(File.exist?(good_one))
      errors << "L’image principale devrait être ’score.svg’."
    end
  end

  def test_only_one_svg
    ['image_passee', 'autre_image_passee'].each do |affix|
      nimg = "#{affix}.svg"
      fimg = File.join(musfile.build_folder, nimg).freeze
      not(File.exist?(fimg)) || begin
        errors << "L’image ’#{nimg}’ n’aurait pas dû être produite…"
      end
    end
  end

end #/module ExtraTestMethods
