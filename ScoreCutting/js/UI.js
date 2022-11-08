'use strict';
class UIClass {

  showBoutonsConfirmation(){
    UI.showButtonConfirmer()
    UI.showButtonRenoncer()    
  }
  hideBoutonsConfirmation(){
    UI.hideButtonConfirmer()
    UI.hideButtonRenoncer()
  }

  showButtonConfirmer(){
    this.btnConfirmer.classList.remove('invisible')
    this.btnConfirmer.classList.remove('inactif')
    this.btnDecouper.classList.add('inactif')
  }
  hideButtonConfirmer(){
    this.btnConfirmer.classList.add('invisible')
    this.btnConfirmer.classList.add('inactif')
    this.btnDecouper.classList.remove('inactif')
  }
  showButtonRenoncer(){this.btnRenoncer.classList.remove('invisible')}
  hideButtonRenoncer(){this.btnRenoncer.classList.add('invisible')}


  // Retourne le numéro du premier système voulu
  getNumberOfFirstSystem(){
    return Number(this.firstNumberField.value || 1)

  }

  // Pour placer le panneau d'information avec le texte +texte+
  showInformation(texte){
    this.panneauInformation.querySelector('.content').innerHTML = texte
    this.panneauInformation.classList.remove('hidden')
  }
  hidePanneauInformation(){
    this.panneauInformation.classList.add('hidden') 
  }

  // Pour afficher le message +msg+
  showMessage(msg){ this.showText(msg,'notice') }
  // Pour afficher une erreur (utiliser la méthode 'error')
  showError(err){   this.showText(err,'error') }
  // Pour afficher un message d'action
  showAction(msg){  this.showText(msg, 'doaction') }

  showText(str,type){
    this.clearTimerMessage()
    this.panneauMessage.innerHTML = str
    this.panneauMessage.className = type
    this.panneauMessage.classList.remove('hidden')
    if ( type !== 'error') this.msgTimer = setTimeout(this.hideMessage.bind(this),20*1000)
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

  // Appelée quand on double-clic sur la partition
  onDoubleClickOnScore(e){
    //console.log("e = ", e)
    LigneCoupe.createAt(e.layerY) // PAS : clientY
    e.stopPropagation()
    e.preventDefault()
    return false
  }

  // Retourne les lignes de coupe
  getTopsOfLignesCoupe(){
    var ls = []
    document.querySelectorAll('div.ligne_coupe').forEach(div => {
      ls.push(unpx(div.style.top) - 20 /* padding-top de body */) 
    })
    return ls.sort(function(a, b) {return a - b});
  }

  /**
   * Détruit toutes les lignes
   */
  removeAllLines(){
    document.querySelectorAll('div.ligne_coupe').forEach(div => {
      div.remove()
    })    
  }


  get btnDecouper(){
    return this._btncrop || (this._btncrop = document.querySelector('button#decouper'))
  }
  get btnConfirmer(){
    return this._btnconfirm || (this._btnconfirm = document.querySelector('button#confirmer_decoupe'))
  }
  get btnRenoncer(){
    return this._btncancel || (this._btncancel = document.querySelector('button#renoncer_decoupe'))
  }
  get score(){return this._score || (this._score = document.querySelector('img#score'))}
  get codeField(){
    return this._codefield || (this._codefield = document.querySelector('textarea#code_decoupe'))
  }
  get firstNumberField(){
    return this._firstnum || (this._firstnum = document.querySelector('input#num_first_system'))
  }
  get panneauInformation(){
    return this._infopanel || (this._infopanel = document.querySelector('div#panneau_information'))
  }
  get panneauMessage(){
    return this._msgpanel || (this._msgpanel = document.querySelector('div#message'))
  }

}
const UI = new UIClass()
