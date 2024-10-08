\version "2.24.0"
#(set-default-paper-size "a0" 'landscape)
\paper{
  indent=0\mm
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup = ##f
  scoreTitleMarkup = ##f
}
% --- %
\score {
  \layout {
    \context {
      % On utilise context pour utiliser des context
    }
  }
  \new Staff \with { \consists Merge_rests_engraver } <<
    \relative c' {
      \omit Staff.TimeSignature
      \clef "treble"
      << { \stemDown g' r } \\ { \stemUp c r } >> \set Merge_rests_engraver.suspendRestMerging = ##t << { \stemDown g r } \\ { \stemUp e' r } >> \set Merge_rests_engraver.suspendRestMerging = ##f << { \stemDown g, r } \\ { \stemUp c r } >>
    }
  >>
  } %/fin de score
  % --- %