module ExtraTestMethods

  def proceed
    extra_file = ScoreImage::Test::ExtraFile.new(self, **{
      file_name: 'score-2.svg',
      designation: 'P2'
    })
    extra_file.test_match
  end


end #/module ExtraTestMethods