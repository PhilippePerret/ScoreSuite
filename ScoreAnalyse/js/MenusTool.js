'use strict';
/**

  class MenusTool
  ---------------
  Classe abstraite pour tous les menus du footer.

  REQUIS
  ------

  * 'Class MenusTool' => menu ID 'menus_tool'
    Le <select> doit avoir un ID qui correspond à la décamelisation
    du nom de la classe. 
    Dans le cas contraire, 'static get menuId' doit retourner cet ID

  * <option value="maMethode"> => ClassTool.onActivate_maMethode(e, option)
    Chaque <option> doit définir l'attribut 'value' qui déterminera
    la fonction à appeler dans la classe. Si 'value="selectAll"'
    alors la classe fille devra implémenter la méthode 
    OnActivate_selectAll qui sélectionnera tout.

  * static beforeActivate(e, <option>)
    Si elle existe, cette méthode sera appelée avant d'appeler la
    méthode opératrice, avec le menu sélectionné.

  * static afterActivate(e, <option>)
    Si elle existe, cette méthode sera appelée après avoir appelé la
    méthode opératrice et la méthode précédente, avec l'évènement et
    le menu (option) sélectionné.

*/
class MenusTool {
  
  static init(){
    this.observe()
  }

  static observe(){
    listen(this.menu, 'change', this.onActivateTool.bind(this))
  }

  static get menu(){
    return this._menu || (this._menu = DGet(`select#${this.menuId || this.name.replace(/(.)([A-Z])/g,'$1_$2').toLowerCase()}`))
  }

  /* --- Gestionnaires d'évènements --- */

  static onActivateTool(e){
    // Méthode générale qui reçoit le choix d'un outil dans le menu
    const tool = this.menu.value
    const option = this.menu.options[this.menu.selectedIndex]
    if ( tool == '' ) return // sécurité
    /*
    |  Méthode appelée avant chaque menu (if any)
    */
    this.beforeActivate(e, option)
    /*
    |  Méthode opératrice
    */
    if ( 'function' == typeof this["onActivate_"+tool] ) {
      this["onActivate_"+tool].call(this, e, option)
    } else {
      console.error("La méthode %s::onActivate_%s doit être définie.", this.name, tool)
    }
    /*
    |  Méthode appelée après chaque menu (if any)
    */
    this.afterActivate(e, option)
    /*
    |  On referme le menu
    */
    this.menu.selectedIndex = 0
  }


  /* --- Default Methods --- */
  static beforeActivate(){}
  static afterActivate(){}
}
