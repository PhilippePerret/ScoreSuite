# encoding: UTF-8
# frozen_string_literal: true
=begin

  Classe MusicScore::MusFile
  --------------------------
  Classe utilisée lorsqu'un fichier .mus est donné en expression de
  la ligne de commande (ou passé par argument à MusicScore.produce)

=end
class MusicScore
class MusFile

attr_reader :raw_path
attr_reader :full_path

##
# Instanciation
#
# @param  raw_path {String}
#         Le chemin d'accès relatif ou absolu tel qu'il est fourni
#         par la ligne de commande.
#
def initialize(raw_path)
  @raw_path = raw_path
  parse_path
  require_ruby_modules
end

# Charge les fichier ruby s’ils existent et étend la classe lilypond
def require_ruby_modules
  Dir["#{folder}/**/*.rb"].each { |m| require(m) }
  if defined?(ScoreImage)
    MusicScore::Parser.include(ScoreImage)
  end
end

##
# Retourne le contenu du fichier, tel quel.
#
def ms_code
  @ms_code ||= File.read(full_path).force_encoding('utf-8')
end

##
# Analyse le chemin d'accès fourni pour en tirer le path complet
#
def parse_path
  fpath = 
    if raw_path.start_with?('./')
      File.expand_path(File.join(current_folder, raw_path))
    else
      raw_path
    end
  #
  # Ajout de l'extension si nécessaire
  #
  fpath = "#{fpath}.mus" unless fpath.end_with?('.mus')
  #
  # Vérification de l'existence
  #
  unless File.exist?(fpath)
    raise EMusicScore.new("Le fichier #{fpath.inspect} est introuvable…")
  end

  @full_path = fpath
end

# def current_folder
#   @current_folder ||= ENV['PWD']
# end

def fname
  @fname ||= File.basename(full_path)
end

def folder
  @folder ||= File.dirname(full_path)
end
def affixe
  @affixe ||= File.basename(full_path, File.extname(full_path))
end

end #/MusFile
end #/MusicScore
