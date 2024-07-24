#
# Module pour gérer les tests.
# Ce patch lance les tests (en les filtrant si nécessaire)
# 
require 'digest'
require_relative 'MusFile'
class TestErreur < StandardError; end


module ScoreImage
class Test
POINT_SUCCESS  = '.'.vert.freeze
POINT_FAILURE = '.'.rouge.freeze
POINT_PENDING  = '.'.gris.freeze
class << self

  # Pour les résultats
  attr_reader :success_tests, :failures_tests, :pendings_tests

  def run_tests_proceed(params)
    clear;clear
    reset
    display_table_options
    must_fail_fast = CLI.options[:fail_fast]
    tests_list(params).each_with_index do |musfile, idx|
      musfile.indice = idx + 1
      ###########################
      ###    APPEL DU TEST    ###
      ###########################
      musfile.test
      
      point = 
        if musfile.success?
          success_tests << musfile
          POINT_SUCCESS
        elsif musfile.failure?
          failures_tests << musfile
          POINT_FAILURE
        else
          pendings_tests << musfile
          POINT_PENDING
        end
      STDOUT.write point

      # Si on doit s’arrêter au premier problème
      break if musfile.failure? && must_fail_fast

    end
    report
  end

  # Affiche le rapport final
  def report
    color = failures_tests.empty? ? :vert : :rouge
    color_pendings = pendings_tests.empty? ? color : :orange

    puts "\n\n"

    # En mode verbeux, on affiche la liste des succès et des
    # pending.
    if verbose?

      success_tests.each_with_index do |musfile, idx|
        puts "[#{idx + 1}] #{musfile.relpath} est conforme aux attentes.".vert
      end
    
      if pendings_tests.count > 0
        puts "\nPendings\n#{'-'*8}".orange
        pendings_tests.each_with_index do |musfile,idx|
          puts "[#{idx + 1}] Pending #{musfile.relpath}".orange
        end
      end

    end

    # Liste des erreurs rencontrées
    failures_tests.each_with_index do |musfile, idx|
      puts "[#{idx + 1}] #{musfile.error}".rouge
    end

    msg = "Success: #{success_tests.count} Failures: #{failures_tests.count} #{"Pendings: #{pendings_tests.count}".send(color_pendings)}"
    puts "\n#{'-'*40}\n#{msg}".send(color)
  end


  # @return [Array<String>] La liste des fichiers tests filtrée
  # 
  def tests_list(params)
    params ||= {}
    filter    = params[:filter]
    in_folder = params[:folder]
    base_folder = tests_folder
    base_folder = File.join(base_folder, in_folder) if in_folder
    all_mus = Dir["#{base_folder}/**/*.mus"].map{|pth|MusFile.new(pth)}
    return all_mus if filter.nil?
    # S’il y a un filtre
    all_mus.select do |musfile|
      musfile.pass_filter?(filter)
    end
  end

  def display_table_options
    puts <<~TEXT.gris
    Options :
      -v    Mode verbeux (affiche notamment la liste des images
            conformes)
      
      -ff   Mode "fail-fast". S’arrête à la première erreur.
      
      -dir=<path>
            Pour réduire au dossier de test dans checksum_tests/  

    TEXT
  end


  def reset
    @success_tests  = []
    @failures_tests = []
    @pendings_tests = []
  end

end #/<< self class
end #/class Test
end #/module ScoreImage
