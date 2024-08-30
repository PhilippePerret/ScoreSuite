class MusicScore

  REG_SIMPLE_NOTE = /[a-g](isis|eses|is|es)?/.freeze

  REG_NOTE = /\b#{REG_SIMPLE_NOTE}\b/.freeze

  # Ne pas remplacer le "+" par un "*" car certaines expressions
  # se servent de cette expression pour vérifier s’il y a une marque
  # d’octave
  REG_MARK_OCTAVE = /(['’,]+)/.freeze


  # Pour capture :note, :alter et :octave
  REG_NOTE_CAPT = /(?<note>[a-grs])(?<alter>isis|eses|is|es)?(?<octave>[,'’]*)/.freeze

  # Pour capturer :
  #   $~[:note], 
  #   $~[:alter], 
  #   $~[:octave],
  #   $~[:duration]
  #   $~[:reste]
  # 
  # Le mieux est d’isoler la note (par exemple en splitant avec des
  # espaces) et d’ajouter ’^’ et ’$’ autour de l’expression :
  #   notes.split(' ').first.match(/^#{REG_NOTE_WITH_DUREE_AND_REST}$/)
  REG_NOTE_WITH_DUREE_AND_REST = /#{REG_NOTE_CAPT}(?<duration>[0-9]+\.*)?(?<reste>.*?)/.freeze

  REG_DUREE_CAPT = /(?<duration>[0-9]+\.*)(?<sub_to_next>STN)?/.freeze

  # Expression régulière complète pour repérer une note et
  # sa durée
  # 
  # @notes
  #   - le "\" à la fin se trouve par exemple avant un ’\fermata’
  #   - le ")" à la fin se trouve à la fin d’une liaison
  #   - le "(" à la fin se trouve au début d’une liaison
  #   - le "/" à la fin se trouve dans les accaciatura
  # 
  REG_NOTE_DUREE = /\b#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?(?<linked>\~)?[ \\\^_\)\(\/$]/

  REG_NOTE_DUREE_SIMPLE = /#{REG_NOTE_CAPT}(#{REG_DUREE_CAPT})?/.freeze

  REG_GRACE_NOTE = /\\gr\(#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?(?<slash>\/)?(?<link>\-)?\)/.freeze

  REG_MAYBE_CHORD = /<[a-g]/.freeze

  REG_CHORD = /\<(?<chord_exp>.+?)\>(?<duration>[0-9]+\.*)?(?<linked>\~)?/.freeze

  REG_NOLET = /(?<diviseur>[234579])\{(?<notes>.*?)\}/.freeze

  REG_START_REPEAT_MARK = /\\repeat (?:volta|unfold) (?<fois>[0-9]+)/.freeze

  REG_REPETITION_ASTERISK = /\b#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?\*(?<fois>[0-9]+)/.freeze

  REG_TRILLE_WITH_TERM = /\\(?<pos>[\^_])?tr\((?<notesdep>.*?)\)\-(?<internotes>.*?)\((?<gnotes>.*?)\)\\\-tr/.freeze

end #/class MusicScore
