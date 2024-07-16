#!/usr/bin/env ruby
# encoding: UTF-8
require 'bundler/setup'
Bundler.setup

require_relative 'lib/required'

begin

  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreCutting::CommandLine.show_help
  else
    curdir = ENV['CUR_DIR']
    ScoreCutting::App.current_folder = curdir
    if ScoreCutting::App.check_and_get_partition
      Dir.chdir(curdir) do
        WAA.goto File.join(__dir__,'main.html')
        WAA.run
      end
    end
  end
rescue InterruptionSilencieuse
  # Silence…
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  begin
    WAA.driver.quit if defined?(WAA) && WAA.running?
  rescue Selenium::WebDriver::Error::InvalidSessionIdError => e
  end
  puts "Bye bye".bleu
end

