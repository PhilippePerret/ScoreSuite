'use strict';
class LigneCoupe {

  static createAt(top){
    const ligne = new LigneCoupe({top:top})
    ligne.build_and_observe()
  }


  constructor(data){
    this.data = data
    this.top = data.top
  }


  build_and_observe(){
    this.build()
    this.observe()
  }

  build(){
    const o = document.createElement('DIV')
    o.className = 'ligne_coupe'
    o.style.top = px(this.top)
    document.body.appendChild(o)
    this.obj = o
  }

  observe(){
    $(this.obj).draggable({
      axis: 'y'
    })
  }
}
