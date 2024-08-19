\version "2.24.0"
#(set-default-paper-size "a0" 'landscape)
\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
  % Numérotation des pages
  % Essai d’espacement entre les systèmes si nécessaire
  % Nombre de systèmes par page
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
      \repeat volta 2 { c d e f  \alternative { \volta 1 { g f e d } \volta 2 { g a b c } } }  \repeat volta 2 {  d, e fis g  \alternative { \volta 1 { a g fis e } \volta 2 { a b cis d } } }  e,1
    }
  >>
  } %/fin de score
  % --- %