# encoding: UTF-8
# frozen_string_literal: true
=begin

  Module qui s'occupe de parser le code fourni, qu'il provienne d'un
  fichier ou de la ligne de commande

=end
class MusicScore
class Parser

attr_reader :music_score

# 
# {Array} La liste de tous les blocs de code où toutes les définitions et
# autres traitements ont été appliqués. Chaque élément est une 
# instance BlockCode
attr_reader :all_blocks

##
# Instanciation du parser, avec l'instance [MusicScore] +music_score+
#
def initialize(music_score)
  @music_score = music_score
end

##
# @usage MusicScore::Parser.exec
#
#
# Produit :
#   - les "définitions" qui sont des lignes de code associées à un
#     nom de variable.
#   - les segments d'image
#
def parse
  code = ini_code # note : on a géré les inclusions
  #
  # Suppression des commentaires
  #
  code = code.gsub(/^#(.*)$/,'')
  #
  # Évaluation des fonctions ruby
  # 
  code = evaluate_fonctions_ruby_in(code)
  #
  # Réduction des retours chariot
  # 
  code = code.gsub(/\n\n\n+/, "\n\n").strip
  #
  # Remplacement des apostrophes courbes
  # 
  code = code.gsub('’', '\'')

  #
  # Les options courantes
  #
  options = {definitions_globales:{}, definitions_locales:{}}

  #
  # Pour mettre tous les blocs de code
  #
  all_blocks = []

  # Découpe du code en "paragraphes" qui définissent chacun quelque
  # chose.
  code.split("\n\n").each do |paragraphe|
    # puts "paragraphe = #{paragraphe.inspect}"
    blocode = BlockCode.new(paragraphe, options.merge(music_score:music_score))
    blocode.parse
    options = blocode.options

    #
    # On retire les options ponctuelles
    #
    [:mesure,:proximity].each{|k|options.delete(k)}

    #
    # Cas spécial où il faut seulement parser à partir de là
    #
    if blocode.start?
      # Vider les données récoltées jusque-là
      all_blocks = []
    end

    #
    # Cas spécial où il faut s'arrêter de parser là
    #
    if blocode.stop?
      break
    end

    # 
    # En fonction de la nature de ce bloc de code, on le range 
    # à différents endroits.
    #
    if blocode.definition?
      #
      # Si c’est une définition de variable, on l’enregistre
      # 
      if blocode.global?
        options[:definitions_globales].merge!( blocode.definition_name => blocode)
      else
        options[:definitions_locales].merge!( blocode.definition_name => blocode)
      end
    elsif blocode.only_options?
      #
      # Si c’est seulement des options définies, on ne fait rien
      # puisque ces options ont déjà été enregistrées
      #
    else
      # 
      # Si ce n’est ni des options, ni une définition de variable,
      # alors ce sont des notes, on enregistre le bloc dans la liste
      # des blocs.
      #
      all_blocks << blocode
      # #
      # # Et on ré-initialise les définitions locales
      # # (pourquoi ?… C’était pensé, peut-être, au début, pour
      # # utiliser un seul nom de variable et lui donner une valeur
      # # différente à chaque utilisation.)
      # #
      # options[:definitions_locales] = {}
    end

    # puts "PARA : #{blocode.inspect}"
    # puts "OPTIONS : #{options.inspect}"
  end

  @all_blocks = all_blocks
end
#/parse


# On recherche les fonctions (méthodes) ruby dans le code +str+
# pour les remplacer par leur valeur retournée.
# 
# @rappel
#   Une méthode <method> définie dans un module ruby doit être
#   appelée dans le code par ’fn_<method>(...)’.
# 
def evaluate_fonctions_ruby_in(str)
  return str unless str.match?('fn_')
  str = str.gsub(REG_RUBY_METHOD) do
    method_name = $~[:method_name].to_sym
    arguments   = $~[:arguments]
    if arguments == ''
      send(method_name)
    else
      arguments = eval("[#{arguments}]")
      # puts "arguments: #{arguments.inspect}"
      send(method_name, *arguments)
    end
  end
  # puts "str après :\n#{str}\n-----------------------------"
  return str
end
REG_RUBY_METHOD = /fn_(?<method_name>[a-zA-Z0-9_]+)\(\((?<arguments>.*?)\)\)/.freeze

# Le code MUS initial
# @note
#   Toutes les inclusions ont été traitées, c’est-à-dire que les codes
#   ont été ajoutés au code initial
def ini_code
  @ini_code ||= begin
    music_score.expression.gsub(INCLUDE_CODE) do
      # - Traitement des fichiers inclus -
      include_path_ini = $~[:include_path].strip.freeze
      include_path_ini = "#{include_path_ini}.mus" unless include_path_ini.end_with?('.mus')
      include_path = include_path_ini.dup
      unless include_path.start_with?('/')
        include_path = File.absolute_path(music_score.mus_file.folder,include_path)
      end
      if not(File.exist?(include_path)) || File.directory?(include_path)
        include_path = File.join(APP_FOLDER,'libmus',include_path_ini)
      end
      File.exist?(include_path) || raise("Le fichier à inclure (INCLUDE #{include_path_ini}) est introuvable (#{include_path})")
      # puts "include_path : #{include_path.inspect}".bleu
      # sleep 10
      IO.read(include_path)
    end.gsub(/\r?\n/, "\n").strip
  end
end

INCLUDE_CODE = /^INCLUDE(?<include_path>.+)$/.freeze

end #/Parser
end #/MusicScore