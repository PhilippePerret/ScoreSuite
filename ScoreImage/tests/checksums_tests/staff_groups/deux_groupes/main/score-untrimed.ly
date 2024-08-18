\version "2.24.0"
#(set-default-paper-size "a0")
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
    \new GrandStaff <<
      \new Staff \with { instrumentName = "Fl." }  {
        \relative c'' {
          \clef treble
          \time 4/4
          \key c \major
          \relative c' { c8 e g c g e c e }
        }
      }
      \new Staff \with { instrumentName = "Hb." }  {
        \relative c'' {
          \clef treble
          \time 4/4
          \key c \major
          \relative c' { e4. e8 e4. e8 }
        }
      }
      \new Staff \with { instrumentName = "Cl." }  {
        \relative c'' {
          \clef treble
          \time 4/4
          \key c \major
          \relative c' { c4 c' c, c' }
        }
      }
    >>
    \new Staff \with { instrumentName = "Cor" }  {
      \relative c {
        \clef bass
        \time 4/4
        \key c \major
        \relative c' { c,2 c' }
      }
    }
    \new GrandStaff \with { instrumentName = "Piano" } <<
      \new Staff  {
        \relative c'' {
          \clef treble
          \time 4/4
          \key c \major
          \relative c' { c8 e g c g e c e }
        }
      }
      \new Staff  {
        \relative c {
          \clef bass
          \time 4/4
          \key c \major
          \relative c' { c,4 c c c }
        }
      }
    >>
    \new Staff \with { instrumentName = "Cb." }  {
      \relative c {
        \clef bass
        \time 4/4
        \key c \major
        \relative c' { c1 }
      }
    }
  >>
  } %/fin de score
  % --- %