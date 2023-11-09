#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'lib/required'

begin
  
  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreNumbering::CommandLine.show_help
  else
    curdir = CURRENT_FOLDER
    puts "Dossier courant : #{curdir}"
    ScoreNumbering::App.current_folder = curdir
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

