'use strict';
/**

  WAA.js
  ------
  Librairie permettant de gérer la WAA application. De façon simple,
  elle reçoit et elle transmet les données au script (ruby) qui a
  lancé l'application avec le web-driver Selenium, appelé ci-dessus
  le "script maitre"

  WAA.state = 1   au démarrage
  WAA.state = 2   quand l'application est prête

*/

class Waa {

  /**
   * Méthode appelée par le serveur (script maitre) pour savoir 
   * s'il y a des 'messages' à recevoir. Si c'est le cas, on le
   * retourne.
   * 
   * Note-rappel : un 'Message' est un échange entre serveur et 
   * client qui a toujours la même forme. Dans la première version
   * de WAA, il contient :classe (définition d'une classe à appeler),
   * :method (la méthode de la classe à appeler) et :data (optionnel-
   * lement, les données, une table, à passer à la méthode).
   * 
   */
  get_message(){
    if (this.datastack && this.datastack.length) {
      return this.datastack.shift()
    }
  }

  /**
   * Pour envoyer des données au script maitre
   * (cf. dans waa.rb le format des données)
   */
  send(data_message){
    if(undefined == this.datastack) this.datastack = []
    if('string' != typeof data_message) data_message = JSON.stringify(data_message)
    this.datastack.push(data_message)
  }

  /**
   * Pour recevoir des données du script maitre par un 'Message'
   * (cf. dans waa.rb le format des données)
   * 
   */
  receive(data_message){
    data_message = JSON.parse(data_message)
    // console.log("Je viens de recevoir le message: ", data_message)
    // 
    // Classe définie par le message
    // 
    let classe = eval(data_message.class)
    // 
    // Appeler la méthode définie par le message, avec les 
    // données définies (if any)
    // 
    classe[data_message.method].call(classe, data_message.data)
    // 
    // On retourne true pour le check
    // 
    return true
  }

  get state(){ return this._state || 1 }
  set state(v){ this._state = v }

}

var WAA = new Waa();
