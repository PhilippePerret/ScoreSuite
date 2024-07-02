#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'lib/required'

begin
  @waa_is_running = false
  if help?
    require File.join(MOD_FOLDER,'help')
    ScoreBuilder::CommandLine.show_help
  else
    # 
    # = Lancement de l’application =
    # 
    clear
    
    # On prend le dossier courant ou le dossier spécifié en
    # argument de la ligne de commande.
    # 
    curdir = ARGV.select do |arg|
      File.exist?(arg) && File.directory?(arg)
    end.first 
    curdir = curdir ? File.expand_path(curdir) : CURRENT_FOLDER
    
    # puts "Dossier courant : #{curdir}"
    ScoreBuilder::App.current_folder = curdir
    # On regarde si le dossier courant est bon
    ScoreBuilder::App.check_current_folder || raise("Abandon.".bleu)
    params = ScoreBuilder::App.goto_params
    Dir.chdir(curdir) do
      WAA.goto( File.join(__dir__,'main.html'), **params)
      @waa_is_running = true
      WAA.run
    end
  end
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit if @waa_is_running
end

