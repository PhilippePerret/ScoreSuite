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
  
  MusicScore.init
  mscore = MusicScore.new
  mscore.proceed

rescue EMusicScore => e
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge if verbose?
rescue Exception => e
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge
end

exit # POUR S'ARRÊTER LÀ

class LilyPond
class << self

  def produce_from_file(fpath)

    # 
    # Boucle sur chaque expression
    # 
    expressions.each do |dexp|

      if OPTIONS[:only_new] && File.exists?(svg_file)
        # Si l'option '--only_new' est activée et que le fichier existe
        # déjà, on ne le refait pas
        next
      elsif OPTIONS[:proximity].is_a?(Range)
        # La valeur de :proximity est un rang, il faut produire une
        # image avec chaque proximité
        safe_prox_prefix = @safe_affixe.freeze
        OPTIONS.merge!(proximity_init: OPTIONS[:proximity].freeze)
        OPTIONS[:proximity_init].each do |prox|
          @safe_affixe = "#{safe_prox_prefix}-prox#{prox}"
          OPTIONS[:proximity] = prox
          produce_from_code(expression)
          @nombre_expressions_traited += 1
          `open '#{svg_file}'` if OPTIONS[:open]
        end
      else
        produce_from_code(expression)
        @nombre_expressions_traited += 1
        `open '#{svg_file}'` if OPTIONS[:open]
      end
    end
    if OPTIONS[:only_new] && @nombre_expressions_traited == 0
      puts "Aucun fichier à actualiser.\nPour forcer la ré-écriture de toutes les expressions, retirer l'option --only_new.\nPour ne forcer la ré-écriture que d'un fichier, le détruire dans le dossier d'arrivée ('#{File.basename(folder)}')."
    end
  end

  # 
  # Production du fichier LilyPond qui va permettre de produire
  # l'image de la partition.
  # 
  def produce_from_code(lilypond_exp, name = nil)
    @expression = lilypond_exp
    puts "Production du fichier SVG à partir de l'expression '#{lilypond_exp[0..15]}...'.\nMerci de patienter…".bleu
    #
    # === FABRICATION DU FICHIER SVG ===
    #
    # On lance sur le fichier la commande lily2svg


    # Pour voir les fichiers récupérés :
    # puts "files_to_trim: #{files_to_trim.inspect}"

    if files_to_trim.count > 0
      # puts "OPTIONS: #{OPTIONS}"

      #
      # === ON TRIME LE(S) FICHIER(S) SVG ===
      #
      # Cette opération est nécessaire pour obtenir juste la dimension
      # voulue, parfaitement aux contours de l'image.
      #
      if trim_svg_files(files_to_trim)
        if not(OPTIONS[:keep])
          File.delete(lilypond_file)
        end
        if files_to_trim.count > 1
          puts "Les fichiers ont été produits avec en préfixe de nom “#{safe_affixe}” (#{safe_affixe}-1, #{safe_affixe}-2 etc.)\n(dans le dossier #{File.dirname(svg_file)}/)".vert
        else
          puts "Le fichier a été produit avec le nom “#{svg_file_name}”\n(dans le dossier #{File.dirname(svg_file)}/)".vert
        end
      end
    else
      puts "Impossible de produire le fichier “#{svg_file_name}”…".rouge
    end
  end

end # /<< self
end #/LilyPond
