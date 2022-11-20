'use strict';
/**

  class SelectionTool
  -------------------
  Classe associée au menu "Sélection" du pied de page

  POUR AJOUTER UN OUTIL
  ---------------------
    - créer son <option> dans le menu #selection_tool (footer de index.html)
    - lui donner une @value adéquate
    - créer la méthode statique SelectionTool::onActive_<@value> pour 
      définir ce que doit faire l'outil.

  TODO
  ----

  (Selection)
  - quand on sélectionne un élément, on doit aussi sélectionner ses
    éléments associés (idem quand on le désélectionne)

**/
class SelectionTool {

  static init(){
    this.observe()
    this.toggleMenuGroupSelection(false)
    this.toggleMenuDegroupSelection(false)
  }

  static observe(){
    listen(this.menu, 'change', this.onActiveTool.bind(this))
  }

  /* --- HTML Methods --- */

  // {HTMLElement} Menu select du pied de page
  static get menu(){ 
    return this._menu || (this._menu = DGet('select#selection_tool'))
  }

  static get optionGroupSelection(){
    return this._optgrpsel || (this._optgrpsel = DGet('option[value="groupSelection"]', this.menu))
  }
  static get optionDegroupSelection(){
    return this._optdegrpsel || (this._optdegrpsel = DGet('option[value="degroupSelection"]', this.menu))
  }

  /* --- Gestionnaires d'évènements --- */

  static onActiveTool(){
    // Méthode générale qui reçoit le choix d'un outil dans le menu
    const tool = this.menu.value
    if ( tool == '…' ) return // sécurité
    this["onActive_"+tool].call(this)
    this.menu.selectedIndex = 0
  }

  static onActive_groupSelection(){
    const firstTag = AObjet.selection[0]
    const len = AObjet.selection.length
    for ( var i = 1; i < len; i++ ) {
      const tag = AObjet.selection[i]
      if ( not(firstTag.isGroupedWith(tag)) ) {
        firstTag.groupWith(tag)
      }
    }
    console.info("Les tags ont été associés.")
  }

  static onActive_degroupSelection(){
    AObjet.eachSelection(tag => {
      delete tag.grp
      tag.grp = null
    })
    console.info("Tous les objets sont dégroupés.")
  }

  static onActive_selectAll(){
    message("Je dois apprendre à sélectionner tous les éléments d'un certain type.")
  }

  /* --- Méthode concernant le groupement de tags --- */

  static toggleMenuGroupSelection(enabled = false){
    // Méthode publique permettant d'activer ou de désactiver le
    // choix "Grouper" (utilisé par la sélection)
    this.optionGroupSelection.disabled = not(enabled)
  }

  static toggleMenuDegroupSelection(enabled = false){
    this.optionDegroupSelection.disabled = not(enabled)
  }

}
