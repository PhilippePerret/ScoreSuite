#!/usr/bin/env ruby
# encoding: UTF-8
=begin

  Obtenir les statistiques d'une partition consiste simplement à 
  appeler le programme 'ScoreImage' en demandant à ne produire 
  que les statistiques.

  Si l'user n'a pas défini le tempo, on le cherche dans un fichier
  de données, ou on le demande.

=end


require_relative 'lib/required'

# Commande
COMMAND_SCORE_IMAGE = File.join(Dir.home,'Programmes','ScoreSuite','ScoreImage','score_image.rb')


def ask_for_filename
  current_filenames = Dir["#{CURRENT_FOLDER}/*.mus"].map do |f|
    fname = File.basename(f)
    {name: fname, value: fname }
  end
  if current_filenames.empty?
    raise "Aucune fichier .mus n'a été trouvé dans le dossier courant… (#{CURRENT_FOLDER})"
  elsif current_filenames.count == 1
    current_filenames.first[:value]
  else
    Q.select('Fichier .mus à utiliser : '.jaune, current_filenames, per_page: current_filenames.count)
  end
end

def ask_for_tempo
  Q.ask("Tempo de la pièce (pour connaitre les temps d'utilisation de chaque note). Ajouter 'T' pour rythme ternaire.".jaune, default: '60')
end

begin

  #
  # Les options éventuelles
  # (on définit le tempo)
  # 
  options = {}

  #
  # Le nom du fichier .mus
  # 
  filename = nil

  # 
  # On parse la ligne de commande
  # 
  ARGV.each do |arg|
    if arg.start_with?('-')
      arg, val = arg.split('=') if arg.match?('=')
      case arg
      when '-t', '--tempo' then options[:tempo] = val.to_i
      end
    elsif filename.nil?
      filename = arg
    else
      raise "Je ne sais pas quoi faire de l'argument #{arg.inspect}."
    end
  end

  filename ||= ask_for_filename

  # 
  # Le tempo (fourni ou demandé)
  # 
  options[:tempo] ||= ask_for_tempo

  # On s'assure que le score image existe
  File.exist?(COMMAND_SCORE_IMAGE) || raise("Le fichier '#{COMMAND_SCORE_IMAGE}' est introuvable…")

  FILE_MUS_NAME   = filename
  FILE_MUS_AFFIXE = File.basename(filename, File.extname(filename))
  FILE_MUS_PATH   = File.join(CURRENT_FOLDER, FILE_MUS_NAME)
  FILE_MUS_FOLDER = File.dirname(FILE_MUS_PATH)

  MUS_SVG_FOLDER  = File.join(FILE_MUS_FOLDER, FILE_MUS_AFFIXE)
  folder_existe_deja = File.exist?(MUS_SVG_FOLDER)

  cmd = "cd \"#{File.dirname(FILE_MUS_PATH)}\" && #{COMMAND_SCORE_IMAGE} ./#{FILE_MUS_NAME} --stats --only_stats -t=#{options[:tempo]}"

  res = `#{cmd} 2>&1`
  
  if res != ''
    raise "Un problème est survenu : #{res.inspect}"
  end

  unless folder_existe_deja
    # Puisque le dossier a été créé pour ces statistiques, on le détruit.
    # Sinon, s'il existait, on le garde.
    FileUtils.rm_rf(MUS_SVG_FOLDER)
  end

  # 
  # Confirmation finale
  # 
  puts "Les statistiques de '#{FILE_MUS_AFFIXE}' ont été produites avec succès\ndans le dossier #{FILE_MUS_FOLDER}.\n\n".vert

rescue Exception => e

  puts e.message.rouge
  puts e.backtrace.join("\n").rouge

ensure


end
