#
# Module pour gérer les tests.
# 
# On appelle la méthode d’entrée #run avec ’score-image tests’
# 
require 'clir'
require 'precedences'

SHORT_OPTION_TO_LONG = {
  'f' => :fail_fast,
  'ff' => :fail_fast,
}

module ScoreImage
class Test
class << self
  # = entry =
  # = main  =
  # 
  # Méthode d’entrée de l’application (’score-image tests’)
  def run(subcommand = nil)
    clear;clear
    case (subcommand ||= CLI.components[0])
    when :stop
      return
    when '_', 'run'
      run_tests
    when /^\/(.+)\/$/
      run_tests(eval(subcommand).freeze)
    when 'create'
      require_relative 'test_create'
      create_test
    else
      puts <<~TEXT
      Pour lancer directement les tests : 
          #{'score-image tests _'.jaune}
      Pour filtrer les tests par expression régulière :
          #{'score-image tests /<expression>/'.jaune}

          
      TEXT
      run(choose_what_to_do)
    end
  end

  def run_tests(filter = nil)
    require_relative 'tests_runner'
    run_tests_proceed(filter)
  end


  def tests_folder
    @tests_folder ||= File.join(MusicScore::APP_FOLDER,'tests','checksums_tests')
  end

  private


    def choose_what_to_do
      choices = [
        {name: "Jouer tous les tests" , value:'run'},
        {name: "Créer un nouveau test", value:'create'},
      ]
      precedencize(choices, './tests') do |q|
        q.question "Que faut-il faire ?"
        q.add_choice "Renoncer".orange, :stop
      end
    end

end #/<< self class
end #/class Test
end #/module ScoreImage
