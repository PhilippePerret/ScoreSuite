#
# Ce module permet de lancer les tests de formatage
# 
# Pour le lancer :
# 
#   * Ouvrir un Terminal au dossier ./tests
#   * Jouer la commande ’ruby ./r[TAB]’
# 
# Le principe de ces tests est très simple : chaque test contient
# un fichier .mus et un fichier .svg qui est son résultat.
# La commande ’score-image’ est appelé sur chaque dossier-test et
# doit produire le même fichier que le fichier .svg.
# 
# 
gem 'clir'
require 'clir'
require 'digest'


class TestErreur < StandardError; end


dossiers_tests = File.join(__dir__,'tests_formatages')

#
# Ici ajout la possibilité de filtrer
# 

success_tests  = []
failures_tests = []
pendings_tests = []

clear;clear

Dir["#{dossiers_tests}/**/*.mus"].each do |mus_file|
  dossier = File.dirname(mus_file)
  fname   = File.basename(mus_file)

  frelpath = mus_file.sub(/^#{dossiers_tests}/,'.')

  begin
    cmd = 'cd "%s";score-image "%s"'.freeze % [dossier,fname]
    res = `#{cmd} 2>&1`
    if res.match?('produite avec succès')
      # OK, on peut comparer
      affixe = File.basename(mus_file,File.extname(mus_file))
      svg_file = Dir["#{dossier}/#{affixe}/*.svg"][0]
      if File.exist?(svg_file)
        # Checksum du fichier SVG
        svg_checksum = Digest::MD5.file(svg_file).hexdigest
        checksum_path = File.join(dossier,affixe,'checksum')
        if File.exist?(checksum_path)
          # La comparaison est possible
          if svg_checksum == IO.read(checksum_path).strip
            puts "#{frelpath} est conforme aux attentes".vert
            success_tests << frelpath
          else
            raise TestErreur.new("Fichier SVG non conforme aux attentes.")
          end
        else
          # On crée le checksum pour la première fois
          IO.write(checksum_path, svg_checksum)
          puts <<~TEXT.bleu
          Checksum créé pour #{frelpath}
          Vérifie que le SVG soit conforme aux attentes, et si ça n’est
          pas le cas, corrige le programme et détruis le checksum pour 
          en obtenir un bon.
          TEXT
        end
      else
        raise TestErreur.new("L’image SVG n’a pas été produite")
      end
    else
      raise TestErreur.new(res)
    end
  rescue TestErreur => e
    failures_tests << frelpath
    puts <<~TEXT.rouge
      ------------------------------------------------------
      [#{failures_tests.count}] Une erreur est survenue avec :
      #{frelpath}
      Erreur : #{e.message}
      ------------------------------------------------------
    TEXT
  end
end

# = Rapport de fin =
color = failures_tests.empty? ? :vert : :rouge
msg = "Success: #{success_tests.count} Failures: #{failures_tests.count} Pendings: #{pendings_tests.count}"

puts "\n#{'-'*40}\n#{msg}".send(color)
