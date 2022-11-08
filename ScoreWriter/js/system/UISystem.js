class UISystemClass {

  // Pour afficher le message +msg+
  showMessage(msg, options){ this.showText(msg,'notice', options) }
  // Pour afficher une erreur (utiliser la méthode 'error')
  showError(err, options){   this.showText(err,'error', options) }
  // Pour afficher un message d'action
  showAction(msg, options){  this.showText(msg, 'doaction', options) }

  showText(str,type, options){
    options = options || {}
    this.clearTimerMessage()
    this.panneauMessage.innerHTML = str
    this.panneauMessage.className = type
    this.panneauMessage.classList.remove('hidden')
    if ( !( type == 'error' || options.keep) ) this.msgTimer = setTimeout(this.hideMessage.bind(this),6*1000)
  }

  hideMessage(){
    this.panneauMessage.innerHTML = ""
    this.panneauMessage.classList.add('hidden')
    this.clearTimerMessage()
  }

  clearTimerMessage(){
    if ( this.msgTimer ){
      clearTimeout(this.msgTimer)
      this.msgTimer = null
    }
  }

  get panneauMessage(){
    return this._msgpanel || (this._msgpanel = document.querySelector('div#message'))
  }

}
const UISystem = new UISystemClass()
