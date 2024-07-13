#
# Lancement de ce script :
#
#     > cd /Users/philippeperret/Programmes/ScoreSuite/LauncherTry && bundle exec ruby try.rb

require 'bundler/setup'
Bundler.require(:default)

puts "VERSION RUBY : #{RUBY_VERSION}"

require_relative '../lib/launcher.rb'
Dir.chdir('/Users/philippeperret/ICARE_EDITIONS/_LIVRES_/Musique/RPSM/Pieces/piano/BACH_BWV846_PreludeEnDo_inCBT1_C') do
  Launcher.launch(:score_image, ['score_code.mus'])
end

