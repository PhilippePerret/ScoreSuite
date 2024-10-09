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
      \time 6/8
      \clef "treble"
      e32 f e32 f e32 f e32 f e32 f e32 f f8 a c \set subdivideBeams = ##t e,32 f e32 f e32 f e32 f e32 f e32 f f8 a c \set subdivideBeams = ##f e,32 f e32 f e32 f e32 f e32 f e32 f f8 a c
    }
  >>
  } %/fin de score
  % --- %