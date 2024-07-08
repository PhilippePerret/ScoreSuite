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

<<
\relative c' {
  \omit Staff.TimeSignature
  
  
  \clef "treble"
  
  
   \relative c' { c4( d e f g1) } 
}
>>



