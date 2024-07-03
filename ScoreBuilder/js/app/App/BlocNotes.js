'use strict';


class BlocNotes extends Panneau {

  static prepare(){
    this.modeEdition = false
    this.notesLoaded = false
    this.current_index = null
    this.close()
    this.watch()
    this.observe()
  }


  // === Functional Methods ===

  /**
  * Méthode qui actualise l’affichage en fonction du nombre de notes
  * qui change, de l’index courant de la note, etc.
  * 
  * @note
  *   La méthode doit se suffire à elle-même, sans appeler d’autres
  *   méthode car on aurait un risque de stack-overflow (sauf quand
  *   on est sûr à 300 %)
  */
  static updateUI(){
    const isLastNote  = this.current_index == this.notes.length
    const isFirstNote = this.current_index == 1
    if ( isLastNote ) {
      this.btnNextNote.classList.add('invisible')
    } else {
      this.btnNextNote.classList.remove('invisible')
    }
    if ( isFirstNote ) {
      this.btnPrevNote.classList.add('invisible')
    } else {
      this.btnPrevNote.classList.remove('invisible')
    }
    this.setTitre()
  }

  static setTitre(){
    this.spanNbNotes.innerHTML = `(${this.current_index}/${this.notes.length})`
  }


  static loadNotes(){
    message("Patience, je charge les notes…", {keep:true})
    WAA.send({class:"ScoreBuilder::App",method:"load_notes",data:{}})
  }
  static onLoadedNotes(wdata){
    this.notesLoaded = true // même en cas d’erreur
    message('')
    if (wdata.ok){
      this.notes = []
      wdata.notes.forEach( note => this.notes.push(decodeURIComponent(note.replace(/\+/g,' '))))      
      this.showNoteByIndex(1)
      this.setTitre()
    } else {
      erreur(wdata.error)
    }
  }

  static observe(){
    listen(this.btnSave, 'click', this.onClickSave.bind(this))
    listen(this.btnAdd, 'click',  this.onClickAddNote.bind(this))
    listen(this.btnEdit, 'click', this.onClickEdit.bind(this))
    listen(this.btnSup, 'click',  this.onClickSup.bind(this))
    listen(this.btnPrevNote, 'click',  this.onClickBtnOtherNote.bind(this,-1))
    listen(this.btnNextNote, 'click',  this.onClickBtnOtherNote.bind(this,1))

    $(this.panneau).draggable()
  }



  // === Notes Methods ===

  /**
  * Affiche la note d’index +index+ (1-start)
  */
  static showNoteByIndex(index) {
    this.toggleMode(false)
    const note = this.notes[index - 1]
    this.reader.innerHTML = note
    this.current_index = Number(index)
    this.updateUI()
  }



  // === Event Methods ===


  static onClickBtnOtherNote(plus, ev){
    // @note : avec la touche META, on peut déplacer une note au 
    // lieu de passer à la suivante
    const pourDeplacement = ev.metaKey == true
    let note;
    stopEvent(ev)
    if ( pourDeplacement) {
      // Dans tous les cas, on prend la note
      note = this.notes.splice(this.current_index - 1, 1)
      let new_index = this.current_index - 1 + plus
      this.notes.splice(new_index, 0, note)
      this.current_index = new_index + 1
      this.save(false)
    } else {      
      this.current_index += plus // 1 ou -1
      this.showNoteByIndex(this.current_index)
    }
    return false
  }

  static onOpen(){
    if ( ! this.notesLoaded )
    this.notesLoaded || this.loadNotes()
  }

  /**
  * Méthode appelée quand on clique sur le bouton "Enregistrer"
  * 
  * Si on tient la touche META en clique sur le bouton "Save", on
  * ferme la fenêtre après l’enregistrement
  */
  static onClickSave(ev){
    stopEvent(ev)
    const new_texte = this.editor.value
    if ( this.current_index ) {
      this.notes[this.current_index - 1] = new_texte
    } else {
      this.notes.push(new_texte)
      this.current_index = this.notes.length
    }
    this.save(/*closeOnSave = */ ev.metaKey)
    return false
  }

  static save(closeOnSave){
    const encodedNotes = []
    this.notes.forEach(n => encodedNotes.push(encodeURIComponent(n)))
    const wdata = {closeOnSave:closeOnSave, notes: encodedNotes}
    WAA.send({class:"ScoreBuilder::App",method:"save_notes",data:wdata})
  }

  static onSavedNotes(wdata){
    if (wdata.ok) {
      if ( wdata.closeOnSave ) { 
        this.updateUI() // pour la prochaine ouverture
        this.close() 
      } else {
        // Si on ne doit pas fermer le bloc-notes, on affiche
        // la note courante
        this.showNoteByIndex(this.current_index)
      }
    } else {
      erreur(wdata.error)
    }
  }

  /**
  * Pour pallier le problème lorsque l’user a demandé une suppression
  * mais qu’il ne l’a pas validé, pour que la prochaine suppression
  * se fasse aussi avec confirmation
  */
  static clearSupTime(){
    clearTimeout(this.supTimer)
    this.supTimer = null
    this.deleteConfirmed = false
    message("Je resseté la suppression.")
  }

  static onClickSup(ev){
    stopEvent(ev)
    // Demander confirmation
    if ( ! this.deleteConfirmed ){
      message("Clique à nouveau sur le bouton de suppression pour confirmer.")
      this.deleteConfirmed = true
      this.supTimer = setTimeout(this.clearSupTime.bind(this), 10*1000)
      return false
    } else {
      this.deleteConfirmed = false
    }
    // Procéder
    let sup = this.notes.splice(this.current_index - 1, 1)
    // On modifie l’index courant si on ne le trouve plus dans la
    // liste
    if ( this.current_index > this.notes.length ){
      this.current_index = this.notes.length
    }
    // Enregistrer
    this.save(false)
  }
  static onHasSupNote(wdata){
    if (wdata.ok){}
  }

  static onClickEdit(ev){
    stopEvent(ev)
    this.toggleMode(true)
    this.editor.value = this.notes[this.current_index - 1]
    return false
  }
  /**
  * Méthode appelée quand on clique sur le bouton "+" pour ajouter
  * une note
  */
  static onClickAddNote(ev){
    stopEvent(ev)
    this.toggleMode(true)
    this.current_index = null
    this.editor.value = ""
    this.editor.focus()
    return false
  }

  // === DOM Elements Methods ===

  static toggleMode(modeEdition){
    if ( undefined === modeEdition ) {
      this.modeEdition = !this.modeEdition
    } else {
      this.modeEdition = modeEdition
    }
    if ( this.modeEdition ) {
      this.maskDivNotes()
      this.showEditor()
      this.maskBtnEdit()
      this.maskBtnSup()
      this.showBtnSave()
    } else {
      this.showDivNotes()
      this.maskEditor()
      this.showBtnEdit()
      this.showBtnSup()
      this.maskBtnSave()
    }
  }
  static maskDivNotes(){
    this.divNotes.classList.add('hidden')
  }
  static showDivNotes(){
    this.divNotes.classList.remove('hidden')
  }
  static maskEditor(){
    this.editor.classList.add('hidden')
  }
  static showEditor(){
    this.editor.classList.remove('hidden')
  }
  static maskBtnEdit(){
    this.btnEdit.classList.add('invisible')
  }
  static showBtnEdit(){
    this.btnEdit.classList.remove('invisible')
  }
  static maskBtnSup(){
    this.btnSup.classList.add('invisible')
  }
  static showBtnSup(){
    this.btnSup.classList.remove('invisible')
  }
  static maskBtnSave(){
    this.btnSave.classList.add('invisible')
  }
  static showBtnSave(){
    this.btnSave.classList.remove('invisible')
  }


  static get reader(){return this.divNotes}
  static get divNotes(){
    return this._divnotes || (this._divnotes = DGet('#blocknotes-reader', this.panneau))
  }
  static get editor(){
    return this._editor || (this._editor = DGet('textarea#blocknotes-editor', this.panneau))
  }
  static get btnNextNote(){
    return this._btnnextnote || (this._btnnextnote = DGet('#btn-next-note', this.panneau))
  }
  static get btnNextNote(){
    return this._btnnextnote || (this._btnnextnote = DGet('#btn-next-note', this.panneau))
  }
  static get btnPrevNote(){
    return this._btnprevnote || (this._btnprevnote = DGet('#btn-prev-note', this.panneau))
  }
  static get btnEdit(){
    return this._btnedit || (this._btnedit = DGet('.btn-edit', this.panneau))
  }
  static get btnSup(){
    return this._btnsup || (this._btnsup = DGet('.btn-sup', this.panneau))
  }
  static get btnAdd(){
    return this._btnadd || (this._btnadd = DGet('.btn-add', this.panneau))
  }
  static get btnSave(){
    return this._btnsave || (this._btnsave = DGet('.btn-save', this.panneau))
  }
  static get btnClose(){
    return this._btnclose || (this._btnclose = DGet('.btn-close', this.panneau))
  }
  static get spanNbNotes(){
    return this._spannbnotes || (this._spannbnotes = DGet('#nombre_et_index_note', this.panneau))
  }
  static get spanTitre(){
    return this._spantitre || (this._spantitre = DGet('h2', this.panneau))
  }
  static get panneau(){
    return this._panneau || (this._panneau = DGet('#panneau-blocnotes'))
  }
}
