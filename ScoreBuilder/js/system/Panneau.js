'use strict';

/**
* Contrairement à Panel.js, cette classe utilise un div existant
* déjà dans le DOM et ne sert qu’à faire les opérations de base
* comme l’ouverture ou la fermeture
* 
* Doivent être définis :
* 
*   this.panneau
*   this.btnClose
*/
class Panneau {

  static watch(){
    if ( this.btnClose ) {
      listen(this.btnClose,'click', this.onClickCloseButton.bind(this))    
    }
  }

  static onClickCloseButton(ev){
    stopEvent(ev)
    this.close()
    return false
  }

  static toggle(){
    if (this.isOpened) {
      this.close()
    } else {
      this.open()
    }
  }

  static open(){
    this.panneau.classList.remove('hidden')
    if ( 'function' == typeof this.onOpen ) {
      this.onOpen()
    }
  }
  static show(){return this.open()}
  static close(){
    this.panneau.classList.add('hidden')
  }

  static get isOpened(){
    return !this.panneau.classList.contains('hidden')
  }
}
