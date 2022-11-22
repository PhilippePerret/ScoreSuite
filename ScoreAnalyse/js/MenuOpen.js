'use strict';
/**

  class OpenTool
  --------------
  Gestion du menu "Ouvrir"

*/
class OpenMenu extends MenusTool {

  static onActivate_prefs(){
    console.log("Je dois apprendre à ouvrir les préférences")

  }

  static onActivate_manual(){
    console.log("Je dois apprendre à ouvrir le manuel d'utilisation")    
  }

  static onActivate_infosAnalyse(){
    Analyse.togglePanneau.call(Analyse)
  }

  static onActivate_toolsPanel(){
    Tools.togglePanneau.call(Tools)
  }



}
