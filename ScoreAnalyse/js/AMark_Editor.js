'use strict';
/**
 * AMark_Editor
 * ------------
 * 
 * L'édition d'une "marque d'analyse" (AMark) étant assez complexe,
 * on se sert de cette classe pour créer ou éditer les marques.
 * 
 * Une marque est caractérisée par :
 *    - son type 
 *    - son sous-type (éventuellement)
 *    - son texte (le plus souvent)
 */


class AMark_Editor {

constructor(data){
  this.data   = data
  this.event  = data.event

  //* Pour écrire toutes les coordonnées
  var xy = {}
  for(var k in this.event){
    if ( k.endsWith('X') || k.endsWith('Y')) Object.assign(xy, {[k]: this.event[k]})
  }
  console.log("Coordonnées du click ", xy)
  console.log("Rappel : c'est PageX et PageY qui serviront à placer l'éditeur")
  //*/

}

/**
 * = main =
 * 
 * Méthode qui procède à l'édition. On repasse toujours par cette
 * function, jusqu'à ce que toutes les valeurs nécessaires soient
 * définies. 
 * 
 */
proceed(){
  // console.log("-> proceed() / amark_data = ", this.amark_data)
  if ( !this.amark_type ) return this.getAMarkType()
  if ( this.isRequiringSubType && !this.amark_subtype) return this.getAMarkSubType()
  if ( this.isRequiringContent && undefined == this.amark_content) return this.getAMarkContent()
  this.hasAutoContent && this.setAutoContent()
  this.finishWith(this.amark_data)
}

/**
 * Pour finir, on envoie les données à la méthode qui les attend
 * pour construire ou reconstruire l'objet.
 * 
 * En cas d'annulation, +data+ est null
 * 
 */
finishWith(data){
  this.data.onReleaseMethod.call(null, data)
}

/**
 * Les DATA de la Marque d'analyse
 * 
 */
get amark_data(){
  return {
      type:     this.amark_type
    , prolong:  !!this.hasProlong
    , subtype:  this.amark_subtype
    , content:  this.amark_content
    , top:      this.position.top   + this.rectifTopPerType
    , left:     this.position.left  + this.rectifLeftPerType
  }
}

get amark_type(){return this._amark_type}
get amark_subtype(){return this._amark_subtype}
get amark_content(){return this._amark_content}

/**
 * Rectification du left et du top par rapport au clic de souris
 * en fonction du type de marque
 */
get rectifLeftPerType(){
  return this.dataOfType.ajustX || 0
}
get rectifTopPerType(){
  return this.dataOfType.ajustY || 0
}

/**
 * Les méthodes pour obtenir les valeurs des données
 * 
 */

/**
 * Méthode pour obtenir le type de la marque
 */
getAMarkType(){
  var params = {cancelEnable: true}
  Object.assign(params, this.positionFixed)
  console.log("Paramètres envoyés à GetterInList (notamment pour le positionner)", params)
  this.getterOfAMarkType.show(params)
  this._datatype      = null
  this._gettersubtype = null
  this._editorcontent = null
}
onChooseType(type){
  if ( type ) {
    this._amark_type = type
    this.proceed()
  }
}
/**
 * Méthode pour obtenir le sous-type de la marque
 * (si nécessaire)
 */
getAMarkSubType(){
  this.getterOfAMarkSubtype.show(this.positionFixed)
}
onChooseSubtype(subtype){
  this._amark_subtype = subtype
  this.proceed()
}

/**
 * Méthode pour obtenir le contenu textuel de l amark
 */
getAMarkContent(){
  this.editorOfAMarkContent.value = this.amark_content || this.defaultValue
  this.editorOfAMarkContent.show(this.position)
}

/**
 * Méthode de retour du contenu (Editeur.js)
 * 
 * @param {String|Null} content Le contenu ou la valeur null si Renoncer
 * 
 */
onSetContent(content){
  if ( content ) {
    this.hasProlong = content.endsWith('--')
    this._amark_content = this.hasProlong 
      ? content.substring(0, content.length - 2) 
      : content
    // On met toujours une prolongation à une pédale, même lorsqu'elle
    // n'est pas indiquée
    if ( this.amark_type == 'ped' ) this.hasProlong = true
    this.proceed()
  }
}

/**
 * Méthode qui règle le contenu automatique pour les valeurs
 * qui le nécessite. Par exemple pour les cadences.
 * 
 */
setAutoContent(){
  switch(this.amark_type){
    case 'cad':
      this._amark_content = CADENCES[this.amark_subtype].autocontent
      break
    case 'not':
      this._amark_content = TYPES_NOTES[this.amark_subtype].autocontent
      break
    default:
      erreur("Impossible de définir l'autocontent du type '"+this.amark_type+"'…")
  }
}

/**
 * 
 * Méthode d'état, pour savoir si la marque a besoin de telle ou 
 * telle chose (subtype, content)
 * 
 */
get isRequiringSubType(){
  return undefined != this.dataOfType.subtype
}
get isRequiringContent(){
  return undefined != this.dataOfType.default
}
get hasAutoContent(){
  return this.dataOfType.autocontent == true
}


// --- PRIVATE ---

// La position des différents "éditeur" (getters de liste, 
// mini-éditeur)
get position(){
  // return this._pos || (this._pos = {top:this.event.layerY, left:this.event.layerX})
  return this._pos || (this._pos = {top:this.event.pageY - 40, left:this.event.pageX - 40})
}
get positionFixed(){
  return this._posfixed || (this._posfixed = {top:this.event.clientY - 40, left:this.event.clientX - 40})
}

// La valeur par défaut, en fonction du type
get defaultValue(){
  return this.dataOfType.default
}

// Les données du type (dans AMARQUES_TYPES)
get dataOfType(){
  return this._datatype || ( this._datatype = AMARQUES_TYPES[this.amark_type])
}

/**
 * 
 * Les éditeurs particuliers
 * 
 */

// Éditeur pour obtenir le type
get getterOfAMarkType(){
  return this._gettertype || (this._gettertype = new GetterInList(this.paramsGetterOfType))
}

// Éditeur pour obtenir le sous-type (subtype)
get getterOfAMarkSubtype(){
  return this._gettersubtype || (this._gettersubtype = new GetterInList(this.paramsGetterOfSubtype))
}

// Éditeur pour obtenir le contenu textuel
get editorOfAMarkContent(){
  return this._editorcontent || (this._editorcontent = new Editeur(this, {message:this.dataOfType.message, setMethod: this.onSetContent.bind(this)}) )
}


/**
 * 
 * Les paramètres pour les éditeurs particuliers (getter de liste…)
 * 
 */
get paramsGetterOfType(){
  return {
      values:         Object.values(AMARQUES_TYPES)
    , message:        "Type de la marque"
    , onChooseMethod: this.onChooseType.bind(this)
  }
}

// Paramètres pour le getter de sous-type
get paramsGetterOfSubtype(){
  var d = {}
  switch(this.amark_type){
    case 'cad':
      d = {
          values: Object.values(CADENCES)
        , message:"Type de la cadences"
      }
      break
    case 'not':
      d = {
          values: Object.values(TYPES_NOTES)
        , message:"Type de la note :"
      }
      break
    case 'txt':
      d = {
          values: TAILLES_TEXTE
        , message:"Taille du texte"
      }
      break
    case 'seg':
      d = {
          values: TYPES_SEGMENT
        , message:"Disposition du segment"
      }
      break
    default:
      erreur("Le type '"+this.amark_type+"' ne définit pas son sous-type…")
      return null
  }
  return Object.assign(d, {onChooseMethod: this.onChooseSubtype.bind(this)})
}

} // AMark_Editor
