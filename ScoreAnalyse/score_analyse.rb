#!/usr/bin/env ruby
# encoding: UTF-8
=begin

  Script maitre de l'application "Table d'Analyse v2"

=end
require_relative 'lib/required'

begin

  if ['help','aide','-h','--help'].include?(ARGV[0])

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
      WAA.run
    end
  end
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit
end
