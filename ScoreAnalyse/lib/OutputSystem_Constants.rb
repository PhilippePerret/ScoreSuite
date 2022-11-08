# encoding: UTF-8
module ScoreAnalyse
class OutputSystem

  FONTS_FOLDER = File.join(Dir.home,'Library','Fonts')
  PHILNOTE_FONT_REGULAR = File.join(FONTS_FOLDER,'PhilNote2-Regular.otf')
  PHILNOTE_FONT_BOLD    = File.join(FONTS_FOLDER,'PhilNote2-Bold.otf')
  PHILNOTE_FONT_EXPORT  = File.join(FONTS_FOLDER,'PhilNoteExport-Regular.otf')
  ARIAL_NARROW_FONT     = File.join(FONTS_FOLDER,'Arial Narrow.ttf')

  # Ajustement pour que les marques se marques pile à l'endroit 
  # voulu.
  #
  V_ADJUST = 124
  H_ADJUST = 24
  W_ADJUST = -170

  NOIR_MARQUE = 'cmyk(40,40,40,40)'

  STROKE_WIDTH = 12

  # Largeur maximale du système avant d'être réduit
  SYSTEM_MAX_WIDTH = 3000

  table = {
    'IV**'  => 'R',
    'VII**' => 'P', 'II**' => 'L',
    'VI***' => '£', 'VI**'  => 'O',
    'III**' => 'J', 'III*' => 'K',
    'V***'  => '€'
  }
  table.merge!({
    'IV*' => 'T',
    'VI*' => 'S',
    'II*' => 'U',
    'V**' => 'W',
    'VII*' => 'Q'
  })
  TABLE_LIGA_TO_CHAR = {}
  table.each do |k, v|
    TABLE_LIGA_TO_CHAR.merge!( k => v )
  end

  TABLE2_LIGA_TO_CHAR = {
    '--' => 'h', '++' => 'i',
    '+2' => 'z',
    '+4' => 'y', '4-' => 'u', '4+' => 't',
    '5-' => 'x', '5+' => 'v',
    '6+' => 's', '+6' => 'o',
    '7-' => 'w',
    'I*' => 'Y',
    'V*' => 'X', 
  }
  # Les choses sans '*' ni '-' ou '+'
  TABLE3_LIGA_TO_CHAR = {
    'I64' => 'Z',
  }

  # Pour traiter dans l'ordre
  LIGA_ORDER_1 = [
    'VII**', 'III**', 'II**',
    'IV**', 'V***', 'V**',
    'VI***', 'VI**', 'VI*',
    'III*', 'VII*', 'II*'
  ]

end #/class OutputSystem
end #/module ScoreAnalyse
