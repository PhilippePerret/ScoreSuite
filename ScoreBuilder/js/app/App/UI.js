'use strict';

class UI {
  static prepare(){
    
    this.espaceButtonTitle()

    // Redimensionner pour prendre tout l’écran
    window.resizeTo(screen.width, screen.height)

    listen(this.btnBuild, "click", this.onClickBuild.bind(this))
    listen(this.btnManual,'click', this.onClickManual.bind(this))

  }

  /**
  * Méthode appelée pour ouvrir le manuel
  */
  static onClickManual(ev){
    window.open("Manuel","../ScoreImage/Manuel/Manuel_MusicScore.pdf")
    return stopEvent(ev)
  }
  /**
  * Méthode appelée quand on clique sur le bouton "Build" pour
  * forcer la construction de la partition.
  */
  static onClickBuild(ev){
    stopEvent(ev)
    MusCode.saveAndEvaluateCode()
    return false
  }
  // Le bouton de construction
  static get btnBuild(){return DGet("#btn-build")}
  static get btnManual(){return DGet("#btn-manual")}

  /**
  * Pour que la souris ne masque pas le début du title des boutons
  */
  static espaceButtonTitle(){
    document.querySelectorAll('button').forEach(button => {
      if ( button.title ) {
        button.title = '      ' + button.title
      }
    })
  }
}
