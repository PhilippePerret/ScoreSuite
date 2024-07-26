#
# Module pour gérer les tests.
# 
# On appelle la méthode d’entrée #run avec ’score-image tests’
# 

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
    # puts "Je joue les tests…".jaune

    clear;clear
    case (subcommand ||= CLI.components[0])
    when :stop
      return
    when '_', 'run'
      run_tests(folder: CLI.options[:dir])
    when /^\/(.+)\/$/
      run_tests({filter: eval(subcommand).freeze, folder: CLI.options[:dir]})
    when 'create'
      require_relative 'test_create'
      create_test
    else
      if CLI.options[:dir]
        run_tests(folder: CLI.options[:dir])
      else
        puts <<~TEXT
        Pour lancer directement les tests : 
            #{'score-image tests _'.jaune}
        Pour filtrer les tests par expression régulière :
            #{'score-image tests /<expression>/'.jaune}
        Pour jouer tous les tests d’un dossier
            #{'score-image tests -dir=relpath/to/dir'.jaune}
        Pour jouer les tests d’un dossier en les filtrant
            #{'score-image tests /<expression>/ -dir=relpath/to/dir'.jaune}
        TEXT
        run(choose_what_to_do)
      end
    end
  end

  def run_tests(params = nil)
    require_relative 'tests_runner'
    run_tests_proceed(params)
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
