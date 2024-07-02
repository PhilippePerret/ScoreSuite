'use strict';
/**
* Gestion de la partition originale
* 
* En bas de la fenêtre, on trouve différents container qui 
* permmettent de glisser les différentes pages de la partition 
* originale.
*/

class OriginalScore {

  /**
  * Préparation de l’application au niveau de l’affichage de la
  * partition originale.
  */
  static prepare(){

    // Hauteur du container
    this.container.style.height = px(window.innerHeight - 100)
    
    // Construction des vignettes de partition
    this.buildVignettes()

    // Contraintes sur page courante affichée
    this.containerCurrentPage.style.height = px(this.container.offsetHeight - 200)
  }

  static buildVignettes(){
    let largeur = this.container.offsetWidth
    while ( (largeur - 2 * MINIATURE_WIDTH) > 0 ) {
      this.buildVignette()
      largeur -= MINIATURE_WIDTH + MINIATURE_GUTTER;
    }
  }
  static buildVignette(){
    (new Vignette(this, {droppable: true})).build()
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
    return this._container || ( this._container = DGet('section#section-original-score'))
  }
}

