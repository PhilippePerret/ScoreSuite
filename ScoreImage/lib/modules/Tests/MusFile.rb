module ScoreImage
class Test
class MusFile

  EXTRAIT_MESSAGE_SUCCES = 'produite avec succès'.freeze

  attr_reader :path
  attr_accessor :indice

  # Pour les "extra-tests"
  attr_writer :ok

  def initialize(path)
    @path      = path
    @error_msg = nil
  end

  # === Test Methods ===

  MSG_NEGATIVE_ERROR = <<~ERR
  La construction de : %{relpath} 
  aurait dû échouer avec le code d’erreur : %{code} et les 
  éventuels textes : %{texts}.
  Or, la construction a réussi.
  ERR

  # = main =
  # 
  # TEST DU FICHIER
  # ----------------
  # Cela consiste à :
  #   - le construire avec ’score-image’
  #   - calculer le checksum du SVG résultat
  #   - le comparer avec le checksum attendu
  #   - produire les statistiques et les comparer avec les
  #     statistiques validées
  # 
  # En cas de test négatif (qui doit produire une erreur) il faut
  # trouver le message d’erreur (code) dans le retour.
  # 
  def test
    # Avec l’option ’-d’, on force la destruction de tous les
    # fichiers CHECKSUM des tests filtrés (pour réinitialiser leur
    # test, en quelque sorte)
    if CLI.option(:d)
      File.exist?(checksum_path) && File.delete(checksum_path)
      # PAS CI-DESSOUS
      # File.exist?(stats_compare_path) && File.delete(stats_compare_path)
      # <= ça détruirait toutes les vérifications faites, qui peuvent
      # être assez fastidieuses
      # => Les détruire à la main si nécessaire
    end
    resultat_built = build_svg_score
    if negative?
      # 
      # Test négatif
      # 
      @ok = has_error?(resultat_built) || not(extra_tests_ok?)
      if not(@ok)
        err_msgs = []
        err_msgs += expected_error_txts if expected_error_txts
        err_msgs +=  extra_tests.errors if not( extra_tests.errors.empty?)
        err_msgs = ['néant'] if err_msgs.empty?
        err_msgs = err_msgs.join(',')
        @error_msg = MSG_NEGATIVE_ERROR % {relpath:relative_path, code: expected_error_code, texts: err_msgs}
      end
    else
      #
      # Test positif
      # 
      if resultat_built.match?(EXTRAIT_MESSAGE_SUCCES)
        @ok = compare_with_checksum # => true, false, nil
        if @ok === true
          # @ok et @error_msg peuvent être modifiés par des tests
          # particulier sur les productions
          @ok = extra_tests_ok?
          if @ok === false
            # = Extra-tests =
            @error_msg = extra_tests.errors.join("\n")
          else
            # = Statistiques =
            @ok = statistiques_ok? # => true, false, nil
            if @ok === nil
              display_explication_pending_stats
              stats_file_to_good_file # on produit GOOD-STATS.csv
            end
          end
        end
      else
        @error_msg = resultat_built 
        @ok = false
      end
    end
  end

  # Méthode qui compare le checksum attendu avec le checksum de la
  # nouvelle image créée
  # 
  # @return :
  #   - true  si le checksum existe et qu’il est identique
  #   - false si le checksum existe et qu’il est différent
  #   - nil   si le checksum n’existe pas encore
  def compare_with_checksum
    if checksum?
      return checksums_same?
    else
      save_checksum
      display_explication_pending
      return nil # pending
    end
  end

  def build_svg_score
    result = run_build_command
    if original_svg_exist?
      move_svg
      nettoie_dossier
    end
    return result
  end

  # On supprime le dossier ’main’, mais seulement s’il est vide
  def nettoie_dossier
    if Dir["#{build_folder}/*"].count == 0
      FileUtils.rm_rf(build_folder)
    end
  end

  def run_build_command
    # `#{build_command} 2>&1` # avant
    require 'open3'
    out, err, pid = Open3.capture3(build_command)
    # puts "out: #{out.inspect}"
    # puts "err: #{err.inspect}"
    if pid.success? && out.match?('produite avec succès')
      return out
    elsif pid.success? && out.match?(/ERREUR \[[0-9]+\]/)
      return out
    elsif pid.success? && err.empty?
      # La commande n’a pas échoué, mais l’image n’a pas été produite
      # et pourtant aucun message d’erreur n’a été renvoyé
      return "Une erreur inconnue (sans message d’erreur) a été rencontrée.\nÀ titre indicatif, out a retourné : #{out.inspect}"
    else
      return err
    end
  end

  # Commande
  # 
  # @notes
  #   
  def build_command
    @build_command ||= 'cd "%s" && score-image --stats --tempo=60 "%s"'.freeze % [folder,File.join(folder,filename)]
  end

  def open
    `open -a Finder "#{folder}"`
  end

  def open_in_ide
    `subl "#{folder}"`
  end

  # === Helper Methods ===

  # Le message d’erreur qui sera affiché
  # 
  def error
    if negative? && @error_msg
      @error_msg
    else
      "La construction de ’#{relative_path}’ " + 
      if not(@error_msg.nil?)
        "a retourné le message d’erreur suivant :\n#{@error_msg}"
      elsif not(checksums_same?)
        "n’est pas conforme aux attentes."
      elsif not(statistics_same?)
        <<~TEXT.strip
        produit la bonne image mais 
        pas les STATISTIQUES attendues.
        Comparer les fichiers ’GOOD-STATS.csv’ et ’main-stats.csv’ 
        du dossier ’stats’
        TEXT
      else
        "n’est pas bon pour une raison inconnue."
      end
    end
  end

  def display_explication_pending
    puts <<~TEXT.bleu

    [Pending] #{relative_path}
    Si l’image #{relative_path}/#{svg_name} ne correspond 
    pas aux attentes, détruire le fichier CHECKSUM. Dans le cas contraire, 
    au prochain test, le fichier #{svg_name} produit devra correspondre.
    Vous pouvez aussi dupliquer le fichier #{svg_name} en ajoutant par 
    exemple "bon" à son nom pour garder une trace de l’image bonne.
    (note : pour forcer la destruction du CHECKSUM à chaque — pendant la
    phase de mise au point du test — ajouter l’option ’-d’ comme ’delete’)
    TEXT
  end

  def display_explication_pending_stats
    puts <<~TEXT.bleu

    [Pending] #{relative_path}
    Si les statistiques pour l’image #{relative_path}/#{svg_name} ne 
    sont pas valides :
      1. détruire le fichier : #{relative_path}/stats/GOOD-STATS.csv
      2. corriger le code de Score-Image pour que ça soit bon
      3. relancer le test pour vérifier.
    TEXT
    
  end


  # === Extra Tests Methods ===
  # 
  # (les extra tests sont des tests particuliers qui peuvent être
  #  créés pour des tests particuliers)
  # 

  # @return true si les extra tests réussissent ou s’ils n’existent
  # pas
  def extra_tests_ok?
    extra_tests.ok?
  end

  def extra_tests
    @extra_tests ||= ExtraTests.new(self)
  end

  # === Functional Methods ===


  def move_svg
    FileUtils.mv(built_svg_path, svg_path)
  end


  # === Negative Methods === #


  attr_reader :expected_error_code
  attr_reader :expected_error_txts


  # @return true si c’est un test négatif, c’est-à-dire une 
  # construction qui doit échouer. Dans ce cas, le test contient un
  # fichier ’FAILURE’ avec le numéro d’erreur et les éventuels textes
  # à trouver
  def negative?
    File.exist?(failure_path_file)
  end

  def has_error?(err_msg)
    read_negative_file
    ok = err_msg.match?(/\[#{expected_error_code}\]/.freeze)
    return false if not(ok)
    if expected_error_txts && not(expected_error_txts.empty?)
      expected_error_txts.each do |expected_error_txt|
        eet = Regexp.escape(expected_error_txt)
        return false if not(err_msg.match?(/#{eet}/.freeze))
      end
    end
    return true
  end

  # Lecture du fichier FAILURE qui contient le code de l’erreur
  # ainsi qu’éventuellement les messages à trouver séparés par des
  # points-virgule
  def read_negative_file
    c = IO.read(failure_path_file).chomp.split(';')
    @expected_error_code = c.shift.freeze
    c = nil if c.empty?
    @expected_error_txts = c.freeze
  end


  # === Checksum Methods ===


  def checksum_compare
    @checksum_compare ||= begin
      if File.exist?(checksum_path)
        IO.read(checksum_path).strip.freeze
      else
        :no_checksum_compare
      end
    end
  end

  def checksum_tested
    @checksum_tested ||= checksum_of(svg_path) || :no_checksum_tested
  end

  def save_checksum
    IO.write(checksum_path, checksum_tested)
  end

  # @return le checksum du fichier +pth+
  def checksum_of(pth)
    if File.exist?(pth)
      (Digest::MD5.file(pth).hexdigest).freeze
    else nil end
  end

  # === Statistiques Methods === #

  # = main =
  # 
  # Méthode principale qui checke les statistiques
  # 
  # @return
  #   true    Les statistiques correspondent
  #   false   Les statistiques ne correspondent pas
  #   nil     Les statistiques n’ont pas encore de références
  def statistiques_ok?
    return nil if not(File.exist?(stats_compare_path))
    return statistics_same?
  end

  def statistics_same?
    :TRUE == @statistiques_are_the_same ||= true_or_false(stats_compare == stats_tested)
  end

  def stats_compare
    @stats_compare ||= begin
      if File.exist?(stats_compare_path)
        IO.read(stats_compare_path).strip.freeze
      else
        :no_stats_compare
      end
    end
  end

  def stats_tested
    @stats_tested ||= begin
      if File.exist?(stats_tested_path)
        IO.read(stats_tested_path).strip.freeze
      else
        :no_stats_tested
      end
    end
  end

  # La première fois, quand ’GOOD-STATS.csv’ n’existe pas, on prend
  # ’main-stats.csv’ pour le construire (en disant de le détruire si
  # les statistiques ne correspondent pas)
  def stats_file_to_good_file
    FileUtils.move(stats_tested_path, stats_compare_path)
  end

  def stats_compare_path
    @stats_compare_path ||= File.join(folder,'stats','GOOD-STATS.csv')
  end

  def stats_tested_path
    @stats_tested_path ||= File.join(folder,'stats','main-stats.csv')
  end


  # === Predicate Methods ===



  def exist?
    File.exist?(path)
  end


  # @param [Regexp] Expression régulière pour filtrer le nom
  # 
  # @return true si le fichier passe le filtre filter
  def pass_filter?(filter)
    relative_path.match?(filter)
  end

  def success?
    @ok == true
  end

  def failure?
    @ok === false
  end

  def pending?
    @ok === nil
  end

  def original_svg_exist?
    File.exist?(built_svg_path)
  end

  # @return true si le fichier mus ne produit qu’une seule image
  # (les tests sont différents dans le cas contraire)
  def only_one_svg?
    :TRUE == @onlyonesvg ||= (Dir["#{build_folder}/*.svg"].count == 1 ? :TRUE : :FALSE)
  end

  # @return true si plusieurs images SVG ont été produite par le
  # fichier mus
  def plusieurs_svg?
    :TRUE == @plusieurssvg ||= (only_one_svg? ? :FALSE : :TRUE)
  end

  def checksums_same?
    checksum_compare == checksum_tested
  end

  def checksum?
    File.exist?(checksum_path)
  end


  # === Path Methods ===



  # Nom de l’image créée (le ’-> partition’ dans le mus-file)
  def image_name
    @image_name ||= get_image_name.freeze
  end

  def checksum_path
    @checksum_path ||= File.join(folder,'CHECKSUM')
  end

  def failure_path_file
    @failure_path_file ||= File.join(folder, 'FAILURE')
  end

  def svg_path
    @svg_path ||= File.join(folder,svg_name).freeze
  end

  def built_svg_path
    @built_svg_path ||= begin
      File.join(build_folder,svg_name).freeze
    end
  end

  def svg_name
    @svg_name ||= define_real_svg_name
  end

  # L’image peut avoir pour nom ’<nom image>.svg’ ou 
  # ’<nom image>-1.svg’ suivant le nombre de pages produites.
  def define_real_svg_name
    n = "#{image_name}.svg".freeze
    return n if File.exist?(File.join(build_folder, n))
    if File.exist?(File.join(build_folder, svg_name_as_page_1))
      return svg_name_as_page_1
    else
      return n
    end
  end

  def svg_name_as_page_1
    @svg_name_as_page_1 ||= "#{image_name}-1.svg".freeze
  end

  def relative_path
    @relative_path ||= "#{main_folder_name}/#{foldername}"
  end
  alias :relpath :relative_path

  def affixe
    @affixe ||= File.basename(path, '.mus')
  end
  def filename
    @filename ||= File.basename(path)
  end
  def build_folder
    @build_folder ||= File.join(folder,affixe).freeze
  end
  def foldername
    @foldername ||= File.basename(folder)
  end
  def folder
    @folder ||= File.dirname(path)
  end
  def main_folder_name
    @main_folder_name ||= File.basename(main_folder)
  end
  def main_folder
    @main_folder ||= File.dirname(folder)
  end


  private

    # On récupère et renvoie le nom de l’image de la partition dans
    # le code MUS. Il est repéré par ’->’ (ou pas…)
    def get_image_name
      muscode = IO.read(path).force_encoding('UTF-8')
      if muscode.count("->") > 1
        inames = muscode.scan(/^\-\> (.+)$/).to_a.map {|n|n[0]}
        # => ["nom image 1", "nom image 2", etc.]
        # Sauf indication contraire, on prend toujours la première
        # L’indication contraire, c’est l’utilisation de commandes
        # comme START/STOP
        take_next_name  = false
        named_found     = nil
        muscode.split("\n").each do |line|
          if line == 'START'.freeze
            take_next_name = true
          elsif take_next_name && line.start_with?('->')
            named_found = line[3..-1].strip
            break
          end
        end
        named_found ||= inames[0]
        return named_found
      else
        iname = muscode.match(/^\-\> (.+)$/)
        if iname.nil?
          # Quand le nom de l’image n’est pas définie dans le fichier, 
          # on le construit
          "#{affixe}/#{affixe}-score-001"
        else
          iname[1].strip
        end
      end
    end

end #/class MusFile
end #/class Test
end #/module ScoreImage
