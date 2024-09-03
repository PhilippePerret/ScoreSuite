#
# Module pour gérer les tests.
# Ce patch lance les tests (en les filtrant si nécessaire)
# 
require 'digest'
require_relative 'MusFile'
require_relative 'ExtraTests'
require_relative 'ExtraFile'
require_relative 'ReportFile'
class TestErreur < StandardError; end


module ScoreImage
class Test
POINT_SUCCESS  = '.'.vert.freeze
POINT_FAILURE = '.'.rouge.freeze
POINT_PENDING  = '.'.gris.freeze
class << self

  # Pour les résultats
  attr_reader :success_tests, :failures_tests, :pendings_tests

  attr_reader :report_file

  def run_tests_proceed(params)
    clear;clear
    reset(params)
    display_table_options
    must_fail_fast = CLI.option(:fail_fast)||CLI.option(:ff)
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

  def last_tests?
    CLI.option(:lasts) || CLI.option(:last)
  end
  def only_last?
    CLI.option(:last)
  end
  def only_failures?
    CLI.option(:only_failures)
  end

  # Affiche le rapport final
  def report

    report_file.stop

    color = failures_tests.empty? ? :vert : :rouge
    color_pendings = pendings_tests.empty? ? color : :orange

    puts "\n\n"

    # En mode verbeux, on affiche la liste des succès et des
    # pending.
    if verbose?

      success_tests.each_with_index do |musfile, idx|
        puts "[#{idx + 1}] #{musfile.relative_path} est conforme aux attentes.".vert
      end
    
      if pendings_tests.count > 0
        puts "\nPendings\n#{'-'*8}".orange
        pendings_tests.each_with_index do |musfile,idx|
          puts "[#{idx + 1}] Pending #{musfile.relative_path}".orange
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
  # Suivant les options, la liste peut être différente :
  #   - avec l’option -dir et un filtre, on choisit les tests dans
  #     le dossier, avec le filtre
  #   - avec l’option --lasts, on joue les derniers tests
  #   - avec l’option --last, on ne joue que le dernier test
  #   - avec l’optino --only_failures, on ne joue que les derniers
  #     échecs
  # 
  def tests_list(params)
    params ||= {}
    report_file.load # s’il existe

    cli_options = CLI.options.dup
    if only_failures? || last_tests?
      if report_file.exist?
        cli_options.merge!(report_file.data[:options])
      end
    end

    if only_failures?
      if report_file.exist?
        last_failures = report_file.data[:failures]
        if last_failures.empty?
          puts "Il n’y a eu aucun échec lors des derniers tests.".orange
        end
        return last_failures
      else
        puts "Aucun test n’a encore été lancé."
        return []
      end
    end

    filter = in_folder = nil
    if last_tests?
      # S’il faut rejouer les derniers tests
      if report_file.exist?
        params = report_file.data[:params]
      else
        puts "Aucun test n’a encore été lancé.".orange
      end
    end
    filter    ||= params[:filter]
    in_folder ||= params[:folder]

    header = "Filter: #{filter.inspect} | in_folder: #{in_folder.inspect} | options: #{cli_options.inspect}"
    puts "#{header}\n#{'-'*[80, header.length].min}".bleu
    base_folder = tests_folder
    base_folder = File.join(base_folder, in_folder) if in_folder
    all_mus = Dir["#{base_folder}/**/*.mus"].map{|pth|MusFile.new(pth)}

    if filter
      all_mus = all_mus.select { |musfile| musfile.pass_filter?(filter) }
    end

    if only_last?
      return [all_mus.last]
    else
      return all_mus
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
      --last : seulement le dernier, --lasts : les derniers testés
      --only_failures : seulement les derniers échecs rencontrés

    TEXT
  end


  def reset(params)
    @success_tests  = []
    @failures_tests = []
    @pendings_tests = []
    @report_file = ReportFile.new(params)
  end

end #/<< self class
end #/class Test
end #/module ScoreImage
