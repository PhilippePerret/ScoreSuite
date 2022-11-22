# encoding: UTF-8
=begin

  Module WAA
  ----------
  Pour les applications WAA (Without Ajax Application)
  C'est le pendant de la librairie waa.js côté client

  La données transmises dans un sens comme dans l'autre doivent
  être au format JSON.

  Le format de base est le suivant :
    {
      id:     '<identifiant universell unique>'
      class:  '<nom de la classe de l'app à appeler>',
      method: '<nom de la méthode de la classe à appeler>',
      data:   {<données JSON à transmettre à la méthode>}
    }

=end
require 'selenium-webdriver'
require 'webdrivers'

BROWSER = :chrome # pour le zoom

def clear
  puts "\n" # pour certaines méthodes
  puts "\033c"    
end

clear

class Waa

  @version = '1.0'
  attr_reader :version
  
  attr_reader :browser, :driver


  #
  # Instanciation
  #
  def initialize(browser = :firefox)
    @browser = browser
  end

  def goto(file)
    driver.navigate.to 'file://'+file
  end

  # 
  # La boucle d'attente jusqu'à la fin
  # (pour le moment, rien n'indique la fin)
  # 
  def run
    state = 1
    iloop = 20 # pour des essais
    wait.until do
      check_clsv_message
      # 
      # Pour des essais
      # 
      if false #true
        iloop -= 1
        break if iloop < 0
      end

      # Marque la fin du programme
      state == 0
    end

  end

  #
  # Méthode qui regarde essaie de récupérer une donnée s'il y en a
  # 
  # "clsv" signifie "client-server"
  # 
  def check_clsv_message
    begin
      msg = driver.execute_script('return WAA.get_message()')
    rescue Exception => e
      # Par exemple quand on recharge la page
      puts "ERREUR BLOQUÉE : #{e.message}".orange
      return 
    end
    if msg
      traite_message(msg)
    else
      # out("Aucun message envoyé.")
    end
  end

  def traite_message(msg)
    message = Waa::Message.new(msg)
    #
    # On exécute le message
    #
    message.execute

  end

  #
  # Pour envoyer un 'message' côté client
  # 
  def send(data)
    data = data.to_json if not(data.is_a?(String))
    data = data.gsub(/"/,'\\"')
    # puts "WAA.send: Data envoyée : #{data}"
    resultat = driver.execute_script('return WAA.receive("'+data+'")')
  end

  ##
  # Le driver
  def driver
    @driver ||= begin
      if browser == :firefox
        opts = Selenium::WebDriver::Firefox::Options.new(
          # args: ['-devtools'], # -headless, -devtools, -jsconsole
          args: ['-devtools'], # -headless, -devtools, -jsconsole
          prefs: {
            'devtools.debugger.start-panel-collapsed': true,
            'devtools.toolbox.zoomValue': 4,
            'devtools.toolsidebar-height.inspector': 300,
            'devtools.chrome.enabled': true
          }
          # à essayer :
          # devtools.debugger.ui.editor-wrapping true/false
          # devtools.debugger.ui.panes-visible-on-startup
        )
      else
        opts = {}
      end
      Selenium::WebDriver.for(browser, options: opts)
    end
  end

  ##
  # Le waiter
  def wait
    @wait ||= Selenium::WebDriver::Wait.new(:timeout => 24 * 3600 )
  end

class Message
  def initialize(raw_data)
    @raw_data = raw_data    
  end

  def execute
    # puts "Waa::Message: ruby_classe = #{ruby_classe.inspect}" 
    # puts "Waa::Message: ruby_method = #{ruby_method.inspect}" 
    if defined?(ruby_classe) == 'method' # wierd…
      classe = Object.const_get(ruby_classe)
      if classe.respond_to?(ruby_method)
        if method_args
          classe.send(ruby_method, method_args)
        else
          classe.send(ruby_method)
        end
      else
        raise "Méthode de classe inconnue : #{classe}::#{ruby_method}"
      end
    else
      raise "Classe inconnue : #{ruby_classe}"
    end
  end
  
  def data
    @data ||= JSON.parse(@raw_data)
  end

  def id;           @id           ||= data['id'] end
  def ruby_classe;  @ruby_classe  ||= data['class']   end
  def ruby_method;  @ruby_method  ||= data['method'].to_sym  end
  def method_args;  @method_args  ||= data['data'] end

end #/class Message

end #/class Waa


WAA = Waa.new(BROWSER)
