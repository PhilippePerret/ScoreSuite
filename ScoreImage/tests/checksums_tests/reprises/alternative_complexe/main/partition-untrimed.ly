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
      c4 d e f  \repeat volta 2 {  c4 d e f  \alternative { \volta 1 { e2 d } \volta 2 { d2 c } } }  b c
    }
  >>
  } %/fin de score
  % --- %