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
  % \path #0.1 #'((moveto -1 0)(rlineto 0 3.5)(rlineto 0.5 0))
  \path #0.1 #'((moveto -0.5 1)(rlineto 0 3.5)(rlineto 0.5 0))
}
rhMark = \markup {
  % \path #0.1 #'((moveto -1 0)(rlineto 0 -3.5)(rlineto 0.5 0))
  % \path #0.1 #'((moveto -5 0)(rlineto 0 -3.5)(rlineto 0.5 0))
}
\score {
  \layout {
    \context {
      % On utilise context pour utiliser des context
    }
  }
  \new PianoStaff \with { \consists Merge_rests_engraver } <<
    \new Staff = "haute" {
      % enforce creation of all contexts at this point of time
      \clef "treble"
      \relative c' {
        \omit Staff.TimeSignature
        e8 e \set fingeringOrientations = #'(left) <gis\finger \lhMark>8-.-5  b \set fingeringOrientations = #'(left) <d\finger \rhMark>  f \set fingeringOrientations = #'(left) <d\finger \rhMark>  e f \set fingeringOrientations = #'(left) <c,\finger \lhMarkText>  \set fingeringOrientations = #'(left) <c'\finger \rhMarkText>4
      }
    }
    \new Staff = "basse" {
      \clef bass
      \relative c {
        \omit Staff.TimeSignature
        r2 f8 e d \set fingeringOrientations = #'(left) <e\finger \rhMark>  \set fingeringOrientations = #'(left) <d\finger \lhMark>  \set fingeringOrientations = #'(left) <f\finger \rhMarkText>  \set fingeringOrientations = #'(left) <e\finger \lhMarkText>
      }
    }
  >>
  } %/fin de score
  % --- %
