'use strict';
/**

  Class OptionsTool
  -----------------
  Gestion du menu "Options"

*/
class OptionsTool extends MenusTool {


  /* --- Gestionnaires d'évènement menu ---  */

  static onActivate_toggleColor(e, option){
    console.debug("Je dois apprendre à passer en couleur")
    var colorMode = not(option.dataset.checked == 'true')
    Analyse.current && Analyse.current.toggleModeColor(colorMode)
    option.dataset.checked = colorMode ? 'true' : 'false'
  }

  /**
  * Appelée après chaque choix de menu, cette méthode permet
  * de changer le nom pour activer ou désactiver l'option.
  */
  static afterActivate(e, option){
    var text = option.innerHTML
    text = text.substring(1, text.length)
    text = (option.dataset.checked == 'true' ? '☒' : '☐') + text
    option.innerHTML = text
  }
}
