#!/usr/bin/env ruby -U
# encoding: UTF-8
# frozen_string_literal: true
require 'bundler/setup'
Bundler.require(:default)


begin
  
  require_relative 'required'
  commande = ARGV[0]
  # puts "[ScoreImage] commande: #{commande.inspect}"
  # puts "[ScoreImage] Dossier courant: #{File.expand_path('.')}"
  puts "[ScoreImage] ENV['CUR_DIR']: #{ENV['CUR_DIR']}"

  if commande.end_with?('.mus')
    # C’est un fichier mus spécifié
    if File.exist?(commande)
      mus_file_path = commande
    else
      dossier = ENV['CUR_DIR']||ENV['CURRENT_FOLDER']||ENV['PWD']
      mus_file_path = File.join(dossier, commande)
    end
    puts "mus_file_path: #{mus_file_path}"
    if File.exist?(mus_file_path)
      commande = 'build'
    end
  end

  case commande
  when 'test', 'tests'
    require_relative 'lib/modules/Tests/main.rb'
    ScoreImage::Test.run
  when 'help'
    puts "Je ne sais pas encore gérer l’aide.".jaune
  when 'manuel', 'manual'
    MusicScore.open_manual
  when NilClass, '.'
    # Passage normal
    MusicScore.run
  when 'build'
    MusicScore.run(path: mus_file_path)
  else
    if File.exist?(commande) || File.exist?(File.join(ENV['CUR_DIR'].to_s,commande))
      MusicScore.run
    else
      puts "Je ne connais pas la commande #{commande.inspect}.".jaune
    end
  end
rescue EMusicScore => e
  puts "\n#{e.message}".rouge
  puts e.backtrace.join("\n").rouge if verbose?
rescue Exception => e
  exit 101 if e.message.match?('exit')
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge
end
