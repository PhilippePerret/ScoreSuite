\version "2.24.0"
#(set-default-paper-size "a0")
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
<<
  \relative c' {
    \time 4/4
    \clef "treble"
    \key c \major
    << { c' d e } \\ { a, b c } >>
  }
>>
% --- %