'use strict';
/**

  Class OptionsTool
  -----------------
  Gestion du menu "Options"

*/
class OptionsTool extends MenusTool {

  static init(){
    super.init()
    Cancel.zMenu = DGet('option[value="cancel"]', this.menu)
  }


  /* --- Gestionnaires d'évènement menu ---  */

  static onActivate_toggleColor(e, option){
    var colorMode = not(option.dataset.checked == 'true')
    Analyse.current && Analyse.current.toggleModeColor(colorMode)
    option.dataset.checked = colorMode ? 'true' : 'false'
  }

  static onActivate_toggleGrid(e, option){
    /**
     ** Appelée quand on active ou désactive le menu d'alignement
     ** sur la grille. 
    **/
    var modeON = not(option.dataset.checked == 'true')
    AMark.toggleGridMode(modeON)
    option.dataset.checked = modeON ? 'true' : 'false'
    UI.toggleGridDisplay(modeON)
  }

  static onActivate_cancel(e, option){
    Cancel.zLast(e)
  }
  static onActivate_cancelInList(e, option) {
    Cancel.zInList(e)
  }
  /**
  * Appelée après chaque choix de menu, cette méthode permet
  * de changer le nom pour activer ou désactiver l'option.
  */
  static afterActivate(e, option){
    if ( option.dataset.role != 'cb' ) return
    var text = option.innerHTML
    text = text.substring(1, text.length)
    text = (option.dataset.checked == 'true' ? '☒' : '☐') + text
    option.innerHTML = text
  }
}
