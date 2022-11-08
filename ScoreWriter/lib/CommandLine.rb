# encoding: UTF-8

module ScoreWriter

  class CommandLine

    ##
    # Affichage des options
    def self.show_options
      clear
      puts <<-TEXT.bleu

 ScoreWriter Options
 -------------------

  -cl/--cote=left     Pour que la partition s'affiche à côté du code
                      à gauche
  -cr/--cote=right    Pour que la partition s'affiche à côté du code
                      à droite

      TEXT
    end

    def self.show_help
      clear
      less <<-TEXT

  Aide ScoreWriter
  -----------------

  Cette app de produire facilement une partition.

  Commande :

    #{'score-writer [<options>]'.jaune}

    Pour voir les options, jouer #{'score-writer options'.jaune}.

      TEXT
    end

    def self.parse
      @@options = {}
      ARGV.each do |argv|
        next if not(argv.start_with?('-'))
        argv, valu = argv.split('=') if argv.match?('=')
        case argv
        when '--cote','-cl','cr'then 
          valu ||= argv == '-cl' ? 'left' : 'right'
          @@options.merge!(cote:   true)
        when '-prefix'  then @@options.merge!(prefix: valu)
        when '--path'   then @@options.merge!(path: valu)
        end
      end
    end

    def self.affixe_partition
      @@affixe_partition ||= begin
        afp = nil
        ARGV.each do |argv|
          next if argv.start_with?('-')
          afp = argv
          afp = afp[2..-1].strip if afp.start_with?('./')
          break
        end
        afp
      end
    end
    def self.affixe_partition=(value)
      @@affixe_partition = value
    end

    def self.options
      @@options
    end

  end #/class CommandLine

end #/ScoreWriter
