module ScoreImage
class Test
class MusFile

  EXTRAIT_MESSAGE_SUCCES = 'produite avec succès'.freeze

  attr_reader :path
  attr_accessor :indice

  def initialize(path)
    @path      = path
    @error_msg = nil
  end

  # === Test Methods ===

  MSG_NEGATIVE_ERROR = <<~ERR
  La construction aurait dû échouer avec le code d’erreur %{code}
  et les éventuels textes : %{texts}.
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
  # En cas de test négatif (qui doit produire une erreur) il faut
  # trouver le message d’erreur (code) dans le retour.
  def test
    resultat_built = build_svg_score
    if negative?
      # 
      # Test négatif
      # 
      @ok = has_error?(resultat_built)
      if not(@ok)
        @error_msg = MSG_NEGATIVE_ERROR % {code: expected_error_code, texts: (expected_error_txts||['néant']).join(',')}
      end
    else
      #
      # Test positif
      # 
      if resultat_built.match?(EXTRAIT_MESSAGE_SUCCES)
        @ok = compare_with_checksum # => true, false, nil
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
    # puts "resultat = #{result.inspect}".bleu
    if original_svg_exist?
      nettoie_dossier
    end
    return result
  end

  def nettoie_dossier
    move_svg
    FileUtils.rm_rf(build_folder)
  end

  def run_build_command
    `#{build_command} 2>&1`
  end

  def build_command
    @build_command ||= 'cd "%s";score-image "%s"'.freeze % [folder,filename]
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
    "La construction de #{relative_path} " + 
    if not(@error_msg.nil?)
      "a retourné le message d’erreur suivant :\n#{@error_msg}"
    elsif not(original_svg_exist?)
      "n’a pas pu construire la partition SVG."
    elsif not(checksums_same?)
      "ne correspond pas aux attentes."
    else
      "n’est pas bon pour une raison inconnue."
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
    TEXT
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
    @checksum_tested ||= begin
      if File.exist?(svg_path)
        (Digest::MD5.file(svg_path).hexdigest).freeze
      else
        :no_checksum_tested
      end
    end
  end

  def save_checksum
    IO.write(checksum_path, checksum_tested)
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
    @built_svg_path ||= File.join(build_folder,svg_name).freeze
  end

  def svg_name
    @svg_name ||= "#{image_name}.svg".freeze
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
    # le code MUS. Il est repéré par ’->’
    def get_image_name
      muscode = IO.read(path).force_encoding('UTF-8')
      muscode.match(/^\-\> (.+)$/)[1].strip
    end

end #/class MusFile
end #/class Test
end #/module ScoreImage
