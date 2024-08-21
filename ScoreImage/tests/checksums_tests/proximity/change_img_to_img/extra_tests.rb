module ExtraTestMethods

  def proceed

    if File.exist?(checksum_prox_30_path)
      if checksum_prox30 == expected_checksum_prox30
        musfile.ok = true
      else
        err = <<~ERR
        Le second fichier avec une proximitié plus grande n’est pas
        conforme à ce qui est attendu.
        ERR
        errors << err
      end
    else
      IO.write(checksum_prox_30_path, checksum_prox30)
      puts explication_checksum30.bleu
      musfile.ok = nil
    end
  end

  def expected_checksum_prox30
    IO.read(checksum_prox_30_path).strip
  end

  def checksum_prox_30_path
    @checksum_prox_30_path ||= File.join(musfile.folder,'CHECKSUM_2')
  end

  def checksum_prox30
    musfile.checksum_of(path_prox30)  
  end

  def path_prox30
    @path_prox30 ||= File.join(musfile.build_folder,'score_prox_30.svg')
  end

  def explication_checksum30
    <<~TXT
    [pending] #{musfile.relative_path}
    Vérifier que le fichier ’score_prox_30.svg’ correspond aux attentes.
    Si c’est le cas, relancer le test et sinon, détruire le fichier
    CHECKSUM_2 et corriger le programme (ou le test) jusqu’au résultat
    escompté.

    TXT
  end

end #/module ExtraTestMethods
