module ExtraTestMethods

  def proceed
    extra_file = ScoreImage::Test::ExtraFile.new(self, **{
      file_name: 'score.midi',
      designation: 'MIDI'
    })
    extra_file.test_match
  end

end #/ExtraTestMethods
