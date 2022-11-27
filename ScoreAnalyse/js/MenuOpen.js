'use strict';
/**

  class OpenTool
  --------------
  Gestion du menu "Ouvrir"

*/
class OpenMenu extends MenusTool {

  static onActivate_prefs(){
    Preferences.toggle.call(Preferences)
  }

  static onActivate_manual(){
    Manuel.toggle.call(Manuel)
  }

  static onActivate_infosAnalyse(){
    Analyse.togglePanneau.call(Analyse)
  }

  static onActivate_toolsPanel(){
    Tools.togglePanneau.call(Tools)
  }

  static onActivate_exportToHTML(){
    Analyse.exportCurrentToHtml()
  }

}
