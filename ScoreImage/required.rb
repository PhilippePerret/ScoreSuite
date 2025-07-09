# encoding: UTF-8
# frozen_string_literal: true
require 'clir'
require 'yaml'

class EMusicScore < StandardError; end

def verbose?
  MusicScore.verbose?
end

CLI.set_options_table({
  l:   :lilypond,
  s:   :stats,
  t:   :tempo,
  f:   :fail_fast,
  ff:  :fail_fast,
})
# OPTIONS = {} # conservera les options de la ligne de commande

module ScoreImage

  THISFOLDER = APP_FOLDER = __dir__
  Dir["#{THISFOLDER}/lib/required/**/*.rb"].each{|m|require(m)}

end #/module ScoreImage
