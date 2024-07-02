'use strict';
/**
* Gestion du code Mus
* 
*/
class MusCode {

  static prepare(){

    // Mettre le textarea aux bonnes dimensions
    this.redimTextarea()
    // Surveiller le textarea
    listen(this.field,'change',this.onTextChange.bind(this))
    listen(this.field,'keydown', this.onKeyDown.bind(this))
    listen(this.field,'keyup', this.onKeyUp.bind(this))
    listen(this.field,'focus', this.onFocus.bind(this))
    listen(this.field,'blur', this.onBlur.bind(this))
  }

  // === Functional Methods ===

  // Pour sauver le code, le faire évaluer et l’afficher
  static saveAndEvaluateCode(){
    WAA.send({
      class: "ScoreBuilder::MusCode", method: "save_and_evaluate",
      data: {code: this.getMusCode()}
    })
  }
  /**
   * Retour de l’enregistrement et de l’évaluation
   * 
   * Notamment, la méthode remonte les images produites
   */
  static onSavedAndEvaluated(waaData){
    console.log("Retour Waa :", waaData)
    ScoreViewer.setVignettes(waaData)
  }

  static getMusCode(){
    /**
    * TODO Ajouter les options, qui seront sous forme de case à
    * cocher et de menu
    */
    return this.field.value
  }
  static setMusCode(code){
    /**
    * TODO Il faudrait prendre les options pour les mettre dans le
    * tableau des options, pas dans le code
    */
    this.field.value = code
  }

  // === Gestion des évènements ===

  // Quand on entre dans le champ de texte
  static onFocus(ev){

  }
  // Quand on quitte le champ de texte
  static onBlur(ev){

  }
  // Quand on presse une touche
  static onKeyDown(ev){
    switch(ev.key){
    case "Meta":      this.MetaOn     = true ; break
    case "Alt" :      this.OptionOn   = true ; break
    case "Control" :  this.ControlOn  = true ; break
    case "Shift" :    this.ShiftOn    = true ; break
    case "s" : case "b" :
      if ( this.MetaOn ) {
        // = SAUVEGARDER = 
        // (= construire)
        stopEvent(ev)
        this.saveAndEvaluateCode()
        return false
      }
      break
    default:
      console.info("Touche pressée :", ev.key)
    }
  }
  // Quand on relève la touche
  static onKeyUp(ev){
    switch(ev.key){
    case "Meta": this.MetaOn    = false ; break
    case "Alt" : this.OptionOn  = false ; break
    case "Control" : this.ControlOn = false ; break
    case "Shift" : this.ShiftOn = false ; break
    default:
      console.info("Touche relevée :", ev.key)
    }
  }
  static onTextChange(ev){
    console.warn("Je dois apprendre à gérer le changement de texte.")
    return stopEvent(ev)
  }

  // Redminsionnement du champ de code (en hauteur)
  static redimTextarea(){
    this.field.style.height = px(window.innerHeight - 100)
  }

  static get field(){
    if ( !this._field ) { this._field = DGet('#mus-code') }
    return this._field
  }
}
