#!/usr/bin/env ruby
# encoding: UTF-8
require 'bundler/setup'
Bundler.require
Bundler.setup


require_relative 'lib/required'

begin
  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreBuilder::CommandLine.show_help
  else
    # 
    # = Lancement de l’application =
    # 
    clear
    CLI.set_options_table(i: :interactive)
    CLI.init
        
    # On regarde si le dossier courant est bon
    retourOK = ScoreBuilder::App.check_current_folder 
    retourOK || raise(ScoreBuilder::AbandonException.new)
    
    params = ScoreBuilder::App.goto_params
    Dir.chdir(ScoreBuilder::CURRENT_FOLDER) do
      WAA.goto( File.join(__dir__,'main.html'), **params)
      WAA.run
    end
  end
rescue ScoreBuilder::AbandonException
  # Fin silencieuse
rescue Exception => e
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge if verbose?
ensure
  begin
    WAA.driver.quit if defined?(WAA) && WAA.running?
  rescue Selenium::WebDriver::Error::InvalidSessionIdError => e
  end
  puts "Bye bye.".bleu
end

