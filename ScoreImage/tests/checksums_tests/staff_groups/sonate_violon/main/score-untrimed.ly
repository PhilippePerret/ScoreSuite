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
\layout {
  \context {
    % On utilise context pour utiliser des context
  }
}
% --- %
\score {
  <<
    \new Staff \with { instrumentName = "Violon" }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c4( d e f g1) }
      }
    }
    \new GrandStaff \with { instrumentName = "Piano" } <<
      \new Staff  {
        \relative c'' {
          \clef treble
          \omit Staff.TimeSignature
          \relative c' { e4( f g a b1) }
        }
      }
      \new Staff  {
        \relative c {
          \clef bass
          \omit Staff.TimeSignature
          \relative c' { c,8 c c c c c c c g1 }
        }
      }
    >>
  >>
}
% --- %