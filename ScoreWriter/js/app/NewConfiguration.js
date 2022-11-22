'use strict';
/**


  class NewConfiguration
  ----------------------
  Gestion nouvelle des configurations

*/
class NewConfiguration {

  /**
  * Méthode appelée quand on change la disposition de l'interface
  */
  static onChangeDisposition(){
    UI.setDisposition.call(UI, this.menuDisposition.value)
  }

  /**
  * Méthode appelée lorsque l'on change la valeur du nombre de
  * portées.
  */
  static onChangeStaffCount(){
    console.debug("Je dois apprendre à régler le nombre de portées")
  }

  /**
  * Méthode appelée quand on change la métrique (pour gérer le champ
  * qui permet d'en mettre une "à la main")
  */
  static onChangeMetrique(){
    const isVisible = this.menuMetrique.value == 'xxx'
    this.fieldAutreMetrique.classList[isVisible?'remove':'add']('invisible')
  }

  /**
  * Méthode appelée par les boutons "Appliquer" et "Tout effacer et
  * appliquer"
  * Si +resetAll+ est true, il faut tout effacer.
  */
  static applyConfig(resetAll){
    console.debug("Je dois apprendre à appliquer les choix")

  }



  /* --- HTML Elements --- */

  static get menuMetrique(){
    return DGet('select#config-piece-metrique')
  }
  static get fieldAutreMetrique(){
    return DGet('input#config-piece-autre-metrique')
  }

  static get menuDisposition(){
    return DGet('select#config-ui-disposition')
  }

}
