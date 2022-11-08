\version "2.18.2"

#(set-default-paper-size "a0" 'landscape)

\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
}

\layout {
  \context {
    
    
  }
}

\Score {
  \new StaffGroup <<
\new Staff <<
  \new Voice \relative c'' {
    \set Staff.instrumentName = #"Main gauche "
\clef treble

    \time 4/4
    
    
    
    
     a2 b c d 
  }
>>

\new Staff <<
  \new Voice \relative c' {
    \set Staff.instrumentName = #"Milieu "
\clef alto

    \time 4/4
    
    
    
    
     e2 f g a 
  }
>>

\new Staff <<
  \new Voice \relative c {
    \set Staff.instrumentName = #"Main droite "
\clef bass

    \time 4/4
    
    
    
    
     c2 d e f 
  }
>>

  >>
}


