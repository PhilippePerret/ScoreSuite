#
# Pour gérer les transpositions
# 
# Pour le moment, ça ne sert que pour le calcul des statistiques, 
# en appelant la méthode ’Transposition.current.tranpose(note)’
class MusicScore
class Transposition

# === CLASSE ===
class << self
  attr_accessor :current
end #/class << self


# === INSTANCE ===

# [TransposeNote] Les deux notes de référence de la transposition
attr_reader :note_ba, :note_to

def initialize(paire)
  # On parse la transposition
  parse(paire)
  # On met cette transposition en transposition courante
  self.class.current = self
end

# @api
# @main
# 
# Méthode qui reçoit la note à transposer et retourne la note
# transposée
# 
# @note
#   On ne passe ici qu’une fois pour chaque note différente. Donc, si
#   on a 5 cis et 3 c, on passe 1 fois pour c et 1 fois pour cis.
# 
def transpose(note_ini)
  note = TransposeNote.new(self, note_ini)
  new_degre = note.transposed_degree
  # puts "\nTransposition de la note #{note_ini.inspect}".jaune
  # puts "new_degre = #{new_degre}".bleu
  # puts "transposed_simple_note = #{note.transposed_simple_note}"
  # puts "transposed_semiton = #{note.transposed_semiton}"
  # puts "Note transposée : #{note.transposed_note}".vert
  # exit 12
  return note.transposed_note
end

def parse(paire)
  n_ba, n_to = paire.split(' ')
  @note_ba = TransposeNote.new(self, n_ba)
  @note_to = TransposeNote.new(self, n_to)
end

# Nombre de degrés de différence entre la note de base et la note
# transposée
def diff_degres
  @diff_degres ||= begin
    note_to.degree - note_ba.degree
  end
end

# Nombre de demi-tons
def diff_semitons
  @diff_semitons ||= begin
    (note_to.semiton - note_ba.semiton).freeze
  end
end

# Structure pour les notes de la transposition, la première comme la
# deuxième
class TransposeNote
  attr_reader :transpositor
  attr_reader :note, :alteration, :octave
  def initialize(transpositor, fullnote)
    @transpositor = transpositor
    tout, @note, @alteration, @octave = fullnote.match(REG_NOTE_TRANSPO).to_a
  end
  def degree
    @degree ||= SIMPLE_NOTES.index(note)
  end

  # Au final, la note transposée
  def transposed_note
    @transposed_note ||= begin
      ary = SEMITONS_PER_INT[transposed_semiton]
      ary.select do |na|
        na.start_with?(transposed_simple_note)
      end.first
    end
  end

  def transposed_simple_note
    @transposed_simple_note ||= begin
      SIMPLE_NOTES[transposed_degree].freeze
    end
  end
  def transposed_degree
    @transposed_degree ||= begin
      if transpositor.diff_degres < 0
        degree + 7 + transpositor.diff_degres
      else 
        degree + transpositor.diff_degres
      end.freeze
    end
  end

  def transposed_semiton
    @transposed_semiton ||= begin
      ((semiton + transpositor.diff_semitons) % 12)
    end
  end

  # Le "semiton" de la note, c’est-à-dire son index/indice en fonction
  # de la note et de l’altération. Par exemple "c" a un semiton de
  # 1 comme "deses" (ré double bémol), "cis" (do dièse) un semiton de
  # 2, comme "des" (ré bémol) etc.
  def semiton
    @semiton ||= SEMITONS["#{note}#{alteration}"].freeze
  end

  REG_NOTE_TRANSPO = /([a-g])(eses|es|isis|is)?([,'’]+)?/.freeze
  SIMPLE_NOTES = ['c','d','e','f','g','a','b','c','d','e','f','g','a','b']
  SEMITONS_PER_INT = {
    1 => ['c'     , 'bis'],
    2 => ['cis'   , 'bisis' , 'des'],
    3 => ['cisis' , 'd'     , 'eeses'],
    4 => ['dis'   , 'ees'   , 'feses'],
    5 => ['disis' , 'e'     , 'fes'],
    6 => ['eis'   , 'f'     , 'geses'],
    7 => ['eisis' , 'fis'   , 'ges'],
    8 => ['fisis' , 'g'     , 'aeses'],
    9 => ['gis'   , 'aes'],
   10 => ['gisis' , 'a'     , 'beses'],
   11 => ['ais'   , 'bes'   , 'ceses'],
   12 => ['aisis' , 'b'     , 'ces']
  }
  SEMITONS = {}
  SEMITONS_PER_INT.each do |ind, ary|
    ary.each do |na|
      SEMITONS.merge!( na => ind)
    end
  end
end
#/class TransposeNote

end #/class Transposition
end #/class MusicScore
