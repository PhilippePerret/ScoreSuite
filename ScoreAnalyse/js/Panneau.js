'use strict';

class Panneau {

  constructor(id){
    this.id = id
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
    this.obj || this.build()
    this.obj.classList.remove('hidden')
    this.isOpened = true
    'function' == typeof this.onOpen  && this.onOpen()
  }
  hide(){
    this.obj.classList.add('hidden')
    UI.reactiveCurrentShortcuts()
    this.isOpened = false
    'function' == typeof this.onClose && this.onClose()
  }

  observe(){
    listen(this.obj, 'click', (e)=>{e.stopPropagation();return true})
  }

  get obj(){
    return this._obj || (this._obj = DGet('#'+this.id))
  }
  set obj(v){ this._obj = v }
  
}
