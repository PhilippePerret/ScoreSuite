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
    \Score
    
  }
}

<<
\relative c' {
  \omit Staff.TimeSignature
  
  
	\clef "treble"
  
  
	 \shadedGrace b'8_ a4 
}
>>

