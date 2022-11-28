=begin

Tous les messages

=end

LANG = 'fr'

LOCALES_FOLDER = File.expand_path(File.join(__dir__,'..','locales',LANG))
ERRORS.merge!(YAML.load_file(File.join(LOCALES_FOLDER,'errors.yaml'), aliases:true, symbolize_names:true))
MESSAGES.merge!(YAML.load_file(File.join(LOCALES_FOLDER,'messages.yaml'), aliases:true, symbolize_names:true))
