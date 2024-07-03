module ScoreNumbering
class Score
class << self

  # Le dossier dans lequel on a lancé l’application
  attr_accessor :current_folder

  def check_existence(data)
    retour = {ok:true, msg: nil}
    # puts "Check de l’existence de #{data.inspect}"
    filename = data["name"]
    filepath = File.expand_path(File.join(".", filename))
    if File.exist?(filepath)
      # On fait une copie du fichier dans l’application
      destpath = File.join(APP_FOLDER,"system.jpg")
      FileUtils.copy(filepath, destpath)
    else
      retour.merge!(ok:false, msg: "Fichier introuvable dans #{filepath.inspect}")
    end
    WAA.send({class:"Score.current", method:"imageExists", data:retour})
  end


  def print_numbers(data)
    retour = {ok:true, msg: nil}
    curfolder_name = File.basename(App.current_folder)
    sys_numbered_systems = File.expand_path(File.join("../#{curfolder_name}-N"))
    FileUtils.mkdir_p(sys_numbered_systems)
    fname   = data["filename"]
    extname = File.extname(fname)
    srcpath = File.expand_path(File.join(".", fname))
    affixe = File.basename(fname, extname)
    dstpath = File.join(sys_numbered_systems,"#{affixe}N.#{extname}")
    File.delete(dstpath) if File.exist?(dstpath)
    numeros = []
    data["numbers"].each do |dnumber|
      numero  = dnumber["numero"]
      x       = dnumber["x"].to_i
      y       = dnumber["y"].to_i
      numeros << CMD_DRAW_NUMBER % { numero:numero, x:x, y:y }
    end

    cmd = CMD_PRINT_NUMBERS % {
      src:      srcpath,
      dest:     dstpath,
      fonte:    data["style"]["fonte"],
      size:     data["style"]["size"],
      fill:     data["style"]["color"],
      numeros:  numeros.join(' '),
    }

    # puts "Commande jouée : #{cmd}"

    res = `#{cmd} 2>&1`
    if res && !res.empty?
      puts "Résultat : #{res}".rouge
      retour.merge!(ok:false, msg: res)
    end
    WAA.send(class:"Score.current", method:"onNumbersPrinted", data:retour)

  end

  CMD_DRAW_NUMBER = '-draw "text %{x} %{y} \'%{numero}\'"'.freeze
  CMD_PRINT_NUMBERS = 'magick "%{src}" -font %{fonte} -pointsize %{size} -fill "%{fill}" %{numeros} "%{dest}"'.freeze


  def get_next_system(data)
    retour = {ok:true, msg: nil}
    begin
      fname = data["filename"]
      raise if !fname || fname.empty?
      raise "Ne contient pas de chiffre…" unless fname.match?(REG_SYSTEM_NAME)
      pref, nombre, suf = fname.scan(REG_SYSTEM_NAME).to_a[0]
      len_nombre = nombre.length
      nombre = nombre.to_i
      next_nombre = nombre + 1
      nextname = "#{pref}#{next_nombre}#{suf}"
      nextpath = File.join(CURRENT_FOLDER, nextname)
      unless File.exist?(nextpath)
        nextname = "#{pref}#{next_nombre.to_s.rjust(len_nombre,'0')}#{suf}"
        nextpath = File.join(CURRENT_FOLDER, nextname)
      end
      if File.exist?(nextpath)
        retour.merge!(next_system: nextname)
      else
        raise "Le fichier #{nextpath} est introuvable. Pas de système suivant."
      end


    rescue Exception => e
      retour.merge!(ok:false, msg: "Impossible de passer au système suivant : #{e.message}.")
    end
    # puts "pref:#{pref.inspect}, nombre:#{nombre.inspect}, suf:#{suf.inspect}"

    WAA.send(class:"UI", method:"onReturnNextSystem", data:retour)
  end
  REG_SYSTEM_NAME = /^([^0-9]+)([0-9]+?)([^0-9]+)$/

end #/<< self
end #/class App
end #/module ScoreNumbering
