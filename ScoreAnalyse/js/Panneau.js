'use strict';

class Panneau {

  constructor(owner){
    this.owner = owner
    this.id = owner.panneauId || raise(`${this.constructor.name} faut définir l'ID du panneau (<owner>.panneauId)`)
  }

  toggle(){
    if ( this.isOpened ) {
      this.hide()
    } else {
      this.show()
    }
  }
  togglePanel(){
    return this.toggle()
  }

  show(){
    UI.desactiveCurrentShortcuts()
    if ( 'function' == typeof this.owner.onKeyPress) { window.onkeypress = this.owner.onKeyPress.bind(this)}
    this.obj || this.owner.build()
    this.obj.classList.remove('hidden')
    this.isOpened = true
    'function' == typeof this.owner.onOpen  && this.owner.onOpen()
  }
  hide(){
    this.obj.classList.add('hidden')
    UI.reactiveCurrentShortcuts()
    this.isOpened = false
    'function' == typeof this.owner.onClose && this.owner.onClose()
  }

  observe(){
    listen(this.obj, 'click', (e)=>{e.stopPropagation();return true})
  }

  get obj(){
    return this._obj || (this._obj = DGet('#'+this.id))
  }
  set obj(v){ this._obj = v }
  
}
