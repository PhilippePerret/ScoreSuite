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
  \new PianoStaff <<
    \new Staff = "haute" {
      % enforce creation of all contexts at this point of time
      \clef "treble"
      \relative c' {
        \omit Staff.TimeSignature
        \relative c' { \once \override TextScript #'script-priority = #-100 a'1\mordent^\markup { \hspace #0.5 \center-column { \teeny \sharp } } } \relative c' { \once \override TextScript #'script-priority = #-100 a'1\mordent^\markup { \hspace #0.5 \center-column { \teeny \flat } } } \relative c' { \once \override TextScript #'script-priority = #-100 a'1\mordent^\markup { \hspace #0.5 \center-column { \teeny \natural } } }
      }
    }
    \new Staff = "basse" {
      \clef bass
      \relative c {
        \omit Staff.TimeSignature
        \relative c' { \once \override TextScript #'script-priority = #-100 c,1\mordent^\markup { \hspace #0.5 \center-column { \teeny \sharp } } } \relative c' { \once \override TextScript #'script-priority = #-100 c,1\mordent^\markup { \hspace #0.5 \center-column { \teeny \flat } } } \relative c' { \once \override TextScript #'script-priority = #-100 c,1\mordent^\markup { \hspace #0.5 \center-column { \teeny \natural } } }
      }
    }
  >>
  } %/fin de score
  % --- %