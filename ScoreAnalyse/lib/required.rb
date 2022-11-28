# encoding: UTF-8
require 'yaml'
require 'fileutils'

APP_FOLDER = File.dirname(__dir__)

CURRENT_FOLDER = File.expand_path('.')

def out(msg)
  puts msg
end

# Librairies de la suite Score
require_relative '../../lib/required'

# Dossier required
Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}
