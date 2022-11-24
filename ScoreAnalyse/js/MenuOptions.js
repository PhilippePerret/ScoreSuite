'use strict';
/**

  Class OptionsTool
  -----------------
  Gestion du menu "Options"

*/
class OptionsTool extends MenusTool {


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
    AMark.vSnap = modeON ? pref('grid_vertical_space')   : null
    AMark.hSnap = modeON ? pref('grid_horizontal_space') : null
    AMark.bSnap = modeON ? pref('thiness_cellule_line')  : null
    option.dataset.checked = modeON ? 'true' : 'false' 
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
