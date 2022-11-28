=begin

Tous les messages

=end

LANG = 'fr'

LOCALES_FOLDER = File.expand_path(File.join(__dir__,'..','locales',LANG))
ERRORS    = YAML.load_file(File.join(LOCALES_FOLDER,'errors'), aliases:true, symbolize_names:true)
MESSAGES  = YAML.load_file(File.join(LOCALES_FOLDER,'messages'), aliases:true, symbolize_names:true)
