#!/usr/bin/env ruby -U
# encoding: UTF-8
# frozen_string_literal: true
# require 'bundler/setup'
# Bundler.setup
# Bundler.require


begin
  
  CURRENT_DIR = ARGV.shift

  # require_relative '../lib/required'
  require_relative 'required'
  
  # commande = ARGV[0]
  commande = CLI.main_command

  if commande && commande.end_with?('.mus')
    # C’est un fichier mus spécifié
    if File.exist?(commande)
      mus_file_path = commande
    else
    mus_file_path = File.join(CURRENT_DIR, commande)
    end
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
    # Si du code a été transmis par heredoc
    input_code = STDIN.read
    STDIN.gets # pour chopper le retour final
    if input_code
      # puts "input_code:\n#{input_code.inspect}"
      MusicScore.run(input_code: input_code.strip, can_open:true)
    else
      MusicScore.run
    end
  when 'build'
    MusicScore.run(path: mus_file_path)
  else
    if File.exist?(commande) || File.exist?(File.join(ENV['CUR_DIR'].to_s,commande))
      MusicScore.run
    else
      puts "[ScoreImage] Je ne connais pas la commande #{commande.inspect}.".jaune
    end
  end
rescue EMusicScore => e
  if "string".respond_to?(:rouge)
    puts "\n#{e.message}".rouge
    puts e.backtrace.join("\n").rouge if verbose?
  else
    puts "\n#{e.message}"
    puts e.backtrace.join("\n") if verbose?
  end
rescue Exception => e
  exit 101 if e.message.match?('exit')
  if "string".respond_to?(:rouge)
    puts e.message.rouge
    puts e.backtrace.join("\n").rouge
  else
    puts "\n#{e.message}"
    puts e.backtrace.join("\n") if verbose?
  end
end
