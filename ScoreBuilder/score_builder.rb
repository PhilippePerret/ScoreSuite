#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'lib/required'

begin
  
  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreBuilder::CommandLine.show_help
  else
    # 
    # = Lancement de l’application =
    # 
    curdir = CURRENT_FOLDER
    # puts "Dossier courant : #{curdir}"
    ScoreBuilder::App.current_folder = curdir
    params = ScoreBuilder::App.goto_params
    Dir.chdir(curdir) do
      WAA.goto( File.join(__dir__,'main.html'), **params)
      WAA.run
    end
  end
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit
end

