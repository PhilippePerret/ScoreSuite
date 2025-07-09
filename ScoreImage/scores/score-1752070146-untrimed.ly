\version "2.24.0"
#(set-default-paper-size "a0" 'landscape)
\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
}
% --- %
\score {
  \layout {
    \context {
      % On utilise context pour utiliser des context
    }
  }
  \new Staff \with { \consists Merge_rests_engraver } <<
    \relative c' {
      \omit Staff.TimeSignature
      \clef "treble"
      /Users/philippeperret/ICARE_EDITIONS/_LIVRES_/Musique/RPSM/Pieces/piano/1119-BACH_BWV846_PreludeEnDo_inCBT1_C score_code.mus
    }
  >>
  } %/fin de score
  % --- %