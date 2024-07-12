class MusicScore

  YAML_OPTIONS = {symbolize_names:true, permitted_classes: [Date, Time, Symbol]}

  ERREUR_YAML = <<~TEXT
  ---
  200: |
    Dans les options staves_names et staves_keys, Le nombre de portées 
    ne correspond pas au nombre de clés.
  500: Pas de groupes imbriqués.
  501: Un groupe n’a pas été fermé.

  TEXT


  # ATTENTION : au singulier, pour pouvoir faire ’ERREUR[200]’
  # ERREUR = YAML.safe_load(ERREUR_YAML,**YAML_OPTIONS)
  ERREUR = YAML.safe_load(ERREUR_YAML)

  ERREUR.each do |k, m|
    ERREUR.merge!( k => "ERREUR [#{k}] #{m}")
  end

end #/class MusicScore
