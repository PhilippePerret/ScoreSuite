#!/usr/bin/env ruby
# encoding: UTF-8
require 'bundler/setup'
Bundler.setup

begin
  require_relative 'lib/required'
  
  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreNumbering::CommandLine.show_help
  else
    curdir = ENV['CUR_DIR']
    verbose? && puts("Dossier courant : #{curdir}".bleu)
    ScoreNumbering::App.current_folder = curdir
    Dir.chdir(curdir) do
      WAA.goto File.join(__dir__,'main.html')
      WAA.run
    end
  end
rescue InterruptionSilencieuse => e
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  begin
    WAA.driver.quit if defined?(WAA)
  rescue Selenium::WebDriver::Error::InvalidSessionIdError => e
  end
  puts "Bye bye".bleu
end

