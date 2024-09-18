'use strict';
/**
* Gestion du viewer de partition finale
* 
* La partition originale se présente sous forme d’onglet, comme les
* vignettes dans Aperçu, qu’on peut cliquer pour voir les différentes
* pages.
* 
*/
class ScoreViewer {

  /**
  * Préparation de l’application au niveau du viewer
  */
  static prepare(){
    // Hauteur du container
    this.container.style.height = px(window.innerHeight - 100)
    
    // Construction des vignettes de partition
    this.buildVignettes()

    // Contraintes sur page courante affichée
    this.containerCurrentPage.style.height = px(this.container.offsetHeight - 200)

  }

  /**
  * Pour (re)définir les vignettes courantes
  * 
  * @note
  *   La méthode est aussi appelée quand on actualise le code (c’est
  *   -à-dire quand on l’enregistre et qu’il se réactualise)
  */
  static setVignettes(waaData) {
    let lastFilledVignette, vignette, imgName, imgPath ;
    for ( var iVign in this.vignettes ) {
      vignette  = this.vignettes[iVign]
      imgName   = waaData.svg_images[iVign]
      if ( imgName ) {
        // Cette image existe, on définit la vignette
        imgPath   = `${waaData.folder}/${waaData.affixe}/${imgName}`
        imgPath   = imgPath.replace(/ /,'\ ')
        vignette.image = imgPath
        lastFilledVignette = vignette
      } else {
        // Pas d’image pour cette vignette
        vignette.unset()
      }
    }
    /**
    * Affichage de la vignette courante
    * Soit la dernière si c’est un premier chargement et qu’il 
    * existe une dernière vignette, soit la vignette courante, c’est-
    * à-dire la vignette affichée au moment du rechargement.
    * 
    */
    if ( this.currentVignette ) {
      this.currentVignette.affiche()
    } else if ( lastFilledVignette ) {
      lastFilledVignette.affiche()
    } else {
      // Sinon on ne fait rien
    }
  }


  static buildVignettes(){
    this.vignettes = []
    // let largeur = this.container.offsetWidth
    // while ( (largeur - RESTE_SECU) > 0 ) {
    for (var i = 0; i < 10 ; ++i ) {
      this.vignettes.push(this.buildVignette())
      // largeur -= MINIATURE_WIDTH + MINIATURE_GUTTER;
    }
  }
  static buildVignette(){
    const vig = new Vignette(this, {droppable: false})
    vig.build()
    return vig
  }


  static get imgCurrentPage(){
    return this._imgcurpage || (this._imgcurpage = DGet('img.current-page', this.containerCurrentPage))
  }
  static get containerCurrentPage(){
    return this._contcurpage || (this._contcurpage = DGet('div.container-current-page', this.container))
  }
  static get vignettesContainer(){
    return this._vcontainer || (this._vcontainer = DGet('div.vignettes-container',this.container))
  }
  static get container(){
    return this._container || ( this._container = DGet('section#section-viewer'))
  }

}
