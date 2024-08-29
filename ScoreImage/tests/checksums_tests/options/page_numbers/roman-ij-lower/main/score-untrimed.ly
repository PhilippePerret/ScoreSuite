\version "2.24.0"
#(set-default-paper-size "b6")
\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
  print-page-number = ##t
  page-number-type = #'roman-ij-lower
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
      c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f c1 d e f
    }
  >>
  } %/fin de score
  % --- %