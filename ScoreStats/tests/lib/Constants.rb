# encoding: UTF-8

ALL_NOTES = ['a','b','c','d','e','f','g']
all = ALL_NOTES.dup
['es','is','eses','isis'].each do |alt|
  all.each do |note|
    ALL_NOTES << "#{note}#{alt}"
  end
end
# puts "ALL_NOTES: #{ALL_NOTES}"


BATAVE_TO_ITALIENNE = {
  'a' => 'LA',
  'b' => 'SI',
  'c' => 'DO',
  'd' => 'RÉ',
  'e' => 'MI', 
  'f' => 'FA',
  'g' => 'SOL'
}
ALT_ALL_TO_ITA = {
  '' => '',
  'is' => '#',
  'es' => 'b', 
  'isis' => 'x',
  'eses' => 'bb'
}
