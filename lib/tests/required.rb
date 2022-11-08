# encoding: UTF-8
=begin

  Pour requérir les éléments communs des tests (MiniTest)

  @usage

    Dans un fichier './tests/required.rb' de l'application à tester,
    ajouter :
      require_relative '../../lib/tests/required'
    Si le fichier doit être dans un autre emplacement, adapter les
    '../'

=end
require_relative '../required' # les librairies communes
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
