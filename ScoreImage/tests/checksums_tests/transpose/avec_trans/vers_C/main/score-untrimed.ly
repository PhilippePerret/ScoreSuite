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
    \new Staff \with { \consists Merge_rests_engraver }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \key ees \major
        \relative c' { ees f g aes bes }
      }
    }
    \new Staff \with { \consists Merge_rests_engraver }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \key ees \major
        \relative c' { ees f g aes bes }
      }
    }
    \new Staff \with { \consists Merge_rests_engraver }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \key c \major \transpose c a { \relative c' { ees f g aes bes } }
      }
    }
  >>
  } %/fin de score
  % --- %