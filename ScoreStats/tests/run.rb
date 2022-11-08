# encoding: UTF-8
require_relative '../../lib/tests/required'
require_relative 'lib/required'

TESTS_FOLDER = __dir__


COMMAND_SCORE_STATE = File.expand_path(File.join(__dir__,'..','score_stats.rb'))
# ARGV = ['--stats','--only_stats']

#
# On charge tous les tests pour les jouer
#
Dir["#{__dir__}/tests/**/*.test.rb"].each do |test_sheet|
  require test_sheet
end
