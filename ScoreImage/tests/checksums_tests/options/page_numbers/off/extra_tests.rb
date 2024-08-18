module ExtraTestMethods

  def proceed
    page_2_should_exist || return
    page_2_should_match_checksum  
  end

  def page_2_should_exist
    unless File.exist?(page2_path)
      errors << "La page 2 n’a pas été produite."
    else
      return true
    end
  end

  def page_2_should_match_checksum

    current_page2_checksum = page2_checksum
    
    if checksum_page2_exist?
      if current_page2_checksum != waited_checksum_page2
        errors << "La page 2 n’est pas conforme à celle attendue."
      end
    else
      # Le checksum de la page 2 n’existe pas encore, il faut
      # le faire et générer un pending
      IO.write(checksum_page2_path, current_page2_checksum)
      musfile.ok = nil
      display_pending_page2
    end

  end

  def waited_checksum_page2
    IO.read(checksum_page2_path).strip
  end

  def checksum_page2_exist?
    return File.exist?(checksum_page2_path)
  end

  def page2_checksum
    musfile.checksum_of(page2_path)
  end

  def checksum_page2_path
    @checksum_page2_path ||= File.join(musfile.folder,'CHECKSUM_p2')
  end

  def page2_path
    @page2_path ||= File.join(musfile.build_folder,'score-2.svg').freeze
  end


  def display_pending_page2
    puts <<~MSG.bleu
    
    [Pending] #{musfile.relative_path}
    Si l’image #{musfile.relative_path}/main/score-2.svg correspond 
    aux attentes, relancez le test pour le jouer vraiment. Sinon,
    détruisez le fichier CHECKSUM_p2, corrigez le test et recommencez
    l’opération.
    MSG
  end


end #/module ExtraTestMethods
