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
    // console.log("-> setMusCode avec ", code)
    const decoupe = Options.extractOptionsFrom(code)
    let [codeNotes, options] = decoupe
    Options.setValues(options)
    this.field.value = codeNotes
  }


  /* === Text Methods === */

  /**
  * @param offback [Number] Décalage (mettre en négatif pour remonter)
  */
  static insertAtCursor(what, offback) {
    this.textarea.insertAtCursor(what, offback)
  }
  static get textarea(){
    return this._textarea || (this._textarea = new Textarea(this.field))
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
    case 'o':
      if ( this.ControlOn ) { return stopEvent(ev) }
      break
    case "s" : case "b" :
      if ( this.MetaOn ) {
        // = SAUVEGARDER = 
        // (= construire)
        stopEvent(ev)
        this.saveAndEvaluateCode()
        return false
      } else if ( this.ControlOn ) {
        // Raccourci pour placer une "blanche" => 2
        stopEvent(ev)
        return "2"
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
    case 'b':
      if ( this.ControlOn ) {stopEvent(ev); this.insertAtCursor("2"); return false }
      break
    case 'c':
      // Raccourci pour "croche" => 8
      if ( this.ControlOn ) {
        if ( this.lastLetter == 'o') {
          stopEvent(ev); this.insertAtCursor("8{}", -1); return false
        } else {
          stopEvent(ev); this.insertAtCursor("8"); return false
        }
      }
      break
    case 'd':
      if ( this.ControlOn ) {stopEvent(ev); this.insertAtCursor("16"); return false }
      break
    case 'n':
      if ( this.ControlOn ) {stopEvent(ev); this.insertAtCursor("4"); return false }
      break
    case 'o':
      if ( this.ControlOn ) { 
        this.lastLetter = 'o'
        return stopEvent(ev) 
      }
      break
    case 't':
      if ( this.ControlOn ) {stopEvent(ev); this.insertAtCursor("32"); return false }
      break    
    default:
      // console.info("Touche relevée :", ev.key)
    }
    this.lastLetter = ev.key
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
