'use strict';

/**
* Définition des snippets
*/
const DATA_SNIPPETS = {
  't':  'writeTimeAtCursor',
  'a':  'writeBaliseAnalyse',
  's':  'writeSceneAtCursor',
  'sq': 'writeSequenceAtCursor',
  'o':  'writeObjectifAtCursor',
}


class Snippet {

  /**
  * Exécution du snippet
  */
  static exec(textor, snip, ev){
    let snippet = new Snippet(textor, snip)
    snippet.exec()
    snippet = null
    return stopEvent(ev)
  }

  constructor(textor, snip) {
    this.textor = textor
    this.snip   = snip
  }

  get data(){ 
    return this._data || ( this._data = DATA_SNIPPETS[this.snip] ) 
  }
  
  exec(){
    if ( this.data ) {
      if ( 'function' == typeof this[this.data] ) {
        this[this.data].call(this)
      }
    } else {
      Personnage.traiteSnippet(this)
    }
    return false
  }

  /*
  |  --- Snippet Methods ---
  */

  writeTimeAtCursor(){
    const horloge = s2h(this.textor.combo.controller.currentTime)
    this.remplaceSnippet(horloge + "\n", 1, {description:false})
  }

  writeSceneAtCursor(){
    this.remplaceSnippet('SCENE', 1, {description:"PITCH"})
  }

  writeSequenceAtCursor(){
    this.remplaceSnippet('SEQUENCE', 2, {description:"TITRE\nDESCRIPTION"})
  }

  writeObjectAtCursor(){
    this.remplaceSnippet('OBJECTIF', 1, {description:"TITRE\nDESCRIPTION"})
  }

  writeBaliseAnalyse(){
    this.remplaceSnippet("ANALYSE\n",1, {description:false})
  }

  /**
  * @param [String] str Le texte à placer
  * @param [Integer] snippetLen La longueur du snippet à supprimer
  * @param [Hash] options Les options pour l'insertion (cf. ci-dessous)
  * @option options description [Boolean] Si true, il faut ajouter " DESCRIPTION" après le texte à placer, et le sélectionner, pour définir une description
  */
  remplaceSnippet(str, snippetLen = 1, options){
    const it = this.textor.itextarea;
    options = options || {description: false}
    var offstart = 0, offend = 0 ;
    if ( options.description ){ 
      var ajout = ('string' == typeof options.description) ? ` ${options.description}` : " DESCRIPTION"
      // ajout += "\n\n__"
      offstart  = ajout.length - 1
      offend    =  offstart - 5
      str = str + ajout
    }
    it.select(it.selStart - snippetLen, it.selStart)
    it.replaceSelection(str, 'end')
    it.select(it.selStart - offstart , it.selStart - offend )
  }

}
