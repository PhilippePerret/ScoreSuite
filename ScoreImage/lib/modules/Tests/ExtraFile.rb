#
# Class ScoreImage::Test::ExtraFile
# ---------------------------------
# Pour gérer des fichiers de façon similaire au fichier score 
# principal, en le comparant à un checksum.
# 
# @usage
# 
#   extrafile = ScoreImage::Test::ExtraFile.new(itest, **{
#     file_name: 'nom.ext', # nom dans le "build folder"
#     designation: 'ÇA',    # optionnellement
#   })
# 
#   # - Le tester -
#   extrafile.test_match
# 
# Voir par exemple le test options/midi

module ScoreImage
class Test
class ExtraFile

  class << self

    def next_indice_file
      @current_indice_file ||= 1
      @current_indice_file += 1
    end

  end #/class << self


  attr_reader :test, :musfile, :params
  attr_reader :path
  attr_reader :indice

  def initialize(test, params)
    @test = test
    @musfile = test.musfile
    params[:file_name] || begin
      raise "Le paramètre :file_name doit impérativement être défini."
    end
    @path    = File.join(musfile.build_folder,params[:file_name]).freeze
    File.exist?(@path) || begin
      raise "Le fichier #{path.inspect} est introuvable."
    end
    @indice  = self.class.next_indice_file
    @params  = params 
  end

  # @api
  # @main
  # 
  # Méthode principale qui checke si l’extra-file est valide ou 
  # permet de le faire.
  # 
  def test_match
    if not(checksum_exist?)
      make_checksum_file_and_pending
    elsif not(File.exist?(path))
      test.errors << "Le fichier #{designation} n’a pas été produit."
    elsif checksum_match?
      # OK
    else
      test.errors << message_not_match
    end
  end

  def checksum_exist?
    File.exist?(checksum_path)
  end

  def checksum_match?
    waited_checksum == checksum_of(path)
  end

  def waited_checksum
    @waited_checksum ||= IO.read(checksum_path).strip.freeze
  end


  def make_checksum_file_and_pending
    IO.write(checksum_path, checksum_of(path))
    puts message_pending
  end

  def checksum_path
    @checksum_path ||= File.join(musfile.folder,checksum_filename)
  end
  def checksum_filename
    @checksum_filename ||= "CHECKSUM_#{(params[:designation]||indice).upcase}".freeze
  end

  def checksum_of(path)
    musfile.checksum_of(path)
  end

  def message_not_match
    @message_not_match ||= begin
      <<~MSG
      Le fichier #{designation} n’est pas conforme au fichier
      attendu (en comparant son checksum à #{checksum_filename}).
      MSG
    end
  end

  def message_pending
    puts <<~MSG.bleu
    
    [Pending] #{musfile.relative_path}
    Si le fichier #{designation} #{musfile.relative_path}/main/#{filename} 
    correspond aux attentes, rejouez le test pour lancer l’évaluation
    Sinon, détruisez le fichier #{checksum_filename}, corrigez 
    le code et recommencez l’opération.
    MSG
  end

  def filename
    @filename ||= File.basename(path).freeze
  end

  def designation
    @designation ||= (params[:designation]||"extra #{indice}").freeze
  end


end #/class ExtraFile
end #/class Test
end #/module ScoreImage
