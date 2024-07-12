#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true
=begin

  Class LilyPond
  --------------
  Pour gérer lilypond et produire des svg de notes

=end
require_relative 'required'

begin
  
  case (commande = ARGV[0])
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
  else
    if File.exist?(commande)
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
