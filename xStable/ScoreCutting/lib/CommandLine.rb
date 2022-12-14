# encoding: UTF-8

module ScoreExtraction

  class CommandLine

    ##
    # Affichage des options
    def self.show_options
      clear
      puts <<-TEXT.bleu

 ScoreCutting Options
 -----------------------


      TEXT
    end

    def self.show_help
      clear
      less <<-TEXT

  Aide ScoreCutting
  =================

  Cette app permet de découper une partition en systèmes.

  Utilisation


  Commande :

    #{'score-cutting [<options>]'.jaune}

    Pour voir les options, jouer #{'source-extract options'.jaune}.

      TEXT
    end

    def self.parse
      @@options = {}
      ARGV.each do |argv|
        next if not(argv.start_with?('-'))
        argv, valu = argv.split('=') if argv.match?('=')
        case argv
        when '--keep',      '-k'      then @@options.merge!(keep:   true)
        when '-prefix'                then @@options.merge!(prefix: valu)
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
