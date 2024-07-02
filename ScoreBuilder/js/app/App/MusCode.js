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
    // => [String] Options les unes au-dessous des autres
    //    (à mettre au-dessus du code)
    WAA.send({
      class: "ScoreBuilder::MusCode", method: "save_and_evaluate",
      data: {code: this.getMusCode(), mus_file: this.mus_file_path}
    })
  }
  /**
   * Retour de l’enregistrement et de l’évaluation
   * 
   * Notamment, la méthode remonte les images produites
   */
  static onSavedAndEvaluated(waaData){
    // console.log("Retour Waa :", waaData)
    if (waaData.ok) {
      ScoreViewer.setVignettes(waaData)
      UI.setNameBackupButton(waaData.nb_backups)
    } else {
      erreur(`Un problème est survenu : ${waaData.error}. Consulter le retour.`)
      console.error(waaData)
    }
  }

  static getMusCode(){
    const options = Options.getValues()
    return options + "\n\n" + this.field.value
  }

  static setMusCode(code){
    console.log("-> setMusCode avec ", code)
    const decoupe = Options.extractOptionsFrom(code)
    console.log("decoupe = ", decoupe)
    let [codeNotes, options] = decoupe
    console.log("codeNotes = ", codeNotes)
    console.log("options = ", options)
    Options.setValues(options)
    this.field.value = codeNotes
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
      // console.info("Touche pressée :", ev.key)
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
      // console.info("Touche relevée :", ev.key)
    }
  }
  static onTextChange(ev){
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
