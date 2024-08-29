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
      \relative c' { fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \sharp \musicglyph "scripts.turn" \teeny \sharp } fis,^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \sharp \musicglyph "scripts.turn" \teeny \flat } fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \flat \musicglyph "scripts.turn" \teeny \flat } fis,^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \flat \musicglyph "scripts.turn" \teeny \sharp } fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \natural \musicglyph "scripts.turn" \teeny \natural } fis,^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \flat \musicglyph "scripts.turn" \teeny \natural } fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \natural \musicglyph "scripts.turn" \teeny \flat } fis,^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \sharp \musicglyph "scripts.turn" \teeny \natural } fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny \natural \musicglyph "scripts.turn" \teeny \sharp } fis,^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny  \musicglyph "scripts.turn" \teeny \natural } fis'^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny  \musicglyph "scripts.turn" \teeny \sharp } fis,^\markup \override #'(baseline-skip . 2) \halign #-0.7 \center-column { \teeny  \musicglyph "scripts.turn" \teeny \flat } }
    }
  >>
  } %/fin de score
  % --- %