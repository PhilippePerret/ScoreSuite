#!/usr/bin/env ruby
# encoding: UTF-8
=begin

  Script maitre de l'application "Table d'Analyse v2"

=end
require_relative 'lib/required'

driver_on = false

begin

  if ARGV[0].nil?

    puts "
    Il faut passer le chemin d'accès au dossier de l'analyse en
    premier argument.
    Le plus simple est d'ouvrir une fenêtre Terminal au dossier
    contenant l'analyse (ou devant la contenir) et de mettre en
    premier argument seulement le nom.

    Jouer ".rouge + 'score-analyse help'.jaune + " pour obtenir de l'aide.
    ".rouge

  elsif ['help','aide','-h','--help'].include?(ARGV[0])

    ScoreAnalyse::App.aide

  else

    #
    # Vérification de l'analyse à utiliser (création, etc.)
    # 
    ScoreAnalyse::Analyse.check_current && begin
      # 
      # Fonctionnement normal : ouverture de la 
      # table d'analyse
      # 
      WAA.goto File.join(__dir__,'index.html')
      driver_on = true
      WAA.run
    end
  end
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit rescue nil if driver_on
end
