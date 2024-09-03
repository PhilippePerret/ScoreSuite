# encoding: UTF-8
# frozen_string_literal: true
=begin

  MusicScore::Output
  ------------------
  La classe de la sortie du programme, principalement des fichiers 
  produits. Un output-file définit le fichier .ly, le fichier 
  -trimed.ly, le fichier svg.

=end
class MusicScore
class Output

# --- CLASSE ---
class << self
  def new_score_index
    @last_index ||= 0
    (@last_index += 1).to_s.rjust(3,'0')
  end
end #/<< self

# --- INSTANCE ---

#
# {MusicScore::BlockCode} Données du fichier
# -------------------------------------------
# Fournies à l'instanciation
#
attr_reader :data

##
# Instanciation de l'output-files
#
def initialize(bloccode)
  @data = bloccode
end

##
# Méthode appelée de l'extérieur pour savoir s'il faut construire
# l'image. Cela dépend de l'option 'only_new' et de l'existence du
# fichier final (qui peut avoir un indice ou non)
#
def build_if_required
  dest1 = File.join(dest_folder, "#{image_name}.svg")
  dest2 = File.join(dest_folder, "#{image_name}-1.svg")
  if data.options['only_new'] && (File.exist?(dest1)||File.exist?(dest2))
    puts "L'image #{image_name}" if verbose?
    return
  end
  build
end

##
# = main =
#
# Méthode principale de construction de l'image SVG (pour l'instant
# le programme ne sort que ça)
# 
# Note : data.music_score contient l'instance MusicScore concernée.
#
def build

  # 
  # Chaque ligne de code doit être traduite en pur Lilypond
  #
  STDOUT.write "⚙️  Parsing du code MUS pour l'image #{relpath_image}".bleu
  codes = data.lines_code.map do |line_code|
    # puts "Je dois traduire : #{line_code.inspect}"
    Lilypond.translate_from_music_score(line_code, data.options)
  end
  puts "\r🎼 Code parsé.#{' '*60}".vert


  # puts "Codes obtenus :\n#{codes.inspect}"

  # Quand le fichier MIDI est requis en plus du fichier normal
  # Noter que cela n’arrive que si le code MUS contient l’option
  # ’--midi’. Car si c’est une option en ligne de commande, avec par
  # exemple ’score-image -midi’, seul le fichier MIDI est produit et
  # c’est alors l’appelle Lilypond.compose suivant qui s’en charge
  if data.options['midi']
    STDOUT.write "⚙️  Création du fichier MIDI".bleu
    produce_midi_file(codes)
    puts "\r🎹 Fichier MIDI produit avec succès#{' '*60}".vert
  end

  unless data.music_score.options[:only_stats]
    STDOUT.write "⚙️  Production de l'image #{relpath_image}".bleu
    verbose? && puts("Dans : #{image_name}.svg".gris)
  end

  # On compose le code LilyPond et on le met dans son fichier
  compose_and_save_code_lilypond(codes)

  if data.music_score.options[:only_stats]
    puts "Je dois m'arrêter (seulement statistiques)".jaune if verbose?
    return false
  end

  #
  # Production par lily2svg de ou des images non trimées
  # (sauf si c’est le fichier MIDI seulement qui est demandé)
  build_svg_files

  allright = not(@resultat_travail_lilypond.match?('error'))
  # puts "allright: #{allright.inspect}".bleu

  if not(@resultat_travail_lilypond.empty?)
    # @note : Ça servira notamment à ScoreBuilder pour récupérer le
    # message d’erreur.
    puts "@resultat_travail_lilypond:\n#{@resultat_travail_lilypond}"
  end

  ok_files_trimed = CLI.option(:midi) || trim_all_files

  # Rabottement de toutes les images produites pour ce score
  #
  if allright && ok_files_trimed
    delete_untrimed_files unless data.options['keep']
    msg = 
      if CLI.option(:midi)
        rename_midi_file
        "\r🎹 Le fichier MIDI a été produit avec succès."
      else
        "\r🎹 L'image #{relpath_image} a été produite avec succès."
      end
    puts msg.vert
  else
    raise EMusicScore.new("Impossible de produire l'image finale…")
  end

end


def compose_and_save_code_lilypond(codes)

  # Si on veut produire le fichier midi
  Lilypond.set_midi(true) if CLI.option(:midi)

  # On compose le code Lilypond final pour le mettre dans son fichier
  #
  lilypond_code = Lilypond.compose(codes, data.options.merge(system: systeme))
  # puts "Lilypond Code : #{'x'*50}\n#{lilypond_code}\n#{'x'*50}"

  # On met le code final dans son fichier
  #
  File.delete(lilypond_file_path) if File.exist?(lilypond_file_path)
  File.open(lilypond_file_path,'wb'){|f|f.write lilypond_code}  
end

# Pour produire le fichier MIDI
def produce_midi_file(codes)
  Lilypond.set_midi(true)
  # On détruit le fichier MIDI qui existe peut-être pour s’assurer
  # qu’il a été créé/actualisé
  File.delete(midi_file_path) if File.exist?(midi_file_path)
  compose_and_save_code_lilypond(codes)

  # TODO Ici on pourrait faire une copie du fichier .ly produit, pour
  # pouvoir vérifier en cas d’erreur

  # - Production du fichier MIDI -
  cmd = 'cd "%s" && lilypond --loglevel=ERROR "%s" 2>&1'.freeze % [dest_folder, lilypond_file_name]
  res = `#{cmd}`
  unless res.empty?
    raise "Problème lors de la production du fichier MIDI : #{res}"
  end
  if File.exist?(midi_file_path)
    rename_midi_file
  else
    raise "Le fichier MIDI n’a pas pu être créé, pour une raison inconnue."
  end
  Lilypond.set_midi(false)
end

# Le nom original du fichier midi est "<nom image>-untrimed.midi", il
# faut le renommer en "<nom image>.midi"
def rename_midi_file
  dst_path = File.join(folder, affixe, "#{image_name}.midi")
  FileUtils.mv(midi_file_path, dst_path)
end

def delete_untrimed_files
  Dir["#{dest_folder}/*-untrimed.ly"].each{|p|File.delete(p)}
end

def relpath_image
  @relpath_image ||= "#{folder_name}/#{affixe}/#{image_name}.svg".freeze
end

# Production par lily2svg de l'image non trimée
def build_svg_files
  # cmd  = '/Applications/LilyPond.app/Contents/Resources/bin/lilypond'
  cmd  = "lilypond"
  opts = ['--loglevel=ERROR', '-dbackend=svg']
  # Pour ne pas ajouter les liens de "pointer-cliquer"
  opts << '-dno-point-and-click'.freeze
  # opts << '-dclip-systems' # seulement un extrait de la partition (mais ça ne fonctionne pas encore)
  opts = opts.join(' ')
  res = `cd "#{dest_folder}" && #{cmd} #{opts} "#{lilypond_file_name}" 2>&1`
  @resultat_travail_lilypond = res
end

# Rabbotement des images produites pour la partition
def trim_all_files
  raise EMusicScore.new('Aucun fichier image n’a été produit…') if svg_untrimed_files.count == 0
  svg_untrimed_files.each do |svg_untrimed_file|
    if trim_file(svg_untrimed_file) === false
      raise EMusicScore.new("Impossible de trimer le fichier #{svg_untrimed_file.inspect}…")
    end
  end

  return true
end

def trim_file(svg_path)
  dest_name = File.basename(svg_path).sub(/\-untrimed/,'')
  svg_dest_file = File.join(dest_folder,dest_name)
  cmd   = '/Applications/Inkscape.app/Contents/MacOS/inkscape'
  opts  = '-l -D'
  res = `#{cmd} #{opts} -o "#{svg_dest_file}" "#{svg_path}"`
  if File.exist?(svg_dest_file)
    File.delete(svg_path)
  else
    return false
  end
end

def systeme
  @systeme ||= begin
    if data.options['piano']
      'piano'
    elsif data.options['quatuor']
      'quatuor'
    elsif data.options['staves']
      data.options['staves'].to_i
    elsif data.options['staves_names']
      data.options['staves_names'].split(',').count
    elsif data.options['staves_keys']
      data.options['staves_keys'].split(',').count
    else
      'solo'
    end
  end
end


# @return {Array of Files} La liste de toutes les images produites
# par Lilypond pour faire l'image finale.
#
def svg_untrimed_files
  Dir["#{dest_folder}/*-untrimed*.svg"].collect do |path|
    path
  end.sort_by do |fpath|
    File.basename(fpath)
  end
end


# --- Les paths ---

#
# @return le nom de l'image
#
# Soit elle est définie dans le code ('-> image_name') soit il faut
# la déduire du fichier courant. L'affixe par défaut d'une image est
# '<nom du fichier>-score-<index>'
#
def image_name
  @image_name ||= data.image_name || begin
    if data.options[:music_score].mus_file
      "#{data.options[:music_score].mus_file.affixe}-score-#{self.class.new_score_index}"
    else
      "score-#{Time.now.to_i}"
    end
  end
end

def affixe
  @affixe ||= begin
    if data.options[:music_score].mus_file
      data.options[:music_score].mus_file.affixe
    else
      'scores'
    end
  end
end

# Le fichier SVG résultant de la transformation par Lilypond
def svg_untrimed_path
  @svg_untrimed_path ||= File.join(dest_folder, "#{image_name}-untrimed.svg")
end

# Le fichier contenant le code Lilypond
def lilypond_file_path
  @lilypond_file_path ||= File.join(dest_folder, lilypond_file_name)
end

def lilypond_file_name
  @lilypond_file_name ||= "#{image_name}-untrimed.ly"
end

def midi_file_path
  @midi_file_path ||= File.join(dest_folder, midi_file_name)
end
def midi_file_name
  @midi_file_name ||= "#{image_name}-untrimed.midi"
end

def dest_folder
  @dest_folder ||= mkdir(File.join(folder, affixe))
end

def folder_name
  @folder_name ||= File.basename(folder).freeze
end

def folder
  @folder ||= begin
    if data.options[:music_score].mus_file
      File.expand_path(data.options[:music_score].mus_file.folder)
    else
      CUR_DIR
    end
  end
end


end #/Output
end #/MusicScore
