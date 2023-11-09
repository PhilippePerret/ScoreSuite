'use strict';

class UI {
  static prepare(){
    
    this.espaceButtonTitle()

    Styler.prepare()
    Score .prepare()

    this.watchDropper()
    this.watchImager()

    listen(this.btnPrint, "click", this.onPrint.bind(this))
    listen(this.btnNext,  "click", this.onNextSystem.bind(this))
    listen(this.btnOther, "click", this.onReqDropOther.bind(this))

  }

  /**
  * Quand on clique sur le bouton pour imprimer les numéros
  */
  static onPrint(){
    Score.current.printNumbers()
  }

  /**
  * Quand on clique sur le bouton pour (essayer de) passer au
  * système suivant
  */
  static onNextSystem(){
    WAA.send({class:"ScoreNumbering::Score", method:"get_next_system", data:{filename:Score.current.file.name}})
  }
  static onReturnNextSystem(waaData){
    if (waaData.ok) {
      Score.display({
          item: {type: "image/jpeg" }
        , file: {name: waaData.next_system }
      })
    } else {
      erreur(waaData.msg)
    }
  }

  static onReqDropOther(){
    this.hideImager()
    this.showDropper() 
  }


  static get btnPrint(){return DGet("#btn-print")}
  static get btnNext(){return DGet("#btn-next")}
  static get btnOther(){return DGet("#btn-other")}


  /* Le "Dropper", pour déposer l’image */
  static get dropper(){return DGet("#image-dropper")}
  static hideDropper(){this.dropper.style.display = "none"}
  static showDropper(){
    this.dropper.classList.remove("dropped")
    DGet("#system", this.imager).src = "blank.jpg"
    this.dropper.style.display = "block"
  }
  /**
  * Pour observer le "Dropper"
  */
  static watchDropper(){
    listen(this.dropper, "drop",      this.onDrop.bind(this))
    listen(this.dropper, "dragover",  this.onDragOver.bind(this))
    listen(this.dropper, "dragout",   this.onDragOut.bind(this))
  }
  static onDrop(ev){
    stopEvent(ev)
    Score.display(ev.dataTransfer)
    return false
  }
  static onDragOver(ev){
    stopEvent(ev)
    ev.dataTransfer.dropEffect = "move";
    this.dropper.classList.add("dropped")
  }
  static onDragOut(ev){
    stopEvent(ev)
    ev.dataTransfer.dropEffect = "stop";
    this.dropper.classList.remove("dropped")
  }

  /* L’"Imager" pour mettre l’image */
  static get imager(){return DGet("#image-container")}
  static hideImager(){this.imager.style.display = "none"}
  static showImager(){
    this.imager.style.display = "block"
  }
  /**
  * Observation de l’Imager
  */
  static watchImager(){
    listen(this.imager, "dblclick", this.onClickImager.bind(this))
  }
  /**
  * Méthode appelée quand on clique sur l’image du système
  */
  static onClickImager(ev){
    stopEvent(ev)
    console.log("ev = ", ev)
    console.log("Vous avez cliqué sur l’image")
    this.score.addMesureAt({x:ev.x, y: ev.y})
  }


  static set imageName(value){
    this._imagename = value
    DGet('#image-name').innerHTML = value
  }

  /**
  * Pour que la souris ne masque pas le début du title des boutons
  */
  static espaceButtonTitle(){
    document.querySelectorAll('button').forEach(button => {
      if ( button.title ) {
        button.title = '      ' + button.title
      }
    })
  }
}
