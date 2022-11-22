# encoding: UTF-8
require 'json'
require 'fileutils'

# Dossier de l'application
APP_FOLDER = File.dirname(__dir__)

# Dossier dans lequel a été lancé l'application
CURRENT_FOLDER = File.expand_path('.')


Dir["#{__dir__}/common/*.rb"].each{|m| require m}

require_relative 'CommandLine'
require_relative 'App'

