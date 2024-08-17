# Pour faire des tests supplémentaires
module ExtraTestMethods

  def proceed
    # Tester que les autres images ont bien été créées
    test_other_svgs
  end

  def test_other_svgs
    [2,3,4].each do |indice|
      imgname = "image#{indice}.svg"
      pth = File.join(musfile.build_folder, imgname)
      File.exist?(pth) || begin
        errors << "L’image #{imgname} devrait avoir été construite…"
      end
    end
  end

end #/module ExtraTestMethods
