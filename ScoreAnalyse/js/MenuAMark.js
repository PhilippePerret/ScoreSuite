'use strict';

class AmarkMenu extends MenusTool {

  static init(){
    super.init()
    this.setAllMenus(false)
  }


  static setAllMenus(state){
    this.menu.disabled = not(state)
    const nombreMenus = this.menu.options.length - 1
    for(var i = 1; i < nombreMenus ; ++i){
      this.menu.options[i].disabled = not(state)
    }
    /*
    |  Réglage du menu "Verrouiller/déverouiller"
    */
    var enableLock = true
    this.selection.forEach( tag => {
      if ( tag.isLocked ) enableLock = false
    })
    const mark = this.selection.length > 1 ? 'les marques' : 'la marque'
    this.menuLock.innerHTML = `${enableLock ? 'Verrouiller' : 'Déverrouiller'} ${mark}`
    this.menuLock.dataset.ope = enableLock ? 'lock' : 'unlock'
  }

  static get selection(){ return AObjet.selection || []}
  static boucle(methode){
    AObjet.eachSelection(methode)
  }

  static onActivate_toogleLock(){
    /** Verrouiller ou déverrouiller les marques sélectionnées **/
    const ope = this.menuLock.dataset.ope
    this.boucle(tag => { tag[ope].call(tag) })
    this.setAllMenus()
  }


  static get menuLock(){
    return DGet('option[value="toogleLock"]', this.menu)
  }
}