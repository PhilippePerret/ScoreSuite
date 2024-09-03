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
      \key e \major
      \relative c' { \tuplet 3/2 { gis8 cis e } } \relative c' { \tuplet 3/2 { gis8 cis e } } \relative c' { \tuplet 3/2 { gis8 cis e } } \relative c' { \tuplet 3/2 { gis8 cis e } }
    }
  >>
  } %/fin de score
  % --- %