'use strict';
/**
 * Pour la gestion des TEXTAREAs et notamment l'autocomplétion
 * 
 * On instancie un Textarea avec l'élément DOM (<textarea>)
 * 
 */

/*
|  Expression régulière pour trouver le début d'un snippet
*/
const REG_BUTEE_SNIPPET = /^[ \n\(\{\["' ]$/

class Textarea {

  /**
  * @param [Hash] params Paramètres fournis
  * @option params [Function] autocompleteMethod Méthode à utiliser pour les snippets. Elle doit recevoir en premier argument le mot juste avant le cursor et en second argument l'évènement (mais il n'y a rien à faire dessus, normalement)
  */
  constructor(domElement, params){
    this.dom = domElement
    this.params = params || {}
    this.autocompleteMethod = params && params.autocompleteMethod
    this.observe()
  }

  /**
  * @return [String] Le texte depuis le début jusqu'à la sélection,
  * non comprise
  */
  textFromStartToCursor(){
    return this.content.substring(0, this.selStart)
  }

  /**
   * Pour SÉLECTIONNER DU TEXTE dans le champ Textarea
   * 
   * @param start {Integer} Position de départ
   * @param end   {Integer} Position de fin
   * @param dir   {String}  Direction 'forward' ou 'backward'
   */
  select(start, end, dir ) {
    end = end || start
    dir = dir || 'forward'
    this.dom.setSelectionRange(start, end, dir)
    return this
  }

  focus(){
    this.dom.focus()
  }

  /**
   * REMPLACEMENT DU TEXTE sélectionné par +replacement+, puis
   * sélectionner en fonction de +after+ qui peut être :
   *  'select'    sélection du texte ajouté
   *  'preserve'  sélection identique à ce qu'elle était
   *  'start'     se placer avant le remplacement
   *  'end'       se placer après le remplacement
   * 
   */
  replaceSelection(replacement, after){
    after = after || 'select'
    this.dom.setRangeText(replacement, this.selStart, this.selEnd, after)
    return this
  }
  // Deux alias
  setSelection(rep,after){return this.replaceSelection(rep,after)}
  replace(rep,after) {return this.replaceSelection(rep,after)}

  /**
   * Pour EFFACER DU TEXTE dans le textarea
   * 
   * @param data {:from, :to}
   * 
   */
  remove(data){
    this.select(data.from, data.to, 'forward')
    this.setSelection('')
  }


  /**
   * Retourne la position de la sélection dans l'écran
   * (par exemple pour placer un tooltip ou un champ d'autocomplé-
   *  tion)
   * 
   */
  get selectionPosition(){
    const relPosition = $(this.dom).getCaretPosition()
    const absPosition = {
        left: this.bounds.x + relPosition.left
      , top:  this.bounds.y + relPosition.top
    }
    Object.assign(absPosition, {
        x: absPosition.left
      , y: absPosition.top
    })
    // console.log("Position", {relPosition:relPosition,absPosition: absPosition})
    return absPosition
  }

  /**
   * Méthode pour déplacer le paragraphe courant (this.currentLine)
   * vers le haut (versHaut = true) ou vers le bas.
   * 
   * Cette méthode est appelée par le raccourci clavier 
   * CMD-CTRL-ArrowUp/Down
   * 
   */
  moveCurrentParagraph(versHaut){
    const dPar = this.currentLine
    // On supprime le paragraphe
    this.select(dPar.start, dPar.end + 1).replace('')
    if ( versHaut ) this.select(this.selStart - 1)
    const otherPar = this.currentLine
    if ( versHaut ) {
      // Vers le haut
      // Il faut rejoindre le début de la ligne
      this.select(otherPar.start).replace("\n").focus()
    } else {
      // Vers le bas
      // Il faut rejoindre la fin de la ligne
      this.select(otherPar.end).replace("\n")
      this.select(this.selStart + 1)
    }
    // Et on peut remettre la ligne initiale
    const zero = this.selStart 
    this.select(this.selStart).replace(dPar.text)
    // On doit remettre le curseur à la même position
    const debut = zero + dPar.cursor_start
    const fin   = zero + dPar.cursor_end
    this.select(debut,fin).focus()

  }


  /**
   * Retourne toutes les informations à propos de la ligne
   * courante.
   * Note : quand on parle de "ligne" ici, on entend "paragraphe"
   * 
   * @return {
   *  text:     Le texte de la ligne
   *  length:   Longueur de la ligne
   *  start:    La position de départ
   *  end:      La position de fin
   *  cursor:   La position du curseur dans la ligne ({:end, :start})
   *  index:    L'index de la ligne 
   * }
   */
  get currentLine(){
    const data = {
        text:         null
      , start:        null
      , end:          null
      , length:       null
      , index:        null
      , cursor_start: null
      , cursor_end:   null
    }
    var cursor = this.selStart
    const cursor_start_init = this.selStart
    const cursor_end_init   = this.selEnd
    const len = this.content.length
    // Se trouve-t-on à la fin de la ligne ?
    if ( this.content[cursor] == "\n") {
      /*
      |  Quand on est à la fin de la ligne
      */
      data.end = cursor
      while ( this.content[--cursor] != "\n" && cursor > -1)
      data.start = cursor
      // console.log("Ligne = '%s'", this.content.substring(data.start, data.end))
    } else if ( cursor == 0 || this.content[cursor - 1] == "\n") {
      /*
      |  Quand on est au début de la ligne
      */
      data.start = cursor
      while( this.content[++cursor] != "\n" && cursor <= len)
      data.end = cursor + 1
      // console.log("Ligne = '%s'", this.content.substring(data.start, data.end))
    } else {
      /*
      |  Quand on est à l'intérieur de la ligne
      */
      var start = cursor
      while ( this.content[--start] != "\n" && start > -1)
      data.start = start
      // Trouver la fin de la ligne
      var fin = cursor - 1
      while ( this.content[++fin] != "\n" && fin <= len)
      data.end = fin + 1
    }
    // Le texte du paragraphe
    data.text  = this.content.substring(data.start, data.end)
    // Longueur de la ligne
    data.length = data.text.length
    // La position de départ du curseur de la ligne
    data.cursor_start = cursor_start_init - data.start
    data.cursor_end   = cursor_end_init   - data.start 
    // Index de la ligne
    // TODO (inutile pour le moment et consommateur => wait and see)
    // console.log("Données de la ligne courante : ", data)
    return data
  }

  /**
   * Retourne le mot juste avant le curseur
   * 
   */
  get wordBeforeCursor(){ return this.getWordBeforeCursor() }

  getWordBeforeCursor(){
    var char, start = this.selStart - 1, mot = [];
    while ( start > -1 ) {
      char = this.content.substring(start, start+1)
      if ( char.match(REG_BUTEE_SNIPPET) ) { 
        break; // On a trouvé un caractère butée
      } else {
        mot.push(char)
        -- start
      }
    }
    return mot.reverse().join('')
  }
  
  /**
   * Retourne le mot après le curseur
   * 
   */
  get wordAfterCursor(){return this.getWordAfterCursor()}

  getWordAfterCursor(){
    var char = null
    var start = this.selEnd
    var mot = []
    const max_start = this.length
    while(char != ' ' && char != "\n" && start < max_start){
      char = this.content.substring(start, start + 1)
      if ( char != ' ' && char != "\n" ) { mot.push(char) }
      ++ start
    }
    return mot.join('')
  }


  /**
   * === MÉTHODES D'AUTOCOMPLÉTION ===
   * 
   */

  /**
   * Afficher le champ d'autocompletion
   * 
   * @param params
   *    params.multi         {boolean} True si c'est une autocomplé-
   *                tion multiple, comme par exemple pour un intitué
   *                de scène. Dans ce cas, les propriétés :source,
   *                et :default sont des Arrays
   *    params.source       La ou les sources (si multi)
   *        params.source.sources  : liste(s — si multi)
   *        params.source.defaults : valeur(s — si multi) par défaut
   *    params.afterInsertion {function} Fonction a invoquer après l'ajout.
   *               Elle reçoit la valeur insérée en argument et utilise
   *               this pour faire référence à ce textarea.
   *               Donc elle peut utiliser par exemple this.selStart
   *               ou this.select(...).replace(...) etc.
   *    params.fieldWidth    {Integer} Width (pixels) du champ
   * 
   */
  showAutocompleteInput(params){
    console.log("-> showAutocompleteInput")
    if ( undefined == params ) {
      params = this.autocompleteParams
    } else {
      this.autocompleteParams = params
    }
    this.isMultiAutocompletion = params.source.multi === true
    const source  = this.isMultiAutocompletion ? params.source.sources.shift() : params.source.source
    if ( not(source) || source.length == 0 ) {
      // console.log("Autocomplétion multiple terminée")
      return // fin d'une autocomplétion multiple
    }
    // Valeur par défaut (écrite dans le champ)
    const defaut = (this.isMultiAutocompletion ? params.source.defaults.shift() : params.default) || ''
    // console.log("SOURCE : ", source)
    this.autoInput.classList.remove('hidden')
    this.autoInput.value = defaut
    this.autoInput.style.top  = px(this.selectionPosition.y - 10)
    this.autoInput.style.left = px(this.selectionPosition.x)
    $(this.autoInput).autocomplete('option', 'source', source)
    this.autoInput.focus()
    this.autoInput.select()
    console.log("<- showAutocompleteInput")
  }
  hideAutocompleteInput(){
    const newValue  = this.autoInput.value
    const params    = this.autocompleteParams
    /**
     * TODO : pouvoir définir, dans les params d'autocomplétion, les
     * textes à ajouter avant ou après les valeurs à ajouter
     * note : ça pourrait se faire tout simplement en utilisant la
     * possibilité jQuery d'envoyer des tables {:label, :value} mais
     * c'est peut-être plus simple comme ça
     */
    this.autoInput.classList.add('hidden')
    this.setSelection(newValue,'end')
    if ( this.isMultiAutocompletion && params.source.sources.length){ 
      this.showAutocompleteInput()
    } else {
      if ( params.afterInsertion ) { 
        params.afterInsertion.call(this, newValue) 
      }
    }
  }
  /**
   * Observation du champ d'autocomplétion
   * 
   */
  observeAutocompleteField(o){
    const my = this
    $(o).autocomplete({
        delay:  0
      , source: []
      , autoFocus: true
      , close:  my.hideAutocompleteInput.bind(my)})

    // On doit aussi gérer le retour chariot
    o.addEventListener('keypress', function(e){
      if (e.key == 'Enter'){
        console.log("retour chariot dans le champ d'autocomplétion")
        my.hideAutocompleteInput()
        return stopEvent(e)
      } else if ( e.key == 'Tab' ) {
        console.log("Tab dans le champ d'autocomplétion")
      }
    })

    $(o).on('keydown', function(e) {
      if (e.key == 'ArrowDown' /* && $(this).val().length == 0 */) {
        $(this).autocomplete('search', '');
      }
    })

  }

  /**
   * Construction du champ d'autocompletion 
   * 
   */
  buildAutocompleteInput(){
    const o = DCreate('INPUT', {type:'text', style:'width:100px;padding:8px;position:absolute;z-index:200;'})
    document.body.appendChild(o)
    this.observeAutocompleteField(o)
    return o
  }
  get autoInput(){
    return this._autoinput || (this._autoinput = this.buildAutocompleteInput())
  }

  // ---- /Fin des méthodes pour l'autocomplétion ---


  get selStart() { return this.dom.selectionStart }
  get selEnd()   { return this.dom.selectionEnd   }
  get selection(){ return this.content.substring(this.selStart, this.selEnd)}
  get content()  { return this.dom.value }
  get length()   { return this.content.length}
  get bounds(){
    return this._bounds || (this._bounds = this.dom.getBoundingClientRect())
  }

  observe(){
    this.dom.addEventListener('focus', this.onFocus.bind(this))
    this.dom.addEventListener('blur', this.onBlur.bind(this))
    this.dom.addEventListener('change', this.onChange.bind(this))
    this.dom.addEventListener('keypress', this.onKeypress.bind(this))
    this.dom.addEventListener('keydown', this.onKeyDown.bind(this))
  }

  onKeypress(e){
    return true
    // console.info("= Touche pressée : %s", e.key)
  }
  onKeyDown(e){
    // console.log("=> keyDown pressée : ", e)
    if (e.metaKey && e.ctrlKey){
      switch(e.key){
      case 'ArrowDown': case 'ArrowUp':
        /*
        |  Gestion des flèches haut/bas avec CMD+CTRL pour le
        |  déplacement des paragraphes
        */
        const versHaut = e.key == 'ArrowUp'
        this.moveCurrentParagraph(versHaut)
        return stopEvent(e)
      }
    }
    switch(e.key){
    case 'Tab':
      /*
      |  Méthode de traitement des snippets
      */
      if ( this.autocompleteMethod ) {
        stopEvent(e)
        this.autocompleteMethod.call(null, this.wordBeforeCursor, e)
        return false
      }
      break
    }    
  }

  onFocus(e){
    console.info("= Focus dans le textarea")
  }

  onBlur(e){
    console.info('= Blur du textarea ')
  }

  onChange(e){
    // console.info('= La valeur a changé dans ', this)
    return stopEvent(e)
  }

}
