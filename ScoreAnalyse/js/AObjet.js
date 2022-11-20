'use strict';
/**
 * 
 * Classe AObjet
 * -------------
 * Pour donner la constante AObjets qui est la liste de tous les
 * objets d'analyse
 * 
 * Classe de tous les objets d'analyse
 * 
 */

class AObjet {

  static add(objet){
    this.items.push(objet)
    Object.assign(this.table, {[objet.id]: objet})
  }

  static get(objet_id){
    return this.table[objet_id]
  }

  static init(){
    this.items = []
    this.table = {}
  }

  /* --- Selection Methods --- */

  /**
   * Pour boucle sur les objets sélectionnés avec
   * la méthode +method+
   */
  static eachSelection(method){
    if ( this.selection.length == 0 ) return 
    this.selection.forEach(method)
  }

  static resetSelection(){
    this.selection    = []
    this.selectionIds = []
    this.selectionTbl = {}
    this.updateMenuSelectionTool()
  }

  /**
   * Pour ajouter un objet à la sélection courante
   */
  static addToSelection(aobjet) {
    if ( undefined == this.selection ) {
      this.resetSelection()
    } else if ( this.selectionTbl[aobjet.id] ) {
      return // Ne pas enregistrer deux fois un objet
    }
    if ( aobjet.isGrouped ) {
      aobjet.grp.forEach( tid => {
        this.insertUniqObjectInSelection(AObjet.get(tid))
      })
    } else {
      this.insertUniqObjectInSelection(aobjet)
    }
    this.updateMenuSelectionTool()
  }

  // Méthode fonctionnelle privée (cf. ci-dessus)
  static insertUniqObjectInSelection(aobjet){
    this.selection.push(aobjet)
    this.selectionIds.push(aobjet.id)
    Object.assign(this.selectionTbl, {[aobjet.id]: aobjet})
    aobjet.setSelected()
  }

  static removeFromSelection(aobjet){
    const dec = this.selectionIds.indexOf(aobjet.id)
    this.selection.splice(dec, 1)
    this.selectionIds.splice(dec, 1)
    delete this.selectionTbl[aobjet.id]
    aobjet.unsetSelected()
    this.updateMenuSelectionTool()
  }

  /**
   * 
   * Pour détruire la sélection courante
   * 
   */
  static removeCurrentSelection(){
    if ( this.selection && this.selection.length ) {
      this.selection.forEach(this.remove.bind(this))
      this.resetSelection()
    }
  }

  static setSelection(aobjet){
    this.deselectAll()
    this.selection = [aobjet]
    this.selectionPointer = 0
    this.updateMenuSelectionTool()
  }

  static deselectAll(e){
    if ( this.selection ) {
      this.selection.forEach(aobj => aobj.unsetSelected())
    }
    this.resetSelection()
    return e && stopEvent(e)
  }

  static updateMenuSelectionTool(){

    const severalTags       = this.selection.length > 1
    const hasGroupedTags    = false
    const allTagsAreGrouped = false

    const menGroupEna   = severalTags && not(allTagsAreGrouped)
    const menDegroupEna = severalTags && hasGroupedTags
    /*
    |  On règle la possibilité de grouper les éléments sélectionnés
    |  Seulement :
    |     - s'il y a plusieurs éléments
    |     - si ces éléments ne sont pas déjà groupés
    */
    SelectionTool.toggleMenuGroupSelection(menGroupEna)

    /*
    |  On règle la possibilité de dégrouper les éléments sélectionnés
    |  Note : seulement s'ils sont groupés.
    */
    SelectionTool.toggleMenuDegroupSelection(menDegroupEna)

  }

  /* ---/fin des méthodes de sélection */

  static remove(aobjet){
    var newItems = []
    var newTable = {}
    this.items.forEach(aobj => {
      if ( aobj.id == aobjet.id ) return
      else {
        newItems.push(aobj)
        Object.assign(newTable, {[aobj.id]: aobj})
      }
    })
    aobjet.destroy()
    this.items = newItems
    this.table = newTable
  }

  /**
   * Pour déplacer tous les objets d'analyse d'un certain nombre
   * de pixels à partir d'une certaine hauteur.
   * 
   * @param {Hash} params les paramètres de déplacement :
   *    .top      À partir de cette hauteur
   *    .offset   Pour ce nombre de pixels
   *    .sauf     Sauf les objets qui se trouvent dans cette liste
   *              (par exemple les objets associés au système)
   * 
   */
  static moveAllBelow(params){
    console.info("-> moveAllBelow(",params)
    this.items.forEach(obj => {
      if ( obj.top < params.top || params.sauf.includes(obj.domId)) return ;
      obj.top = obj.top + params.offset
      obj.modified = true
    })
    TableAnalyse.setHeight.call(TableAnalyse)
  }

  /**
   * Retourne l'objet placé le plus bas (s'il existe)
   *
   */
  static get bottomestObjet(){
    const my = this
    if ( this.items.length ) {
      this._bottomestobj = null
      let bottomest = 0
      this.items.forEach( ao => {
        if ( ao.bottom > bottomest ) { 
          this._bottomestobj = ao
          bottomest = ao.bottom
        }
      })
      return this._bottomestobj
    }
  }
  /**
   * Retourne le point le plus bas des objets (donc le bottom de
   * l'objet le plus bas)
   */
  static get bottomestPoint(){
    if ( this.items.length ) {
      return this.bottomestObjet.bottom
    } else {
      return 0
    }    
  }

/**
 * Quand la préférence "Ajuster les marques de même type" est activée
 * l'application doit checker chaque ajustement de position pour
 * mettre l'élément en place.
 * 
 */
static checkPositionAndAdjust(amark){
  const snap = Preferences.get('snap_for_adjust_pos')
  for (var aobj of this.items){
    if ( this.areNotAjustable(aobj.type, amark.type) ){ 
      continue ;
    }
    // S'il y a trop d'écart entre les deux éléments de type 
    // ajustable, on ne les bouge pas
    if ( Math.abs(aobj.top - amark.top) > snap ) {
      continue ;
    }
    // Sinon, on ajuste
    amark.top = aobj.top
  }
}
static areAjustable(type1, type2){
  if ( type1 == type2 ) { return true }
  if ( TYPES_AJUSTABLES[type1] ) {
    return TYPES_AJUSTABLES[type1].includes(type2)
  }
}
static areNotAjustable(type1, type2){
  return !this.areAjustable(type1, type2)
}

// ===============================================================

  constructor(analyse, data){
    this.analyse  = analyse
    this.data     = data
    this._id      = data.id
    this._top     = data.top
    this._left    = data.left
    AObjet.add(this)
  }

  destroy(){
    this.obj.remove()
    this.destroyed = true
  }

  get id(){return this._id}
  set id(v){this._id = v}

  get height(){return this._height || (this._height = this.getHeight())}
  set height(v){
    this._height = v
    this.obj && (this.obj.style.height = px(v))
    this.data.height = v
    this.modified = true
    this.analyse && (this.analyse.modified = true)
  }
  getHeight(){
    // console.log(" -> getHeight / systeme %i", this.id)
    // console.log("this.obj = ", this.obj)
    return this.obj && this.obj.offsetHeight
  }

  get top(){
    return this._top || (this._top = this.getTop() ) 
  }
  getTop(){
    if ( undefined == this.data.top ) {
      return this.obj.offsetTop
    } else {
      return this.data.top
    }
  }
  set top(v){
    const currentTop = 0 + this.data.top
    this._top = v
    this.obj && (this.obj.style.top = px(v))
    this.data.top = v
    this.modified = true
    this.isPartie && this.obj && this.currentTop != v && this.memoriseHauteurLignePartie() // pour la ligne verticale
    this.analyse && this.analyse.setModified()
  }

  memoriseHauteurLignePartie(){
    if (this.obj.querySelector('span.line')){
      this.data.height = this.obj.querySelector('span.line').offsetHeight
    } else {
      console.error("Une partie devrait comporter une ligne…")
      console.error("PARTIE : this.obj", this.obj)
    }
  }

  get bottom(){ return this.top + this.height }
  set bottom(v){
    this.top = v - this.height
  }

  get left(){return this._left || (this._left = this.data.left || this.obj.offsetLeft)}
  set left(v){
    this._left = v
    this.obj && (this.obj.style.left = px(v))
    this.data.left = v
    this.modified = true
    this.analyse && this.analyse.setModified()
  }

  get width(){ return this.data.width || this.getWidth() }
  set width(v) {
    var isModified = v != this.data.width
    this.data.width = v 
    this.analyse && isModified && this.analyse.setModified()
  }

  getWidth(){
    if (this.obj) {
      if ( this.obj.style.width ) {
        return unpx(this.obj.style.width)
      } else {
        return this.obj.offsetWidth
      }
    }
  }
}
