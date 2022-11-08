# encoding: UTF-8
require 'json'
require 'fileutils'
require 'clir'

# Dossier de l'application
APP_FOLDER = File.dirname(__dir__).freeze
LIB_FOLDER = __dir__.freeze
MOD_FOLDER = File.join(LIB_FOLDER,'modules')

# Dossier dans lequel a été lancé l'application
CURRENT_FOLDER = File.expand_path('.')


# Dir["#{__dir__}/common/*.rb"].each{|m| require m}
Dir["#{__dir__}/required/*.rb"].each{|m| require m}

require_relative 'CommandLine'
require_relative 'App'

