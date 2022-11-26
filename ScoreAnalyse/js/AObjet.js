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

  static each(method){
    this.items.forEach(aobjet => method(aobjet))
  }


  static select(method){
    /** Retourne toutes les marques qui retournent true avec la 
     ** méthode +method+ **/
    var liste = []
    this.each(aobjet => {
      method(aobjet) === true && liste.push(aobjet)
    })
    return liste
  }

  static selectFirst(method){
    /** Retourne le premier objet qui renvoie true avec la méthode
     ** +method+ **/
    for (var aobjet of this.items ) {
      if ( aobjet.type == 'systeme') continue ;
      if ( method(aobjet) === true ) return aobjet
    }
  }

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

  static dupSelection(){
    /**
     ** Retourne une nouvelle liste avec les tags sélectionnés,
     ** qui pourra être modifiée sans toucher à la liste originale
     **/
    var liste = []
    this.eachSelection(aobj => liste.push(aobj))
    return liste
  }

  static resetSelection(){
    this.selection    = []
    this.selectionIds = []
    this.selectionTbl = {}
    this.updateMenuSelectionTool()
    BordersTool.desactivate()
    this.setMenusState()
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
    BordersTool.setMenuBordsFor(this.selection[0])
    this.setMenusState()
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
    this.setMenusState()
  }

  static setMenusState(){
    this.updateMenuSelectionTool()
    AlignMenu.setStateBySelection(this.selection.length)
    AdjustMenu.setStateBySelection(this.selection.length)
    AmarkMenu.setAllMenus(this.selection.length > 0)
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
    var hasGroupedTags    = false
    var allTagsAreGrouped = false

    if ( severalTags ) {
      allTagsAreGrouped = true
      const firstTag = this.selection[0]
      this.eachSelection((tag) => {
        if ( tag.isGrouped ) { 
          hasGroupedTags = true
          if ( allTagsAreGrouped && not(firstTag.isGroupedWith(tag))) {
            allTagsAreGrouped = false
          }
        } else { allTagsAreGrouped = false }
      })
    }

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
  const snap = pref('snap_for_adjust_pos')
  for (var aobj of this.items){
    if ( this.areNotAjustable(aobj.type, amark.type) && this.areNotAjustable(aobj.subtype, amark.subtype)){ 
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
  if ( type1 == type2 ) { 
    return true
  } else if ( TYPES_AJUSTABLES[type1] ) {
    return TYPES_AJUSTABLES[type1].includes(type2)
  } else if ( SUBTYPES_AJUSTABLES[type1]) {
    return SUBTYPES_AJUSTABLES[type1].includes[type2]
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


  corrigeDataValue(prop){
    /**
     ** Permet de corriger la valeur de la propriété +prop+ dans les
     ** données de l'objet.
     ** Cette méthode est appelée juste avant l'enregistrement,
     ** lorsque le programme s'assure que les valeurs sont bonnes.
     **/
    Object.assign(this.data, {[prop]: this.getCssProp(prop)})
  }

  memoriseHauteurLignePartie(){
    if (this.obj.querySelector('span.vline')){
      this.data.height = this.obj.querySelector('span.vline').offsetHeight
    } else {
      console.error("Une partie devrait comporter une ligne…")
      console.error("PARTIE : this.obj", this.obj)
    }
  }

getCssProp(prop, notANumber){
  /** @return la valeur "computée" de +prop+, qu'elle soit définie
   ** dans la classe CSS ou dans le style de l'objet.
   ** La plupart du temps, c'est une dimension, on la renvoie sous
   ** forme de nombre. Dans le cas contraire, il faut mettre 
   ** +notANumber+ à true pour renvoyer la valeur brute.
   **/
  var cval = getComputedStyle(this.obj).getPropertyValue(prop)
  if ( notANumber ) return cval
  return Number(unpx(cval))
}


  get top(){
    return this._top || (this._top = this.getTop() ) 
  }
  set top(v){
    if ( v == this.data.top ) return
    v = AMark.snapVertical(v, true) // Grid adjustment
    const currentTop = 0 + this.data.top
    this._top = v
    this.obj && (this.obj.style.top = px(v))
    this.data.top = v
    this.modified = true
    this.isPartie && this.obj && this.currentTop != v && this.memoriseHauteurLignePartie() // pour la ligne verticale
    this.analyse && this.analyse.setModified()
  }
  getTop(){
    return this.obj && this.getCssProp('top')
  }
  setTop(v){
    this.obj && (this.obj.style.top = px(v))    
  }

  get bottom(){ return this.top + this.height }
  set bottom(v){
    this.isMark && AMark.vSnap && (v = Math.round(v / AMark.vSnap) * AMark.vSnap)
    this.top = v - this.height
  }

  get left(){return this._left || (this._left = this.data.left || this.obj.offsetLeft)}
  set left(v){
    if ( v == this.data.left ) return
    this.data.left = AMark.snapHorizontal(v)
    this._left = this.data.left
    this.setLeft(this.data.left)
    this.analyse && this.analyse.setModified()
  }
  setLeft(v){
    this.obj && (this.obj.style.left = px(v))
  }

  get right(){return this._right || (this._right = this.left + this.width) }
  set right(v){
    v = this.snapHorizontal(v)
    this._right = v
    this.left   = v - this.width
  }

  get width(){ return this.data.width || this.getWidth() }
  set width(v) {
    v = this.snapHorizontal(v, this.getCssProp('border-left-width'))
    if ( v == this.data.width ) return
    // console.debug("width à l'entrée = %i", 0 + v)
    // console.debug("width ajustée = %i", 0 + v)
    this.data.width = v
    this.setWidth(this.data.width)
    this.analyse && this.analyse.setModified()
  }
  snapHorizontal(v, retrait){
    if ( ! AMark.hSnap ) return v
    return AMark.snapHorizontal(v) - retrait
  }

  snapVertical(v, retrait){
    if ( ! AMark.vSnap ) return v
    return AMark.snapVertical(v) - retrait
  }

  get height(){return this._height || this.data.height || (this._height = this.getHeight())}
  set height(v){
    v = this.snapVertical(v, this.getCssProp('border-top-width'))
    if ( v == this.data.height ) return
    this.data.height = v
    this._height = this.data.height
    this.setHeight(this.data.height)
    this.analyse && this.analyse.setModified()
  }

  getWidth(){
    return this.obj && this.getCssProp('width')
  }
  setWidth(v){
    /** Appliquer la largeur à l'objet **/
    this.obj && (this.obj.style.width = px(v))
  }

  getHeight(){
    return this.obj && this.getCssProp('height')
  }
  setHeight(v){
    /** Appliquer la hauteur à l'objet **/
    this.obj && (this.obj.style.height = px(v))
  }
}
