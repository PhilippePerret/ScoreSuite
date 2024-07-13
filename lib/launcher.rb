# encoding: UTF-8

# #
# L’idée derrière ce launcher (lanceur d’application) est de pouvoir
# utiliser la "puissance" de Bundler en passant d’une application
# de la Score Suite à une autre. Par exemple, Score-Builder doit être
# capable de lancer Score-Image pour construire l’image.
# Une application extérieur (comme Rpsm par exemple) doit aussi être
# capable de lancer une application. Rpsm doit pouvoir lancer 
# Score-Builder pour lancer la construction de la partition d’une 
# pièce.
# 
# Au-delà du lancerment, je veux pouvoir gérer correctement les 
# erreurs et autres messages envoyés par l’application en question.
# C’est la raison pour laquelle j’utilise Open3.capture3.
# 
# Requis :
#   - que l’application utilise Bundler
#   - qu’on connaisse le fonctionnement de l’application au niveau
#     des arguments qu’elle attend. Cette partie n’est pas très 
#     précise.
#   - il faut être plus clair aussi pour savoir où il faut lancer
#     l’application. Le faire dans le dossier de l’élément construit
#     ou le faire "n’importe où" ?
# 
# 
# 
require 'open3'
module Launcher
class << self
  
  # ATTENTION : Ne pas se méprendre sur le nom : dans tous les cas,
  # l’application +app_id+ sera appelée avec et par bundle. Ici, 
  # le "without_bundler" veut juste dire que l’application qui 
  # appelle cette méthode n’est pas sous bundler, elle.
  def launch_without_bundler(app_id, args = nil, params = nil)
    params ||= {}
    params.merge!(with_bundler: false)
    launch(app_id, args, params)
  end

  def launch(app_id, args = nil, params = nil)

    # Paramètres par défaut
    params ||= {}
    params.key?(:with_bundler) || params.merge!(with_bundler: true)

    # Arguments par défaut
    args ||= []

    # Instance de l’application
    app = App.new(app_id)

    command = APP_COMMAND % [app.folder, app.script]
    command = [command, *args].join(' ')

    # - Dossier courant -
    # S’il n’est pa défini, on le met toujours en variable d’environ-
    # nement pour le connaitre partout. On ne peut plus utiliser 
    # ENV['PWD'] ou ’.’ car la commande ’bundle exec’ demande de re-
    # joindre le dossier contenant le script à jouer (on pourrait 
    # aussi utiliser une variable environnementale pour définir le 
    # gemfile…).
    # Noter qu’il ne faut le faire que lorsqu’il n’est pas défini,
    # car si on appelle une app qui appelle une autre app, le dossier
    # courant ’.’ est celui de la première app, appelée par cette
    # méthode (ce launcher).
    unless ENV['CUR_DIR']
      cur_dir = params[:in] || File.expand_path('.')
      env = {
        'CUR_DIR'         => cur_dir,
        'CURRENT_FOLDER'  => cur_dir
      }
      command = [env, command]
    end

    # theproc = Proc.new do
    #   stdout, stderr, status = Open3.capture3(*command)
    #   if status.success?
    #     puts "#{app.name} s’est exécutée avec succès."
    #     puts "Sortie normale :\n#{stdout}"
    #   else
    #     puts "#{app.name} a échoué."
    #     puts "Erreur en sortie :\n#{stderr}"
    #   end
    # end

    # Pour faire l’essai
    script = <<~RUBY
    10.times do |itime|
      puts "Répétition \#{itime}"
      sleep 1
    end
    RUBY


    theproc = Proc.new do 
      Open3.popen3(*command) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        pid = wait_thr.pid


        # Lit les sorties standard du processus de manière asynchrone
        Thread.new do
          stdout.each_line do |line|
            puts "Sortie standard : #{line}"
          end
        end

        # Lit les sorties d'erreur du processus de manière asynchrone
        Thread.new do
          stderr.each_line do |line|
            puts "Sortie d'erreur : #{line}"
          end
        end

        exit_status = wait_thr.value
        puts "Statut de sortie : #{exit_status}"
      end
    end


    # theproc = Proc.new do 
    #   Open3.popen3(*command) do |stdin, stdout, stderr, wait_thr|
    #     pid = wait_thr.pid

    #     # stdin.close

    #     # Lit les sorties standard du processus de manière asynchrone
    #     Thread.new do
    #       stdout.each_line do |line|
    #         puts "Sortie standard : #{line}"
    #       end
    #     end

    #     # Lit les sorties d'erreur du processus de manière asynchrone
    #     Thread.new do
    #       stderr.each_line do |line|
    #         puts "Sortie d'erreur : #{line}"
    #       end
    #     end

    #     exit_status = wait_thr.value
    #     puts "Statut de sortie : #{exit_status}"
    #   end
    # end



    if params[:with_bundler]
      proceed_with_bundler(theproc)
    else
      proceed_without_bundler(theproc)
    end

  end #/#launch


def all_eof(files)
  files.find { |f| !f.eof }.nil?
end

  def proceed_with_bundler(theproc)
    Bundler.with_unbundled_env do
      theproc.call
    end
  end

  def proceed_without_bundler(theproc)
    theproc.call
  end

end # << self

class App
  attr_reader :id
  def initialize(app_id)
    @id = app_id
  end
  def script
    @script ||= (data[:script]||"#{id}.rb").freeze
  end
  def folder
    @folder ||= File.expand_path(File.join(__dir__,'..',folder_name))
  end
  def folder_name
    @folder_name ||= data[:folder_name].freeze
  end
  alias :name :folder_name
  def data
    @data ||= DATA_APPS[id]
  end
end #/class App

  DATA_APPS = {
    score_image: {
      folder_name: 'ScoreImage'.freeze,
    },
    score_builder: {
      folder_name: 'ScoreBuilder'.freeze
    },
    score_cutting: {
      folder_name: 'ScoreCutting'.freeze
    },
    score_numbering:{
      folder_name: 'ScoreNumbering'.freeze
    },
  }

  APP_COMMAND = 'cd %s && bundle exec ruby %s'.freeze

end #/ module Launcher
