class MusicScore

  EMPTY_STRING = ''.freeze

  # Pour capturer un réel
  # Par exemple /<?reel>#{REG_REAL})/
  REG_REAL = /(?:\-)?[0-9]+(?:\.[0-9]+)?/.freeze

  REG_SIMPLE_NOTE = /[a-g](isis|eses|is|es)?/.freeze

  REG_NOTE = /\b#{REG_SIMPLE_NOTE}\b/.freeze

  # Ne pas remplacer le "+" par un "*" car certaines expressions
  # se servent de cette expression pour vérifier s’il y a une marque
  # d’octave
  REG_MARK_OCTAVE = /(['’,]+)/.freeze

  REG_MARK_OCTAVE_NOT_ABS = /([^=])(['’,]+)/.freeze


  # Pour capture :note, :alter et :octave
  REG_NOTE_CAPT = /(?<note>[a-grs])(?<alter>isis|eses|is|es)?=?(?<octave>[,'’]*)/.freeze

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

  REG_DUREE_CAPT = /(?<duration>[0-9]+\.*)(?<grace_note>GRN|ACA)?/.freeze

  # Pour récupérer les paramètres d’une note, c’est-à-dire ce qui
  # suit un "-" et peut comprendre l’articulation (-., ->, etc.) le
  # doigté (-5), etc.
  # Les récupérer avec $~[:note_params]
  # 
  # Mais bien souvent, il faut faire une expression propre.
  # 
  # @notes
  #   - pour le moment, l’expression ’-12’ ne passera pas, car
  #     l’expression attend pour le moment un et un seul caractère 
  #     après le tiret ou le trait plat (caractère quelconque pour 
  #     le moment)
  #   - le ’\~[1-5] permet de capter l’écriture des substitutions
  #     de doigt.
  # 
  REG_NOTE_PARAMS = /(?<note_params>([_\-][^)\\](\~[0-5])?)+)/.freeze

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

  REG_NOTE_WITH_PARAMS = /#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?(?:#{REG_NOTE_PARAMS})?/.freeze

  REG_GRACE_INNER  = /\\gr\((?<inner>.*?)\)/.freeze
  
  REG_GRACE_NOTE    = /\\gr\(#{REG_NOTE_WITH_PARAMS}(?<slash>\/)?(?<link>\-)?\)/.freeze

  # Pour capturer plusieurs grace-notes, pas une seule
  # Il faut ensuite traiter les notes en découpant par espace
  REG_GRACE_NOTES = /\\gr\((?<notes>[^)]*?)(?<slash>\/)?(?<link>\-)?\)/.freeze

  REG_MAYBE_CHORD = /<[a-g]/.freeze

  REG_CHORD = /\<(?<chord_exp>.+?)\>(?<duration>[0-9]+\.*)?(?<linked>\~)?/.freeze

  REG_NOLET = /(?<diviseur>[234579])\{(?<notes>.*?)\}/.freeze

  REG_START_REPEAT_MARK = /\\repeat (?:volta|unfold) (?<fois>[0-9]+)/.freeze

  REG_REPETITION_ASTERISK = /\b#{REG_NOTE_CAPT}(?:#{REG_DUREE_CAPT})?\*(?<fois>[0-9]+)/.freeze

  REG_TRILLE_WITH_TERM = /\\(?<pos>[\^_])?tr\((?<notesdep>.*?)\)\-(?<internotes>.*?)\((?<gnotes>.*?)\)\\\-tr/.freeze

  REG_TRILL_START = /\\([\^_])?tr/.freeze
  REG_LONG_TRILL_START = /\\(?<pos>[\^_])?tr\((?<inner>.*?)\)\-/.freeze
  REG_TRILL_END   = /\\\-tr/.freeze



  REG_DOIGTE = /(?<pos>[\-_\^])(?<doigt1>[1-5])(?:\~(?<doigt2>[1-5]))?/.freeze

  # La différence avec REG_DOIGTE, c’est qu’ici la substitution n’est
  # pas optionnelle, on cherche vraiment les doigtés avec substitu-
  # tions
  REG_SUBSTITUTION_DOIGTE = /(?<pos>[\-_\^])(?<doigt1>[1-5])\~(?<doigt2>[1-5])/.freeze


end #/class MusicScore
