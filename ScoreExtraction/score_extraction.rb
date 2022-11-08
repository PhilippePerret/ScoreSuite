#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'lib/required'

begin
  case ARGV[0]
  when 'options'
    ScoreExtraction::CommandLine.show_options
  when 'help', 'aide'
    ScoreExtraction::CommandLine.show_help
  else  
    ScoreExtraction::CommandLine.parse
    ScoreExtraction::Score.extract
  end
rescue Exception => e
  puts e.message
  puts e.backtrace.join("\n")
end
