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
    this.vignettes = []
    let largeur = this.container.offsetWidth
    while ( (largeur - RESTE_SECU) > 0 ) {
      this.vignettes.push(this.buildVignette())
      largeur -= MINIATURE_WIDTH + MINIATURE_GUTTER;
    }
  }
  static buildVignette(){
    const vig = new Vignette(this, {droppable: true})
    vig.build()
    return vig
  }


  /**
  * Quand on remonte les informations sur la partition courante, 
  * on affiche ici les pages de la partition originale
  * 
  * @param pagesRelpaths [Array<String>] Liste des chemins 
  *     relatif (dossier/fichier) aux pages du score
  *   
  */
  static setPages(main_folder, pagesRelpaths) {
    let vig;
    for ( var iPage in this.vignettes ) {
      vig     = this.vignettes[iPage]
      const relpath = pagesRelpaths[iPage]
      if ( relpath ) {
        vig.image = main_folder + '/' + relpath
      } else {
        vig.unset()
      }
    }
    // On affiche la première
    this.vignettes[0].affiche()
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

