#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'lib/required'

begin
  
  # ScoreExtraction::CommandLine.parse
  # option_path = ScoreExtraction::CommandLine.options[:path]

  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreCutting::CommandLine.show_help
  else
    curdir = CURRENT_FOLDER
    puts "Dossier courant : #{curdir}"
    ScoreCutting::App.current_folder = curdir
    ScoreCutting::App.check_and_get_partition || raise("Abandon.")
    Dir.chdir(curdir) do
      WAA.goto File.join(__dir__,'main.html')
      WAA.run
    end
  end
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit
end

