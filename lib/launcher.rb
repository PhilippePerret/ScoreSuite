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
module ScoreSuiteLauncher
class << self
  

  def launch(app_id, args_ini = nil, params = nil)

    # Même si ce n’est pas recommandé, ça peut être ARGV qui a été
    # envoyé, il faut en faire une vraie liste, sinon on aura un
    # problème plus bas.
    args = args_ini.dup || []

    # puts "args: #{args.inspect}::#{args.class}"
    # puts "ARGV: #{ARGV.inspect}::#{ARGV.class}"
    # 

    # Paramètres par défaut
    params ||= {}
    params.key?(:with_bundler) || params.merge!(with_bundler: true)

    # Arguments
    args = [args] unless args.is_a?(Array)
    ARGV.each { |arg| args << arg }
    args = args.uniq

    # Instance de l’application
    app = App.new(app_id)

    command = APP_COMMAND % [app.folder, app.script]
    # command = "#{command} #{args.join(' ')}".strip
    command = [command, *args].join(' ')

    env = {}

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
      env.merge!(
        'CUR_DIR'         => cur_dir,
        'CURRENT_FOLDER'  => cur_dir,
        'SCORE_SUITE_INTERACTIVITY' => 'null'
      )
    end

    # Rediriger les sorties du sous-processus vers la
    # sortie standard du processus courant. C’est-à-dire qu’un puts
    # dans le sous-processus s’écrira dans le processus principal
    options = {
      out: STDOUT,
      err: STDERR,
    }


    # puts "Je lance la commande : #{command}."
    Process.spawn(env, command, options)
    # puts "J’attends la fin"
    Process.wait

  end # /#launch

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

end #/ module ScoreSuiteLauncher
