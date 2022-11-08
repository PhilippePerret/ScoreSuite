'use strict';

class Panneau {

  constructor(id){
    this.id = id
  }

  toggle(){
    if ( this.opened ) {
      this.hide()
    } else {
      this.show()
    }
  }
  show(){
    UI.desactiveCurrentShortcuts()
    this.obj.classList.remove('hidden')
    this.opened = true
    this.observe()
    'function' == typeof this.onOpen && this.onOpen()
  }
  hide(){
    this.obj.classList.add('hidden')
    UI.reactiveCurrentShortcuts()
    this.opened = false
    // this.unobserve()
    'function' == typeof this.onClose && this.onClose()
  }

  observe(){
    listen(this.obj, 'click', (e)=>{e.stopPropagation();return true})
  }

  unobserve(){

  }

  get obj(){
    return this._obj || (this._obj = DGet('#'+this.id))
  }
  
}
