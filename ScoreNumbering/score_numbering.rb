#!/usr/bin/env ruby
# encoding: UTF-8


begin
  CUR_DIR = ARGV.shift
  require_relative 'lib/required'
  
  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreNumbering::CommandLine.show_help
  else
    CUR_DIR = ENV['CUR_DIR']
    verbose? && puts("Dossier courant : #{CUR_DIR}".bleu)
    ScoreNumbering::App.current_folder = CUR_DIR
    Dir.chdir(CUR_DIR) do
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

