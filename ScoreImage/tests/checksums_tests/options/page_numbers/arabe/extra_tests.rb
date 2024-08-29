module ExtraTestMethods

  def proceed
    extra_file = ScoreImage::Test::ExtraFile.new(self, **{
      file_name: 'score-2.svg',
      designation: 'P2'
    })
    extra_file.test_match
    # Pour le mettre dans le dossier principal
    extra_file.move_to_main_folder
  end


end #/module ExtraTestMethods
