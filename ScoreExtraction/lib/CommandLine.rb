# encoding: UTF-8

module ScoreExtraction

  class CommandLine

    ##
    # Affichage des options
    def self.show_options
      clear
      puts <<-TEXT.bleu

 ScoreExtraction Options
 -----------------------

    (note : certaines options ci-dessous concernent scorize et n'ont
     aucun effet sur la production de l'extrait)

    -m/--mesure       Afficher le numéro de la première mesure
                      de l'extrait.
    -p/-proximity=x   Mettre une proximité de x entre les notes. La
                      normal est 5, plus le nombre est grand, plus 
                      les notes seront éloignées.
    -prefix=abcde_fg  Pour définir un nouveau préfixe utilisé pour
                      les noms.
    -k/--keep         Pour conserver tous les fichiers créés

    -s/--stats        Produire les statistiques de l'extrait. C'est
                      une option pour scorize, pas pour ScoreExtraction
    -t/--tempo=<val>  Pour les statistiques, le tempo (à la noire)
                      Ajouter "T" au bout du tempo si c'est une métrique
                      ternaire (p.e. '60T')

      TEXT
    end

    def self.show_help
      clear
      less <<-TEXT

  Aide ScoreExtraction
  --------------------

  Cette app permet d'extraire un fragment d'une partition dont on fournit
  les données par mesure.

  Commande :

    #{'source-extract <première mesure> <dernière mesure comprise> [<options>]'.jaune}

    Pour obtenir les options, jouer #{'source-extract options'.jaune}.

    Si la dernière mesure n'est pas précisée, ce sera la dernière.
    Si la première mesure n'est pas précisée, ce sera la première.
    Donc la commande :

    #{'source-extract'.jaune}

    … produira la partition entière, avec les valeurs par défaut.

  Pour obtenir les données des mesures
  ------------------------------------

  Utiliser MusicScoreWrite, en hauteur de note absolue et sortir la
  partition au format d'une table de données des mesures.
  Coller le résultat dans un fichier data_mesures.rb à mettre dans un
  dossier vide ne servant qu'à obtenir les extraits.

  Pour obtenir un fragment de la partition
  ----------------------------------------

    * Ouvrir un Terminal au dossier contenant data_mesures.rb qui
      doit définir la constante DATA_MESURES définissant les mesures,
    * jouer la commande ci-dessus en réglant les mesures et les options
      pour obtenir l'extrait voulu.

  Format des données
  ------------------

  On peut entrer les données à la main. Il suffit de définir la constante
  DATA_MESURES dans un fichier de nom 'data_mesures.rb'. De cette
  manière :

  DATA_MESURES = {
    1 => ["<main droite>", "<main gauche>"], # mesure 1
    2 => ["<main droite>", "<main gauche>"], # mesure 2
    ...
    N => ["<main droite>", "<main gauche>"], # mesure N
  }

      TEXT
    end

    def self.parse
      @@options = {}
      ARGV.each do |argv|
        next if not(argv.start_with?('-'))
        argv, valu = argv.split('=') if argv.match?('=')
        case argv
        when '--keep',      '-k'      then @@options.merge!(keep:   true)
        when '--mesure',    '-m'      then @@options.merge!(mesure: true)
        when '-proximity',  '-p'      then @@options.merge!(proximity: valu)
        when '--stats',     '-s'      then @@options.merge!(stats: true)
        when '-prefix'                then @@options.merge!(prefix: valu)
        when '--tempo','-tempo','-t'  then @@options.merge!(tempo: valu)
        end
      end
    end

    def self.first_mesure
      @@first_mesure ||= begin
        if ARGV[0]
          ARGV[0].start_with?('-') ? nil : ARGV[0].to_i
        end
      end
    end

    def self.last_mesure
      @@last_mesure ||= begin
        if ARGV[1]
          ARGV[1].start_with?('-') ? nil : ARGV[1].to_i
        end
      end
    end

    def self.options
      @@options
    end

  end #/class CommandLine

end #/ScoreExtraction
