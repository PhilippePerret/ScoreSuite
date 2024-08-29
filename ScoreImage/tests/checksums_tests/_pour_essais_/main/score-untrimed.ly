\version "2.24.0"
#(set-default-paper-size "b6" 'portrait)
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
      fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \sharp \musicglyph "scripts.turn" \teeny \flat }

      fis,_\markup \override #'(baseline-skip . 2) \halign #-0.5 \center-column { \teeny \sharp \musicglyph "scripts.turn" \teeny \flat }
    }
  >>
  } %/fin de score
  % --- %
