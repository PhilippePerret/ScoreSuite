'use strict';
/**
 * Constance ImgScore pour gérer l'image de la partition
 * 
 * (ou "les" images car il peut y en avoir plusieurs)
 */
class ImgScoreClass {

constructor(){
  this.size = 100
}

/**
 * Après l'actualisation de la partition, on remet
 * le conteneur de partition en l'état
 * (zoom et scrolling)
 * 
 * @param data {Hash}
 *          :scrollTop
 */
setScoreContainer(data){
  this.setZoomOnUpdate()
  this.container.scrollTop = data.scrollTop
}

/**
 * Méthode appelée à chaque changement/rafraichissement d'image
 */
setZoomOnUpdate(){
  console.log("-> setZoomOnUpdate / size = %i %", this.size)
  this.changeSize(this.size) 
}

/**
 * Méthodes pour aggrandir et diminuer
 * 
 */
augmenteSize(){
  this.changeSize(this.size += 5)
}
diminueSize(){
  this.changeSize(this.size -= 5)
}

changeSize(val){
  val = val || this.size
  this.container.querySelectorAll('img').forEach(img => {
    img.style.width = val + '%'
  })
}

get container(){
  return this._conteneur || (this._conteneur = DGet('section#score_container'))
}

}//ImgScoreClass
const ImgScore = new ImgScoreClass()
