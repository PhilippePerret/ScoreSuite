\version "2.24.0"
#(set-default-paper-size "a0" 'landscape)
\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
  % Essai d’espacement entre les systèmes si nécessaire
}
\layout {
  \context {
  }
}
% --- %
\score {
  <<
    \new Staff \with { instrumentName = "Fl." }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c8 e g c g e c e }
      }
    }
  >>
  \new Staff \with { instrumentName = "Hb." }  {
    \relative c'' {
      \clef treble
      \omit Staff.TimeSignature
      \relative c' { e4. e8 e4. e8  }
    }
  }
  \new StaffGroup <<
    \new Staff \with { instrumentName = "Cl." }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c4 c' c, c' }
      }
    }
    \new Staff \with { instrumentName = "Cor" }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c2 c' }
      }
    }
    \new Staff \with { instrumentName = "Piano" }  {
      \relative c'' {
        \clef treble
        \omit Staff.TimeSignature
        \relative c' { c8 e g c g e c e }
      }
    }
  >>
  \new StaffGroup <<
    \new Staff \with { instrumentName = "Piano" }  {
      \relative c {
        \clef bass
        \omit Staff.TimeSignature
        \relative c' { c,4 c c c }
      }
    }
    \new Staff \with { instrumentName = "Cb." }  {
      \relative c {
        \clef bass
        \omit Staff.TimeSignature
        \relative c' { c1 }
      }
    }
  >>
}
% --- %