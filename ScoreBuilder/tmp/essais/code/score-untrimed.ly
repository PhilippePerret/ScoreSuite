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
\new PianoStaff <<
  \new Staff = "haute" {
    % enforce creation of all contexts at this point of time
    \clef "treble"
    \relative c' {
      \time 4/4
      \key c \major
      c1 d e f g a b c b a g f e d c d e f g a b c b a g f e d c
    }
  }
  \new Staff = "basse" {
    \clef bass
    \relative c {
      \time 4/4
      \key c \major
      c1 b a g f e d c d e f g a b c b a g f e d c d e f g a b c
    }
  }
>>
% --- %