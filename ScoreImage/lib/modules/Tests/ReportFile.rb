module ScoreImage
class Test
class ReportFile

  attr_reader :data
  attr_reader :params

  def initialize(params)
    @start_time = Time.now
    @params     = params
  end

  # Méthode appelée à la fin des tests
  # Elle mémoriser la date de fin et enregistre le rapport dans
  # le fichier caché
  def stop
    @stop_time = Time.now
    save
  end

  def reset_data
    @data = {
      start: @start_time,
      stop:  @stop_time,
      success_count: Test.success_tests.count,
      pending_count: Test.pendings_tests.count,
      failure_count: Test.failures_tests.count,
      failures: Test.failures_tests,
      options: CLI.options,
      params: params, # :folder, :filter
    }
  end

  def save
    reset_data
    IO.write(path, Marshal.dump(data).force_encoding('utf-8'))
  end

  def load
    @data ||= begin
      if exist?
        begin
          Marshal.load(IO.read(path))
        rescue Exception => e
          verbose? && puts("Le dernier rapport n’a pas pu être chargé : #{e.message}")
          {}
        end
      else {} end
    end
  end

  def exist?
    File.exist?(path)
  end

  def path
    @path ||= File.join(Test.tests_folder,'.last_report').freeze
  end

end #/class ReportFile
end #/class Test
end #/module ScoreImage
