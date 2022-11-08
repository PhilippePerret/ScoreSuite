# encoding: UTF-8
require 'fileutils'

# Dossier de l'application
APP_FOLDER = File.dirname(__dir__)

# Dossier dans lequel a été lancé l'application
CURRENT_FOLDER = File.expand_path('.')

# La commande 'scorize' (maintenant score-image)
SCORISE_CMD = "ruby #{Dir.home}/Programmes/ScoreSuite/ScoreImage/score_image.rb"


Dir["#{__dir__}/common/*.rb"].each{|m| require m}

require_relative 'CommandLine'
require_relative 'Score'

