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
    \new GrandStaff <<
      \new Staff \with { \consists Merge_rests_engraver
      instrumentName = "Fl." }  {
        \relative c'' {
          \clef treble
          \omit Staff.TimeSignature
          \relative c' { c4 d e f } \relative c' { c4 d e f }
        }
      }
      \new Staff \with { \consists Merge_rests_engraver
      instrumentName = "Hb." }  {
        \relative c'' {
          \clef treble
          \omit Staff.TimeSignature
          \relative c' { c4 d e f } \relative c' { c4 d e f }
        }
      }
      \new Staff \with { \consists Merge_rests_engraver
      instrumentName = "Ba." }  {
        \relative c {
          \clef bass
          \omit Staff.TimeSignature
          \relative c' { c,4 d e f } \relative c' { c,4 d e f }
        }
      }
    >>
    \new GrandStaff <<
      \new Staff \with { \consists Merge_rests_engraver
      instrumentName = "Vl." }  {
        \relative c'' {
          \clef treble
          \omit Staff.TimeSignature
          \relative c' { c4 d e f } \relative c' { c4 d e f }
        }
      }
      \new Staff \with { \consists Merge_rests_engraver
      instrumentName = "Alto" }  {
        \relative c' {
          \clef alto
          \omit Staff.TimeSignature
          \relative c' { c4 d e f } \relative c' { c4 d e f }
        }
      }
      \new Staff \with { \consists Merge_rests_engraver
      instrumentName = "Cb." }  {
        \relative c {
          \clef bass
          \omit Staff.TimeSignature
          \relative c' { c,4 d e f } \relative c' { c,4 d e f }
        }
      }
    >>
  >>
  } %/fin de score
  % --- %