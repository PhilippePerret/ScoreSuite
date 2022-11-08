# encoding: UTF-8
require 'yaml'

APP_FOLDER = File.dirname(__dir__)

CURRENT_FOLDER = File.expand_path('.')

def out(msg)
  puts msg
end

# Librairies de la suite Score
require_relative '../../lib/required'

require_relative 'App'
require_relative 'Analyse'
