# encoding: UTF-8
# frozen_string_literal: true
require 'fileutils'

class EMusicScore < StandardError; end

def verbose?
  MusicScore.verbose?
end

SHORT_OPTION_TO_LONG = {
  'h' => :help,
  'l' => :lilypond,
  'v' => :verbose,
  's' => :stats,
  't' => :tempo
}
OPTIONS = {} # conservera les options de la ligne de commande

THISFOLDER = __dir__
Dir["#{THISFOLDER}/lib/**/*.rb"].each{|m|require(m)}

