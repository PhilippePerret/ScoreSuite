module ExtraTestMethods

  def proceed
    test_transposed_tune_method
  end

  def test_transposed_tune_method
    require './lib/required/Transposition'

    [
      # [<inst tonalité>, <piece tune>  , <armure required>]
      # [<sax en Bb]>   , <morceau en D>, <E majeur requis>] 

      ['bes'  , 'd'   , 'e'   ],
      ['ees'  , 'ees' , 'c'   ],
      ['ees'  , 'aes' , 'f'   ],
      ['ees'  , 'd'   , 'b'   ],
      ['a'    , 'a'   , 'c'   ],
      ['a'    , 'd'   , 'f'   ],
      ['a'    , 'c'   , 'ees' ],
      ['c'    , 'c'   , 'c'   ],
      ['c'    , 'd'   , 'd'   ],
    ].each do |inst, piece, expected|
      actual = MusicScore::Transposition.transposed_tune(inst, piece)
      if actual == expected
        # OK
      else
        errors << "[extra_tests.rb:#{__LINE__}] La tonalité attendue était #{expected.inspect}. La méthode ScoreImage::Transposition#transposed_tune a retourné #{actual.inspect}."
      end
    end
  end

end #/module ExtraTestMethods
