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
  * Pour définir les vignettes courantes
  */
  static setVignettes(waaData) {
    let vignette, imgName, imgPath ;
    for ( var iVign in this.vignettes ) {
      vignette  = this.vignettes[iVign]
      imgName   = waaData.svgs[iVign]
      if ( imgName ) {
        // Cette image existe, on définit la vignette
        imgPath   = `${waaData.folder}/${waaData.affixe}/${imgName}`
        imgPath   = imgPath.replace(/ /,'\ ')
        vignette.image = imgPath
      } else {
        // Pas d’image pour cette vignette
        vignette.unsetImage()
      }
    }
    // On affiche la dernière
    this.current = imgPath
  }


  // Pour définir l’image courante
  static set current(path){
    console.info("Path image courante : ", path)
    this.imgCurrentPage.src = path
  }


  static buildVignettes(){
    this.vignettes = []
    let largeur = this.container.offsetWidth
    while ( (largeur - 2 * MINIATURE_WIDTH) > 0 ) {
      this.vignettes.push(this.buildVignette())
      largeur -= MINIATURE_WIDTH + MINIATURE_GUTTER;
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
