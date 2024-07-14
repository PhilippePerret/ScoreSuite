# encoding: UTF-8
require 'fileutils'
require_relative 'required/constants'

def require_folder(path)
  return unless File.exist?(path)
  Dir["#{path}/**/*.rb"].each{|m|require(m)}
end

require_folder(File.join(ScoreBuilder::LIB_FOLDER,'required','system'))
require_folder(File.join(ScoreBuilder::LIB_FOLDER,'required','app'))
require_folder(File.join(ScoreBuilder::LIB_FOLDER,'required','test'))

require_relative 'required/constants_after'

# On aura besoin du launcher pour ScoreImage
require_relative '../../lib/launcher'
# => Launcher
