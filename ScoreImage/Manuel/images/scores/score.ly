\version "2.24.0"
#(set-default-paper-size "a5" 'portrait)
\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
}
% --- %
lhMarkText = \markup {
  \concat {
    \override #'(font-encoding . latin1) \italic "m.g. "
    \path #0.1 #'((moveto 0 -0.5)(rlineto 0 2.5)(rlineto 0.5 0))
  }
}
rhMarkText = \markup {
  \concat {
    \override #'(font-encoding . latin1) \italic "m.d. "
    \path #0.1 #'((moveto 0 1)(rlineto 0 -2.5)(rlineto 0.5 0))
  }
}
lhMark = \markup {
  \path #0.1 #'((moveto -1 0)(rlineto 0 3.5)(rlineto 0.5 0))
}
rhMark = \markup {
  \path #0.1 #'((moveto -1 0)(rlineto 0 -3.5)(rlineto 0.5 0))
}
\score {
  \new Staff <<
    \relative c' {
      \omit Staff.TimeSignature
      \clef "treble"
      a' 
      \set fingeringOrientations = #'(left) 
      <a\finger \rhMark>
      <a\finger \lhMark>
      <a\finger \rhMarkText>
      <a\finger \lhMarkText>
      a
    }
  >>
  } %/fin de score
  % --- %
