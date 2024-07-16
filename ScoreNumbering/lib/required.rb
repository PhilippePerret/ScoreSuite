# encoding: UTF-8
require 'fileutils'
require 'yaml'
require 'pretty_inspect'
require 'clir'

require_relative 'required/constants'


def require_folder(path)
  return unless File.exist?(path)
  Dir["#{path}/**/*.rb"].each{|m|require(m)}
end

require_folder(File.join(ScoreNumbering::LIB_FOLDER,'required','system'))
require_folder(File.join(ScoreNumbering::LIB_FOLDER,'required','app'))
require_folder(File.join(ScoreNumbering::LIB_FOLDER,'required','test'))
