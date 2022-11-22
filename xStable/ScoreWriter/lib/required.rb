# encoding: UTF-8
require 'fileutils'
require 'yaml'
require_relative 'CommandLine'
require_relative 'App'

# On parse la ligne de commande
ScoreWriter::CommandLine.parse

# Dossier de l'application
APP_FOLDER = File.dirname(__dir__)

# Dossier dans lequel a été lancé l'application
REAL_CUR_FOLDER = File.expand_path('.')
CURRENT_FOLDER = if ScoreWriter::CommandLine.options[:path]
  pth = ScoreWriter::CommandLine.options[:path]
  if pth == 'manuel' || pth == 'aide'
    `open "#{File.join(APP_FOLDER,'Manuel','Manuel.pdf')}"`
    REAL_CUR_FOLDER
  elsif File.directory?(pth)
    pth
  elsif File.exist?(pth)
    ScoreWriter::CommandLine.affixe_partition = File.basename(pth)
    File.dirname(pth)
  else
    REAL_CUR_FOLDER
  end
else
  REAL_CUR_FOLDER
end
puts "CURRENT_FOLDER: #{CURRENT_FOLDER}"
puts "Affixe : #{ScoreWriter::CommandLine.affixe_partition.inspect}"

SCORE_SUITE_FOLDER = File.join(Dir.home, 'Programmes','ScoreSuite')


Dir["#{__dir__}/common/*.rb"].each{|m| require m}

require_relative 'MusScore'

