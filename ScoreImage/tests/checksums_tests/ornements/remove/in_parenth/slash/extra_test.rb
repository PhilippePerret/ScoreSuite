module ExtraTestMethods

  def proceed
    # Pour tester le fichier sans grace note
    extrafile = ScoreImage::Test::ExtraFile.new(self, **{
      file_name: 'score_sans.svg',
      designation: 'sans_gr'
    })
    extrafile.test_match
  end

end #/module
