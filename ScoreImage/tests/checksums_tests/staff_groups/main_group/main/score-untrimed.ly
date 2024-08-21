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
  <<
    \new Staff \with { \consists Merge_rests_engraver
    instrumentName = "Vl." }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c4 d e f } \relative c' { c4 d e f }
      }
    }
    \new Staff \with { \consists Merge_rests_engraver
    instrumentName = "Alto" }  {
      \relative c' {
        \clef alto
        \omit Staff.TimeSignature
        \relative c' { c4 d e f } \relative c' { c4 d e f }
      }
    }
    \new Staff \with { \consists Merge_rests_engraver
    instrumentName = "Cb." }  {
      \relative c {
        \clef bass
        \omit Staff.TimeSignature
        \relative c' { c,4 d e f } \relative c' { c,4 d e f }
      }
    }
  >>
  } %/fin de score
  % --- %