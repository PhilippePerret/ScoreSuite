'use strict';
/**
* Gestion des évènements
*/

window.onresize = function(){
  // console.log("Vous venez de redimensionner la fenêtre.")
}
/**
 * Enregistrement de la nouvelle taille de fenêtre
 * 
 * @notes
 * 
 *  La méthode onresize est appelée à chaque microchangement
 *  de taille de la fenêtre. On ne peut donc pas lui demander
 *  de se charger de l'enregistrement de la nouvelle taille.
 *  On utilise donc un "débouteur" qui va empêcher d'agir avant
 *  que l'utilisateur ait fini de la redimensionner.
 * 
*/
function debounce(func, time = 200){
  var timer;return function(event){timer && clearTimeout(timer);timer = setTimeout(func, time, event);};
}
function onEndResizing() {
  // console.log('Redimensionnée !', window.outerWidth, window.innerWidth, window.outerHeight, window.innerHeight);
}
window.addEventListener("resize", debounce(onEndResizing));




class KeyboardEventManager {
  static onPress(ev){
    return true
  }
  /**
  * @return true si la touche n'a pas été traitée
  */
  static onDownCommon(ev){
    if ( ev.ctrlKey ) {
      // console.warn("[DOWN] Je dois apprendre à jouer le raccourci control + ", ev.key)
      // return stopEvent(ev)
    } 
    if ( ev.metaKey ) {
      /*
      |  Les commandes principales pour commander l'interface
      */
      switch ( ev.key ){
      case 'g': // se rendre au temps voulu ou au marqueur (cf. manuel)
      case 'G': // se rendre au premier temps trouvé dans le texte
      case 'h': // Aide
      case 'j':case 'J': // reculer
      case 'k': // Jouer la vidéo
      case 'l': case 'L': // avancer
      case 'm': case 'M': // placer le marqueur
      case 'p': // panneau des personnages
      case 's': // sauvegarde de l'analyse
      case 'S':
      }
    }
    return true
  }
  static onUpCommon(ev){
    /*
    |  Avec la touche CTRL
    */
    if ( ev.ctrlKey ) {
      // console.warn("[UP] Je dois apprendre à jouer le raccourci control + ", ev.key)
      switch(ev.key){
      case 'v':
      }
      return stopEvent(ev)
    } else if ( ev.metaKey ) {
    }
    return true
  }
}
window.onkeypress = KeyboardEventManager.onPress
window.onkeydown  = KeyboardEventManager.onDownCommon
window.onkeyup    = KeyboardEventManager.onUpCommon
