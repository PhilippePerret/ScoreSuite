'use strict';

class AppClass {

  /**
   * Méthode appelée au chargement de l'application pour savoir
   * si une analyse est en cours
   */
  load_analyse_if_exist(){
    WAA.send({
      id:'ANAGetIfExist',
      class:'ScoreAnalyse::Analyse',
      method:'get_analyse_if_exist'
    })
  }

  /**
   * Si une analyse est en cours, cette méthode reçoit les éléments
   */
  onload_analyse(data){
    console.debug("DATA REMONTÉES :", data)
    if (data) {
      var analyse = new Analyse(data)
      Preferences.setValuesSaved(data.preferences)
      analyse.checkSystems()
      analyse.display()
      analyse.scrollToLastPosition()
      Preferences.afterLoadingAnalyse()
    } else {
      console.log("Pas d'analyse courante à afficher.")
    }
  }

  onError(data){
    /**
     ** Pour remonter une erreur depuis le serveur
     **/
    erreur(data.error)
  }

}
const App = new AppClass()

window.onresize = function(){
  if ( Analyse.current ) {
    Analyse.current.defineWindowSize(window.outerWidth, window.outerHeight)
  }
}
