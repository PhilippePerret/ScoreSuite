'use strict';
/**

  Classe BordersTool
  ------------------

  Pour gérer le menu "Bords" du pied de page, qui permet d'affiner
  les bords des éléments qui en contiennent (les cadres, les seg-
  ments, etc.)

**/

class BordersTool {

  static get menu(){
    return this._menu || (this._menu = DGet('select#borders_tool'))
  }

  static init(){
    this.observe()
  }

  static observe(){
    listen(this.menu,'change', this.onActiveMenu.bind(this))
  }

  static onActiveMenu(e){
    const action = this.menu.value
    const classe = this.menu.options[this.menu.selectedIndex].dataset.css
    this.menu.selectedIndex = 0

    const tag = AObjet.selection[0]
    /*
    |  Ajout ou retrait de la classe du tag
    */
    tag.obj.classList[action](classe)
    /*
    |  Enregistrement dans les données du tag
    */
    tag[action+"Css"](classe)
    Analyse.current && Analyse.current.setModified()
    /*
    |  Actualisation du menu des bords pour ce tag
    */
    this.setMenuBordsFor(tag)
    /*
    |  Alerte (console) pour dire qu'on n'affecte que la première
    |  selection.
    */
    if ( not(this.alertOnlyFirstSelectionDone) ) {
      console.info("Par mesure de prudence, je n'applique ce choix qu'à la première sélection possible.")
      this.alertOnlyFirstSelectionDone = true
    }

  }

  /**
   * Méthode appelée par les méthodes AObjet@selection pour régler
   * les menus "Bords" en fonction du premier tag sélectionné
   * 
   **/
  static setMenuBordsFor(tag){
    if ( tag ) {
      const o = tag.obj ;
      ['left','right','top','bottom'].forEach( dir => {
        const classe = `no_${dir}_border`
        const optAdd = DGet('option[value="add"][data-css="'+classe+'"]', this.menu)
        const optRem = DGet('option[value="remove"][data-css="'+classe+'"]', this.menu)
        optAdd.disabled = o.classList.contains(classe)
        optRem.disabled = not(o.classList.contains(classe))
      })
      this.activate()
    } else {
      this.desactivate()
    }
  }

  /**
  * Appelée par exemple par AObjet quand il n'y a plus de sélection
  */
  static desactivate(){
    this.menu.disabled = true
  }
  static activate(){
    this.menu.disabled = false 
  }


}
