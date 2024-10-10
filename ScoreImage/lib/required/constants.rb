class MusicScore

  LIB_FOLDER = File.dirname(__dir__)
  APP_FOLDER = File.dirname(LIB_FOLDER)

  LANG = 'fr'

  YAML_OPTIONS = {symbolize_names:true, permitted_classes: [Date, Time, Symbol]}

  ERREUR_YAML = <<~TEXT
  ---
  200: |
    Dans les options staves_names et staves_keys, Le nombre de portées 
    ne correspond pas au nombre de clés.
  500: Pas de groupes imbriqués.
  501: Un groupe n’a pas été fermé.

  1700: Une trille longue requiert impérativement sa maque de fin ’\\-tr’.

  2000: Trop d’itérations pour supprimer les Parentheses.font-size dans ’%s’
  2001: Trop d’itérations pour supprimer les Parentheses.padding dans ’%s’
  TEXT


  # ATTENTION : au singulier, pour pouvoir faire ’ERREUR[200]’
  # ERREUR = YAML.safe_load(ERREUR_YAML,**YAML_OPTIONS)
  ERREUR = YAML.safe_load(ERREUR_YAML)

  ERREUR.each do |k, m|
    ERREUR.merge!( k => "ERREUR [#{k}] #{m}")
  end


  CUR_DIR = ENV['CUR_DIR']||ENV['CURRENT_FOLDER']||ENV['PWD']

  SHORT_OPTION_TO_LONG = {
    o: :open
  }

  CLI.set_options_table(SHORT_OPTION_TO_LONG)

end #/class MusicScore
