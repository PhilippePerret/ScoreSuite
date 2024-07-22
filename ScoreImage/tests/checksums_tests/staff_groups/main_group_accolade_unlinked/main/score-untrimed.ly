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
  \new GrandStaff <<
    \new Staff \with { instrumentName = "Vl." }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c4 d e f } \relative c' { c4 d e f }
      }
    }
    \new Staff \with { instrumentName = "Alto" }  {
      \relative c' {
        \clef alto
        \omit Staff.TimeSignature
        \relative c' { c4 d e f } \relative c' { c4 d e f }
      }
    }
    \new Staff \with { instrumentName = "Cb." }  {
      \relative c {
        \clef bass
        \omit Staff.TimeSignature
        \relative c' { c4, d e f } \relative c' { c4, d e f }
      }
    }
  >>
}
% --- %