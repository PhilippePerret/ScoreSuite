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
    listen(this.btnClose,'click', this.onClickCloseButton.bind(this))    
  }


  static onClickCloseButton(ev){
    stopEvent(ev)
    this.close()
    return false
  }


  static open(){
    this.panneau.classList.remove('hidden')
  }
  static show(){return this.open()}
  static close(){
    this.panneau.classList.add('hidden')
  }


}