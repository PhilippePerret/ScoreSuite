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
    this.showNoteInMenuTitres()
    this.setTitre() // p.e. affiche le nombre de notes
  }

  static updateMenuTitres(){
    this.menuTitres.innerHTML = ""
    for (var inote = 0, len = this.notes.length; inote < len; ++inote){
      const note    = this.notes[inote].trim()
      const titre   = note.split("\n")[0].replace(/#/g,'').trim()
      const option  = DCreate('OPTION', {text: titre, value: String(inote + 1)})
      this.menuTitres.appendChild(option)
    }
  }
  static showNoteInMenuTitres(){
    this.menuTitres.value = this.current_index
  }
  static get menuTitres(){
    return this._menutitres || (this._menutitres = DGet('select#blocknotes-menu-titres'))
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
      this.updateMenuTitres()
      this.showNoteByIndex(1)
      this.updateUI()
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

    listen(this.menuTitres, 'change', this.onChooseTitreNote.bind(this))
    $(this.panneau).draggable()
  }



  // === Notes Methods ===

  /**
  * Affiche la note d’index +index+ (1-start)
  */
  static showNoteByIndex(index) {
    this.toggleMode(false)
    const note = this.notes[index - 1]
    this.reader.innerHTML = this.formateNote(note)
    this.current_index = Number(index)
    this.updateUI()
  }


  // === Event Methods ===


  // Quand on choisit un titre de note dans le menu
  static onChooseTitreNote(){
    this.showNoteByIndex(this.menuTitres.value)
  }

  static onClickBtnOtherNote(plus, ev){
    // @note : avec la touche META, on peut déplacer une note au 
    // lieu de passer à la suivante
    const pourDeplacement = ev.metaKey == true
    stopEvent(ev)
    if ( pourDeplacement) {
      this.moveCurrentNote(this.current_index + plus)
    } else {      
      this.current_index += plus // 1 ou -1
      this.showNoteByIndex(this.current_index)
    }
    return false
  }

  /**
  * Méthode appelée quand on META-clique sur une flèche pour 
  * déplacer la note vers l’index to_index.
  * 
  * @note 
  *   La difficulté, pour les déplacements, est toujours la même :
  *   le traitement est différent suivant que la note doit être 
  *   placée après ou avant son index actuel.
  */
  static moveCurrentNote(to_index){
    // On prend la note à déplacer
    const note = this.notes[this.current_index - 1]
    // On remplace sa valeur par null
    this.notes[this.current_index - 1] = null
    // L’index réel 0-start
    const toReadIndex = to_index - 1
    var newListe = []
    for (var i = 0, len = this.notes.length; i < len; ++i){
      const curn = this.notes[i]
      if ( curn == null ) {
        // passer la note à déplacer
        continue
      } else if ( i == toReadIndex ) {
        // L’endroit où il faut mettre la note
        if ( to_index > this.current_index ) { newListe.push(curn) }
        newListe.push(note)
        if ( to_index < this.current_index ) { newListe.push(curn) }
      } else {
        // On ajoute toujours l’élément courant
        newListe.push(curn)
      }
    }
    this.notes = newListe
    this.current_index = Number(to_index)
    this.save(false)
  }

  static onOpen(){
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
      this.updateMenuTitres()
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




  static formateNote(note){
    const str = []
    note.split("\n\n").forEach(line => {
      line = line.replace(/^(#{1,7})(.+)$/, (tout, mark, titre) => {
        mark = mark.length
        return `<h${mark}>${titre.trim()}</h${mark}>`
      })
      line = line.replace(/\*\*(.+?)\*\*/g,'<strong>$1</strong>')
      line = line.replace(/\*(.+?)\*/g, '<em>$1</em>')

      str.push(`<p>${line}</p>`)
    })
    return str.join('')
  }




}
