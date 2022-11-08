'use strict';
/**
 * Gestion des touches de clavier
*/

class KeyboardControlerClass {

commonOnKeyUp(ev){
  // console.log("key event : ", ev)
  if ( ev.key == 'Tab' ) {
    /**
     * La touche tabulation est toujours captée, pour éviter le
     * comportement par défaut qui sélectionne l'adresse.
     */
    // console.log("[UP] Tabulation")
    // 
    // Si un panneau est ouvert, on respecte le comportement par
    // défaut, sinon, on passe à la mesure suivante
    // 
    if ( Onglet.current ) {
      // console.log("Un panneau est ouvert. Je ne passe pas à la mesure suivante.")
      return true
    } else {
      ev.preventDefault()
      MesureCode.current && MesureCode.current.focusNextField()
    }
  }
}

commonOnKeyDown(ev){
  // console.log("key down event : ", ev)
  if ( ev.metaKey && ev.key == 'b') {
    console.info("🎹 ⌘ B")
    /**
     * 
     * On soumet le code pour fabriquer la nouvelle image
     * 
     */
    App.submitCode()
    return stopEvent(ev)
  } else if ( ev.key == 'Tab') {
    /**
     * La touche tabulation est toujours captée, pour éviter le
     * comportement par défaut qui sélectionne l'adresse.
     * 
     * Sauf quand un panneau est ouvert
     */
    if ( !Onglet.current ) ev.preventDefault()
  }
}

}//KeyboardControlerClass

const KeyboardController = new KeyboardControlerClass()

window.onkeyup = KeyboardController.commonOnKeyUp ;
window.onkeydown = KeyboardController.commonOnKeyDown ;
