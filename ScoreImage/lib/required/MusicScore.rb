# encoding: UTF-8
# frozen_string_literal: true
=begin

  MusicScore 
  ------------
  La classe principale

=end
class MusicScore
class << self
  attr_accessor :options
  def init
    @options = {
      verbose: false
    }
  end

  # = entry =
  # = main  =
  # 
  # Point d’entrée de l’application, en mode normal.
  #  
  # @param params [Hash]
  #   :input_code     Le code tel qu’il est envoyé en heredoc
  #   :path           Le chemin d’accès à un fichier de code
  #   :can_open       Si true, on demande s’il faut ouvrir le dossier
  #                   de l’image finale. (inauguré pour l’utilise de
  #                   la commande avec un heredoc, donc ne fonctionne
  #                   qu’avec le heredoc pour le moment)
  def run(params = nil)
    init
    mscore = MusicScore.new
    mscore.proceed(params)
    if params[:can_open] && CLI.option(:open)
      # mscore.open
      if mscore.mus_file
        puts "mscore.mus_file: #{mscore.mus_file}"
      else
        puts "Le music score n’a pas de mus_file, j’ouvre le dossier courant".jaune
        `open -a Finder "#{CUR_DIR}/scores"`
      end
    end
  end

  def open_manual
    ext = CLI.option(:dev) ? 'md' : 'pdf'
    pth = File.expand_path(File.join(APP_FOLDER,'Manuel','Manuel_code_MUS.%s'.freeze % ext))
    `open "#{pth}"`
  end

  def verbose?
    options[:verbose]
  end
end #/<< self

# --- INSTANCE ---

#
# Les options générales (de la ligne de commande)
#
attr_reader :options

#
# L'expression fournie. C'est toujours le code.
#
attr_reader :expression

#
# {MusFile} Le chemin d'accès au fichier .mus, si c'est un fichier
# qui a été fourni.
# 
attr_reader :mus_file

#
# Le parser
#
# Il contient notamment :options et :all_blocks qui contient tous
# les blocs qui vont produire autant d'images.
#
attr_reader :parser

##
# = main =
#
# Point d'entrée du programme
#
# La méthode analyse les arguments fournis pour en tirer les 
# conclusion sur le code à analyser et les options à garder.
#
# La méthode peut être appelée avec :options et :expression.
#
def proceed(params = nil)

  #
  # Parse de la ligne de commande ou application
  # des paramètres fournis
  # 
  set_params(params)

  self.class.options.merge!(options)


  # Débug
  debug_self_attributes if verbose?

  #
  # Analyse de l'expression fournie (elle peut être longue)
  #
  parse_expression

  if verbose?
    puts "CODE FINAL: \n#{parser.all_blocks.map{|bc|bc.lines_code.inspect}.join("\n")}"
  end


  #
  # À chaque "bloc de code" obtenu correspond une "sortie", qui est
  # la plupart du temps une image.
  # On l'instancie et on la construit.
  # 
  parser.all_blocks.each do |bloccode|
    ms_image = Output.new(bloccode)
    ms_image.build_if_required
  end

end

def set_params(params = nil)
  #
  # Parse de la ligne de commande if any
  #
  if params.nil?
    parse_command_line
  elsif params.key?(:input_code)
    parse_command_line # défini @expression, mais sera écrasé
    @expression = params[:input_code]
  else
    @options    = params[:options]||{}
    @mus_file   = MusFile.new(params[:path])
    @expression = @mus_file.ms_code
  end 
end

##
# Analyse de la ligne de commande fournie. Elle peut contenir :
#   - des options (-/--)
#   - du code music-score
#     OU Le chemin d'accès au fichier .mus à traiter.
#
def parse_command_line
  @options = {}
  exp = []
  ARGV.each do |argv|
    puts "Traitement de l'argument #{argv.inspect}" if verbose?
    if argv.start_with?('-')
      # 
      # <= L'argument commence par un '-'
      # => C'est forcément une option (longue ou courte ?)
      #
      if argv.start_with?('--')
        argv, valu = parse_cline_element(argv[2..-1])
      elsif argv.start_with?('-')
        argv, valu = parse_cline_element(argv[1..-1])
        argv = SHORT_OPTION_TO_LONG[argv.to_sym] || raise("L'option -#{argv.inspect} n'est pas définie…")
      end
      # puts "OPT: #{argv.inspect} => #{valu.inspect}"
      @options.merge!(argv.to_sym => valu)
    else
      #
      # Soit le code, soit une expression pseudo-lilypond (donc une
      # expression music-score)
      #
      exp << argv
    end
  end
  exp = exp.join(' ')

  #
  # Analyse de l'expression pour savoir si c'est un chemin d'accès
  # ou du code music-score.
  #
  # Attention : comme le code n'est pas toujours évalué dans ce
  # dossier, un chemin relatif ("./...") ne sera pas forcément trouvé
  #
  if File.exist?(exp) || exp.start_with?('./')
    @mus_file   = MusFile.new(exp)
    @expression = @mus_file.ms_code
  else
    @expression = exp
  end
end
#/parse_command_line

def parse_cline_element(argv)
  if argv.match?('=')
    argv, valu = argv.split('=') 
  else
    valu = true
  end
  return [argv, valu]  
end

##
# Instancie un parser pour parser l'expression fournie et parse le
# code (l'expression)
#
def parse_expression
  @parser = Parser.new(self)
  @parser.parse
end

# --- options ---

def verbose?
  @options[:verbose]
end


private


  #
  # Simplement pour débugger les valeurs si on ajoute -v à la ligne
  # de commandes
  #
  def debug_self_attributes
    puts "Options:    #{options.inspect}".mauve
    puts "Expresion : #{expression.inspect}".mauve
    puts "Fichier   : #{mus_file.inspect}".mauve  
  end

end #/MusicScore
