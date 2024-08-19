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
  <<
    \new Staff \with { \consists Merge_rests_engraver
    instrumentName = \markup { \concat { \column { "M.(C" } \column { \vspace #-0.3 { \teeny \sharp } } \column { ")" } } } }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c'4 d e f }
      }
    }
    \new Staff \with { \consists Merge_rests_engraver
    instrumentName = \markup { \concat { \column { "Cl.(B" } \column { \vspace #-0.2 { \small \flat } } \column { ")" } } } }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c4 d e f }
      }
    }
  >>
  } %/fin de score
  % --- %