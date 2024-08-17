# encoding: UTF-8
# frozen_string_literal: true
=begin

  Class MusicScore::Parser::BlockCode
  -----------------------------------
  Pour un bloc de code, un paragraphe

  Un bloc de code peut être de différentes nature :

    - une option seule (par exemple une ligne contenant '--piano OFF')
    - plusieurs options seules
    - la définition d'une image ('->', mais pas forcément au début)
    - une définition de variable (la première ligne est forcément
      terminée par un '=')
    - une commande (START, STOP)

=end
require_relative 'BlockCode_mus_code_module'
class MusicScore
class Parser
class BlockCode


# L'expression régulière qui traque les séquences d'images
REG_SEQUENCE_IMAGES = /\b([a-zA-Z]+)([0-9]+?)<\->([0-9]+?)\b/

# # Expression régulière pour la définition d’une variable
REG_DEFINITION = /^[a-zA-Z0-9_\/\-]+\=\=?$/.freeze

attr_reader :raw_code
attr_reader :options
attr_reader :lines_code
#
# Si définition
#
attr_reader :definition_name

#
# Si image
#
attr_reader :image_name

##
# Instanciation du bloc de code avec son contenu et les options
# courantes
#
# @param  raw_code {String}
#         Le code (pseudo lilypond = music-score)
# @param  options {Hash}
#         Les options en court. Elles pourront être modifiée par
#         l'analyse du bloc de code
#
def initialize(raw_code, options)
  @raw_code = raw_code
  @options  = options.dup
end

# --- Méthodes de statut ---

def definition?
  !@definition_name.nil?
end
def global? # si définition
  definition? && @is_global_definition
end
def local?  # si définition
  definition? && !@is_global_definition
end

def only_options?
  @lines_code.count == 0
end

def start?
  @muststartgravure
end

def stop?
  @muststopgravure
end

##
# Analyse du raw_code
#
# On passe chaque ligne en revue
#
def parse
  #
  # Les lignes de code de musique
  #
  @lines_code = []

  if verbose?
    puts "Raw code étudié :\n<<<<<<<<<\n#{raw_code}\n>>>>>>>>>>>>\n"
  end

  lines = raw_code.split("\n")

  #
  # Est-ce une définition ?
  #
  if lines[0].match?(REG_DEFINITION)
    # 
    # <= La première ligne termine par '=' ou '=='
    # => C'est une définition
    #
    # Mars 2024 On ne fait plus la distinction entre définition
    # globale et locale, elles sont toute globales
    @is_global_definition = true
    line1 = lines.shift
    if line1.end_with?('==')
      # @is_global_definition = true
      @definition_name = line1[0..-3]
    else
      # @is_global_definition = false
      @definition_name = line1[0..-2]
    end
  end

  #
  # Boucle sur toutes les lignes à traiter
  # (souvent, il n'y en a qu'une ou deux — piano)
  #
  lines.each do |line|
    line = line.strip
    if line.start_with?('->')
      #
      # Définition du nom de l'image
      #
      @image_name = line[2..-1].strip
    elsif line.start_with?('--')
      # 
      # Définition d'une option
      #
      traite_as_option(line[2..-1])
    elsif line.split(' ')[0].match?(/^[A-Z]{3,}$/)
      traite_as_commande(line)
    else
      #
      # Définition d'une ligne de code music-score
      #
      @lines_code << line
    end
  end

  # Dans le cas d’un piano (option ’--piano’) et d’une définition
  # unique des lignes de code ’lines_code’, on dédouble la ligne qui
  # doit être composée de variables. Car pour le piano, on peut 
  # faire :
  # 
  #   m1=
  #   c d e f
  #   c1
  # 
  #   m2
  #   g a c d
  #   g1
  # 
  #   -> score
  #   m1 m2
  # 
  if options['piano'] && @lines_code.count == 1
    @lines_code << @lines_code[0]
  end

  # Cas particulier : plusieurs lignes de notes mais pas de mode
  # multi-pistes défini (par --staves_keys et --staves_names)
  if @image_name && lines_code.count > 1
    if options[:staves_keys]
      # Tout est bien défini au niveau des portées multiples
    else
      # Aucune système à portées multiples n’est défini, il faut le
      # faire (en mettant toutes les clés à Sol)
      xkeys = Array.new(lines_code.count, 'G').join(',')
      options.merge!('staves_keys' => xkeys)
    end
  end

  if options['tempo']
    music_score.options.merge!(tempo: options['tempo'])
  end

  # On doit maintenant remplacer les variables dans chaque ligne
  # ainsi que quelques corrections
  # 
  lines = []
  @lines_code.each_with_index do |line, idx|
    lines << traite_as_code_mscore(line, idx)
  end

  # Note : normalement, ici, @lines_code ne doit contenir que les
  # notes, les expressions Lilypond.
  @lines_code = lines

  # Calcul des statistiques
  # puts "music_score.options: #{music_score.options}"
  # puts "options: #{options}"
  # exit 12
  if (options[:stats]||music_score.options[:stats]||CLI.options[:stats]) && @lines_code.any?
    require_relative 'Statistiques'
    MusicScore::Statistiques.new(music_score, @lines_code, **options).produce
  end

end

def music_score
  @music_score ||= options[:music_score]
end


def traite_as_option(opt)
  o = opt.split(' ')
  opt = o.shift
  setting = o.empty? ? nil : o.join(' ')
  val = case setting
    when 'OFF', 'Off', 'off' then false
    when NilClass then true
    else setting # la valeur de l'option, p.e. pour mesure, ou time
    end

  # Quelques correspondances de clé et correction de
  # valeurs
  # Note : s'il vient à y en avoir beaucoup, on les mettra dans
  # une table.
  case opt
  when 'page' then val = "\"#{val}\""
  when 'tune' then opt = 'key'
  when 'proximity'
    if val && val.match?('-')
      # C'est un rang de proximités, il faut produire une 
      # image pour chaque valeur
      from, to = val.split('-').collect{|i|i.to_i}
      val = (from..to)
    end
  end

  options.merge!({opt => val, opt.to_sym => val})
end
#/traite_option

def traite_as_commande(line)
  commande, params = line.split(' ')  
  case commande
  when 'START'.freeze
    @muststartgravure = true
  when 'STOP'.freeze
    @muststopgravure = true
  else
    raise "Je ne connais pas la commande #{line.inspect}"
  end
end
#/ traite_as_commande



# 
# Remplacement des définitions dans +str+
# 
# @return {String}  La ligne de code avec les remplacements de 
#                   variables effectués.
#
# @param  {String} str La ligne de code
# @param  {Number} line_idx  Index de la ligne, pour savoir quelle ligne
#                       utiliser dans la définition.
def traite_definitions_in(str, line_idx)

  definitions = {}
  definitions.merge!(options[:definitions_locales])
  definitions.merge!(options[:definitions_globales])

  # puts "Je dois remplacer les définitions :\n\t#{DEFINITIONS.inspect}\net\n\t#{DEFINITIONS_GLOBALES.inspect}\ndans:\n\t#{str.inspect}"
  str = " #{str} "

  # Dans un premier temps, il faut remplacer les séquences de 
  # mesures sous la forme [img][index départ]<->[index fin] par les
  # mesures concernées.
  # [NOTE 001]
  # Depuis Juil 2024, on met mettre un numéro plus grand que le 
  # dernier numéro déjà créé (par exemple pour mettre le tout dernier
  # numéro de la partition)
  #  
  if str.match?('<->')
    # puts "AVANT traitement séquence :\n#{str.freeze}"
    str = str.gsub(REG_SEQUENCE_IMAGES){
      prefix = $1.freeze
      index_start = $2.to_i.freeze
      index_stop  = $3.to_i.freeze
      (index_start..index_stop).map do |index|
        # On pourrait mettre un ’break’ pour sortir dès qu’on trouve
        # une mesure indéfini (voir [NOTE 001] ci-dessus) mais on 
        # laisse la possibilité, par exemple, d’avoir les mesures de
        # 1 à 10 définies, puis un trou de 10 à 13 et les 14 et 
        # suivantes définies. Le seul problème serait d’avoir une
        # partition momentanéement fausse.
        varname = "#{prefix}#{index}"
        if definitions[varname]
          varname
        else
          nil # variable pas encore définie
        end
      end.compact.join(' ')
    }
    # puts "\n\nAPRÈS traitement séquence :\n#{str}"
  end


  # puts "Définitions à traiter : #{definitions.inspect}"

  # On boucle sur chaque définition (chaque "variables") pour la
  # remplacer par ce qu’elle doit être.
  # 
  # @note
  #   Les définitions sont maintenant "dynamique" (cf. le manuel)
  #   ce qui fait qu’on peut trouver après des caractères pouvant
  #   définir :
  #   - la répétition du motif    *N
  #   - la hauteur du motif       , ou '
  # 
  definitions.each do |search, blocode|
    str.match?(search) || next
    remp = blocode.lines_code[line_idx] || blocode.lines_code[0]
    # puts "remp: #{remp.inspect}::#{remp.class}"
    if not remp.is_a?(String)
      if remp.nil?
        puts "#ERREUR Variable #{search.inspect} mal définie".rouge
        puts "Chaine à transformer : #{str.inspect}".rouge
        puts "Ligne #{line_idx} absente dans :".rouge
        puts "#{blocode.lines_code.inspect}".rouge
        opts = options.dup
        opts.delete(:definitions_globales)
        opts.delete(:definitions_locales)
        opts.delete(:music_score)
        puts "Options : #{opts.inspect}".rouge
        raise "La définition de #{search.inspect} devrait définir la ligne #{line_idx +1}"
      else
        raise "La définition de #{search.inspect} n'est pas conforme…"
      end
    end
    # puts "remp = #{remp.inspect}"
    str = remplace_variable_in_string(str, search, remp)
  end

  str = str.strip

  # puts "STR final : #{str.inspect}"

  return str
end #/traite_definitions_in

def remplace_variable_in_string(str, var, remp)
  # 2 fois car elles peuvent se "toucher" (en comptant 
  # l’espace cherché)
  2.times do
    str = str.gsub(/ #{Regexp.escape(var)}(?<mark_hauteur>[,']+)?(?:\*(?<nombre_fois>[0-9]+))? /) do 
      hauteur = $~[:mark_hauteur]
      nb_fois = $~[:nombre_fois].to_i
      nb_fois = 1 if nb_fois < 1
      hauteur = "'#{hauteur}".gsub(/(',|,')/,'')
      # puts "Nombre x : #{nb_fois.inspect}".bleu
      # puts "Hauteur finale  : #{hauteur}".bleu
      " \\relative c#{hauteur} { #{remp} } " * nb_fois
    end
  end
  return str
  # Initialement :
  # str = str.gsub(/ #{search} /, " \\relative c' { #{remp} } ")
  #          .gsub(/ #{search} /, " \\relative c' { #{remp} } ")
end


end #/BlockCode
end #/Parser
end #/MusicScore
