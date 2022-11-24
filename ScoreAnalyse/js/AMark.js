'use strict';



class AMark extends AObjet {

  /**
   * Pour créer un nouvel objet à l'endroit du double-clic
   * 
   * La méthode fonctionne en deux temps :
   *  1) choix du type (type) de la marque (avec un GetterInList)
   *  2) contenu (value) de la marque (avec un Mini-éditeur)
   * 
   * @param {Event}   e       L'event double-click (ou null)
   * @param {Hash}    params  Les données
   */
  static createNew(e, params){
    if ( undefined == params ) {

      const editor = new AMark_Editor({event:e, onReleaseMethod: this.createNew.bind(this, e)})
      return editor.proceed()

    } else if ( null === params ) {

      //
      // Annulation de l'utilisateur
      //
      return

    } else {

      //
      // Paramètres fournis, on peut construire la marque
      //

      console.info("CREATE: Marque d'analyse avec données : ", params)
      // Identifiant unique
      Object.assign(params, { id: Analyse.current.newId() })
      const newMark = ( function(type){
        if ( type == 'img' ) {
          return new AMImage(Analyse.current, params)
        } else {
          return new AMark(Analyse.current, params)
        }
      })(params.type)
      newMark.setValues(params)
      newMark.build_and_observe()
      newMark.toggleFromSelection(/* keep_other = */ false)
      newMark.ajustePosition(newMark.left, newMark.top)
      UI.allumeRedLight()

      return newMark
    }
  }

/**
* Pour déplacer la sélection avec les flèches
*/
static moveSelection(sens, multiplicateur, precision){
  if (!Analyse.current) return
  var prop, factor, methode
  switch(sens){
  case 'right': [prop, factor] = ['left', 1]  ; break
  case 'left' : [prop, factor] = ['left',-1]  ; break
  case 'down' : [prop, factor] = ['top',  1]  ; break
  case 'up'   : [prop, factor] = ['top', -1]  ; break
  }
  factor = factor * multiplicateur
  methode = function(aob) { aob[prop] += precision * factor}
  AObjet.eachSelection(methode)
  
}

/**
 * Nettoyage de la table d'analyse (par exemple avant lecture)
 * 
 */
static cleanUp(){
  var restItems = []
  AObjet.items.forEach(aobj => {
    if ( aobj.type != 'systeme' ){
      aobj.destroy()
      aobj = null
    } else {
      restItems.push(aobj)
    }
  })
  AObjet.items      = restItems ; // seulement les systèmes
  AObjet.resetSelection()
}

/* --- Snap Grid Methods --- */

static toggleGridMode(modeON){
  this.vSnap = modeON ? pref('grid_vertical_space')   : null
  this.hSnap = modeON ? pref('grid_horizontal_space') : null
  this.bSnap = modeON ? pref('thiness_cellule_line')  : 0
  console.log("this.bSnap = ", this.bSnap)
}

static snapVertical(v){
  if ( !this.vSnap ) return v ;
  return Math.round(v / this.vSnap) * this.vSnap
}
static snapHorizontal(v){
  if ( !this.hSnap ) return v ;
  return Math.round(v / this.hSnap) * this.hSnap
}

static get bSnap(){
  return this._bSnap || (this._bSnap = pref('thiness_cellule_line'))
}
static set bSnap(v){ this._bSnap = v}


//##################################################################


constructor(analyse, data){
  super(analyse, data)
  this.type = data.type
}

get prolong(){
  return this.data.prolong
}
set prolong(v){
  this.data.prolong = v
}

/**
 * Quand on double clique sur l'élément => édition pour le moment
 * 
 */
onDoubleClick(e){
  try{
    this.edit()
  } catch(err){
    console.error(err)
  }
  return stopEvent(e)// important
}

/**
 * Édition de la marque
 * 
 * Noter qu'on ne peut pas changer le type de la marque. Pour faire
 * un autre type de marque, supprimer la marque et en refaire une
 * autre
 * 
 */
edit(){
  this.editor = this.editor || new Editeur(this)
  this.editor.value = this.content + (this.hasProlongLine ? '--' : '')
  this.editor.show({top:this.top, left:this.left}, AMARQUES_TYPES[this.type].message)
}

destroy(){
  this.obj.remove() // c'est tout ? OUI
  Analyse.current.modified = true
}

/**
 * Définition des valeurs à la création de la marque
 * Elles sont envoyées depuis la méthode AMark.createNew()
 */
setValues(values){
  this.content  = values.content
  this.top      = values.top
  this.left     = values.left
  this.subtype  = values.subtype
  this.prolong  = values.prolong
  this.type     = values.type
  values.width  && (this.width  = values.width);
  values.height && (this.height = values.height);
}

/**
 * Redéfinition de la valeur de la marque d'analyse
 * 
 * Est appelée seulement par le mini-éditeur lorsque l'on veut 
 * modifier le texte de la marque.
 * Rappel : pour chager de marque (de type), il faut détruire la
 * marque actuelle et en créer une autre.
 * 
 *  '--' à la fin indique qu'il faut un trait de prolongation
 * 
 */
setValue(newvalue){
  if ( null == newvalue ) return ; // annulation
  // console.log("-> setValue('%s')", newvalue)
  const oldProlong = true && this.prolong

  this.prolong = this.data.prolong = newvalue.endsWith('--')
  
  newvalue = this.prolong ? newvalue.substring(0, newvalue.length - 2) : newvalue

  /**
   * Re-définition du contenu et de la prolongation
   */
  this.content = newvalue

  /**
   * 
   * LIGNE DE PROLONGATION
   * À ajouter ou à retirer
   * 
   */
  if ( this.prolong != oldProlong ) {
    if ( this.prolong && !this.isCadence ){
      this.buildLigneProlongation()
    } else if ( this.hasProlongLine && !this.prolong ) {
      this.destroyLigneProlongation()
      this.data.width = null
    }
  }

  /**
   * Petit "+" visible à l'édition pour allonger la cadence
   */
  if ( this.isCadence ) {
    this.signePlusCad || this.buildSignePlusCadence()
  }

  Analyse.current.setModified()

}

lock(){
  this.data.locked = true
  this.obj.classList.add('locked')
  $(this.obj).draggable("disable")
}
unlock(){
  delete this.data.locked
  this.obj.classList.remove('locked')
  $(this.obj).draggable("enable")
}
get isLocked(){
  return this.data.locked == true
}

/* --- Méthodes de GROUPE --- */

get grp(){ return this._grp || (this._grp = this.data.grp) }
set grp(v){
  this._grp = v
  this.data.grp = v
}

get isGrouped(){
  return this.grp && this.grp.length > 0
}
isGroupedWith(tag){
  return this.grp && this.grp.includes(tag.id)
}

groupWith(tag){
  // Permet de grouper le tag courant avec la tag +tag+
  const moi = this

  if ( moi.isGrouped && moi.isGroupedWith(tag) ){
    return erreur("Les deux tags sont déjà associés.")
  }

  const tagIsGrouped = true && tag.isGrouped
  const moiIsGrouped = true && self.isGrouped

  /*
  |  Les deux tags peuvent être déjà groupés avec d'autres
  |  tags.
  */
  var tagAsso = tag.isGrouped ? tag.grp : [tag.id]
  var moiAsso = moi.isGrouped ? moi.grp : [moi.id]

  /*
  |  On regroupe tous les tags associés.
  */
  const allTagsGrouped = moiAsso.concat(tagAsso)
  moi.setGroup(allTagsGrouped)
  tag.setGroup(allTagsGrouped)

  Analyse.current && Analyse.current.setModified()

}

degroupFrom(tag){
  /*
  |  Dégroupe le tag courant et +tag+ ({AMark})
  */
  const moi = this

  if ( not(this.isGroupedWith(tag)) ) {
    return erreur("Les deux tags ne sont pas associés !")
  }

  if ( moi.grp.length == 2 ) { // <= une seule association
    delete moi.grp
    delete tag.grp
  } else {
    const idx = moi.grp.indexOf(tag.id)
    moi.grp.splice(idx, 1)
    this.segGroup(moi.grp)
  }

  Analyse.current && Analyse.current.setModified()
}

setGroup(grp) {
  /*
  |  Définit les associations de ce tag.
  |  Attention, il ne faut appeler cette méthode que sur un seul tag
  |  sinon elle tournera en boucle.
  */
  if ( this.isGrouped ) {
    this.grp.forEach(tid => AMark.get(tid).grp = grp)
  } else {
    this.grp = grp
  }
}

/* ---/fin des méthodes de groupe */

/* --- Classes CSS Methods --- */



addCss(classe){
  if (!this.data.css) this.data.css = []
  if ( not(this.data.css.includes(classe)) ) this.data.css.push(classe)
}
removeCss(classe){
  if ( !this.data.css) return // on ne sait jamais…
  const idx = this.data.css.indexOf(classe)
  if (idx < 0) return // on ne sait jamais
    this.data.css.splice(idx, 1)
  if ( this.data.css.length == 0) {
    delete this.data.css
    this.data.css = undefined
  }
}
/**
* À la construction du tag, pour appliquer ses css ajoutés
*/
applyCss(){
  if ( !this.data.css ) return ;
  this.data.css.forEach(classe => this.obj.classList.add(classe))
}

/**
 * Si le type de la marque est une cadence (markType = 'cad') alors
 * il faut choisir ce type
 * 
 */
chooseCadenceType(){
  // console.log("-> chooseCadenceType")
  this.getterCadenceType.show({top:this.top, left:this.left})
}
/**
 * Méthode qui reçoit le choix du type de la cadence.
 * Elle la consigne et l'affiche.
 * 
 */
onChooseTypeCadence(cadenceType){
  this.cadenceType = cadenceType
  // On marque la cadence
  this.marquerCadence()
}
get getterCadenceType(){
  return this._gettertypecad||(this._gettertypecad = this.buildGetterTypeCadence())
}
buildGetterTypeCadence(){
  var getter = new GetterInList({
    items:Object.values(CADENCES)
    , onChooseMethod: this.onChooseTypeCadence.bind(this)
    , message: "Type de la cadence"
  })
  return getter
}

/**
 * Méthode qui associe l'objet avec son système
 * 
 * L'objet sera mis dans la liste @objets du système et 
 * déplacé avec lui.
 * Les objets permettent aussi de définir le top et le height
 * réel de l'objet.
 * 
 * Pour le détail, consulter la partie "Association de l'objet avec
 * son système" dans le manuel de développement
 */
associateWithSystem(){
  this._sys = null
  this.system && this.system.addObjet(this)
}
get system(){
  return this._sys || (this._sys = Systeme.getSystemeAssociated(this))
}

/**
 * Construction et observation de la marque d'analyse
 * 
 */
build_and_observe(){
  this.build()
  this.observe()
  this.associateWithSystem()
}

/**
 ***********************************
 ***  Construction de la marque  ***
 ***********************************
 */
build(){
  // Main objet
  this.obj = DCreate('DIV', {id:this.domId})
  const o = this.obj
  UI.TableAnalyse.appendChild(o)

  // Content
  this.contentSpan = this.buildSpanContent()
  o.appendChild(this.contentSpan)
  
  // Style de la marque
  var css = ['amark', 'aobj']
  css.push(this.type)
  if ( TYPES_PHILHARMONIEFONT.includes(this.type) ) css.push('philnote')
  this.subtype && css.push(this.subtype)
  o.className = css.join(' ')

  // Ligne supplémentaire et bouton "+"
  this.hasVerticalLine && this.buildVerticalLine()
  this.prolong    && this.buildLigneProlongation()
  this.isCadence  && this.buildSignePlusCadence()
  
  // Position et taille de la marque
  this.data.width   && this.applyWidth(this.width)
  this.data.height  && this.setHeight(this.height)
  this.setLeft(this.left)
  this.setTop(this.top)

  // Css suplémentaires
  this.applyCss()

}

buildSpanContent(){
  // La méthode est "détachée" de #build pour pouvoir être surclassée
  // par une méthode de classe fille. Un type image, par exemple, ne
  // construit pas un span mais une balise <img>
  return DCreate('SPAN', {class:'content', text:this.formated_content })
}

get formated_content(){
  if ( this.hasFormatedText && this.content ) {
    const str = this.markdownize(this.content)
    if ( this.subtype == 'bxt' ) {
      /** Boite de texte **/
      return '<span class="realcontent">' + str + '</span>'
    } else {    
      /** Content stylisé **/
      return str
    }
  } else {
    return this.content
  }
}
markdownize(str){
  return str.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>')
          .replace(/\*(.+?)\*/g, '<i>$1</i>')
          .replace(/\b_(.+?)_\b/g, '<u>$1</u>')
          .replace(/\^(te|re|er|e)/g, '<sup>$1</sup>')

}

/* --- Predicate Methods --- */

get isMark(){ return true }

get isCadence(){ return this.type == 'cad'}
get isPartie(){ return this.type == 'bbx' && this.subtype.startsWith('prt')}
get isSection(){ return this.type == 'bbx' && this.subtype.startsWith('sec')}
get isModulation(){return this.type == 'mod'}
get isEmprunt()   {return this.type == 'emp'}
get isText(){return this.type == 'txt'}
get hasFormatedText(){
  return this._hasformtxt || (this._hasformtxt = ['txt','bbx'].includes(this.type))
}

get isHresizable(){
  return this._ishresize || (this._ishresize = ['bbx','cir','seg','emp','txt'].includes(this.type))
}
get isVresizable(){
  return this._isvresize || (this._isvresize = (['bbx','emp'].includes(this.type)))
}

get is2dimResizable(){
  // Les objets qui sont redimensionnables dans les deux sens en même
  // temps (comme les images)
  return this._is2dimresize || (this._is2dimresize = (['img'].includes(this.type)))
}

get hasSigneMoinsCadence(){return this.signeMoinsCad }

// @return true si le type de marque est ajustable
get isTypeAjustable(){
  return this._isajust || (this._isajust = undefined != TYPES_AJUSTABLES[this.type])
}

// @return true si la marque a une ligne verticale
get hasVerticalLine(){
  return this.isPartie || this.isSection || this.isModulation
}

/* --- Observation Methods --- */

/**
 * Observation de la marque
 * 
 */
observe(){
  const my = this ;
  listen(this.obj, 'click', this.onClick.bind(this))
  listen(this.obj, 'dblclick', this.onDoubleClick.bind(this))
  if ( this.is2dimResizable ) {
    // Attention : là il s'agit bien d'objets dont les deux dimen-
    // sions se règlent EN MÊME TEMPS qui, donc, conservent leurs
    // proportions
    $(this.obj).resizable({
        aspectRatio: true
      , stop: function(e, ui){
          my.width  = my.getWidth.call(my)
          my.height = my.getHeight.call(my)
          my.ajustePosition.call(my)
      }
    })
  } else if ( this.isVresizable && this.isHresizable ) {
    $(this.obj).resizable({
        handles: 'e,s'
      , stop: function(e, ui){
          my.width  = my.getWidth.call(my)
          my.height = my.getHeight.call(my)
          my.ajustePosition.call(my)
      }
    })
  } else if ( this.isHresizable ) {
    $(this.obj).resizable({
      handles:'e'
    , stop: function(e, ui){
        my.width = my.getWidth.call(my)
      }
    })
  }
  if ( this.hasVerticalLine ) { 
    $(this.obj).resizable({
      handles: 's'
    , alsoResize: my.verticalLine
    , stop: function(e, ui) {
        my.height = my.verticalLine.offsetHeight
      }
    }) 
  }
  // Pour sélection avec MAJ par simple passage sur l'élément
  listen(this.obj, 'mouseover', this.onMouseOver.bind(this))
  listen(this.obj, 'mouseout',  this.onMouseOut.bind(this))
  // Pour tout déselectionner même lors d'un déplacement
  // cf. bug #10
  listen(this.obj, 'mousedown', this.onMouseDown.bind(this))

  // Draggable
  $(this.obj).draggable({
      rien:function(){}
    , drag:function(e,ui){
        // if ( e.shiftKey ){ ui.position.top = my.top }
        if ( this.forDuplication && !e.altKey ){
          // <= on a lâché la touche alt
          this.forDuplication = false
          my.obj.style.cursor = null
        } else {
          if ( my.isGrouped && e.shiftKey) {
            /*
            |  Pour voir les associés (groupe) se déplacer en même
            |  temps.
            */
            this.movedGrp || (this.movedGrp = my.grp.map(tid => {return AObjet.get(tid)}))
            var diffTop   = this.debTop - ui.offset.top
            var diffLeft  = this.debLeft - ui.offset.left
            this.movedGrp.forEach(tag => {
              tag.obj.style.top   = px(tag.top - diffTop)
              tag.obj.style.left  = px(tag.left - diffLeft)
            })
          }
        }
      }
    , start:function(e,ui){
        // console.log("Départ : ", {
        //   obj_top: my.top,
        //   obj_left: my.left,
        //   ui_top: ui.position.top,
        //   ui_left: ui.position.left
        // })
        this.movedGrp = undefined // pour les associés
        this.debTop  = 0 + parseInt(ui.position.top, 10)
        this.debLeft = 0 + parseInt(ui.position.left,10)
        if ( e.altKey ) {
          this.forDuplication = true
          this.initData = Object.assign({}, my.data)
          my.obj.style.cursor = 'copy'
        } else {
          this.forDuplication = false
          my.obj.style.cursor = null
        }
      }
    , stop:function(e,ui){
        // console.log("Fin : ", {
        //   obj_top: my.top,
        //   obj_left: my.left,
        //   ui_top: ui.position.top,
        //   ui_left: ui.position.left
        // })
        // console.log("-> stop")
        const diffTop   = this.debTop - ui.position.top
        const diffLeft  = this.debLeft - ui.position.left
        // console.log("diffLeft = %i / diffTop = %i", diffLeft, diffTop)
        my.obj.style.cursor = null
        let saufId = null
        if ( e.altKey && this.forDuplication ) {
          // Remettre l'original en place
          my.ajustePosition(this.initData.left, this.initData.top)
          // Créer la nouvelle marque
          var newMark = AMark.createNew(e, this.initData)
          newMark.ajustePosition(ui.position.left, ui.position.top)
          saufId = newMark.id
        } else {
          my.ajustePosition(ui.position.left, ui.position.top)
          my.justMoved = true // pour empêcher le re-select
          saufId = my.id
        }
        /**
         * S'il y a d'autres objets sélectionnés, on les 
         * déplace aussi
         */
        AObjet.eachSelection(ao => {
          if ( ao.id == saufId ) return
          ao.left = ao.left - diffLeft
          ao.top  = ao.top - diffTop
        })
        // console.log("<- stop")
      }
  })
}

onClick(e){
  if ( this.justMoved ) {
    this.justMoved = false
  } else {
    this.toggleFromSelection(/* keep_other = */ e.shiftKey)
  }
  return stopEvent(e)
}

/**
 * Quand on survole la marque, si la touche MAJ est pressée,
 * on ajoute la marque à la sélection (ou on la retire si elle
 * est déjà sélectionnée)
 */
onMouseOver(e){
  // console.log(e)
  if ( this.lastToggleSelectionTime && (e.timeStamp - this.lastToggleSelectionTime) < 1000) {
    return stopEvent(e)
  }
  // unlisten(this.obj, 'mouseover', this.onMouseOver.bind(this))
  if ( this.isOver ) return stopEvent(e)
  this.isOver = true
  if ( e.shiftKey ) {
    this.toggleFromSelection(/* keep_other = */ true)
    this.lastToggleSelectionTime = e.timeStamp
  }
  return stopEvent(e)
}
onMouseOut(e){
  this.isOver = false
  return stopEvent(e)
}

// cf. issue #10
onMouseDown(e){
  e.shiftKey || AObjet.deselectAll()
}

toggleFromSelection(keep_other){
  if ( this.isSelected ) {
    AObjet.removeFromSelection(this)
  } else {
    keep_other || AObjet.deselectAll()
    AObjet.addToSelection(this)
  }  
}

setSelected(){
  this.obj.classList.add('selected')
  this.obj.style.zIndex = 10
  this.isSelected = true
}
unsetSelected(){
  this.obj.classList.remove('selected')
  this.obj.style.zIndex = null
  this.isSelected = false
}

/**
 * Ajustement de la position
 * 
 * Si la marque est d'un type ajustable (harmonie, accord, modulation,
 * etc.) et que d'autres marques sont déjà présentes, on l'ajuste à
 * la position de ces marques.
 * 
 */
ajustePosition(left, top){
  const initTop = 0 + this.data.top
  this.left = left
  this.top  = top
  if (pref('adjust_same_mark') && this.isTypeAjustable ) {
    /*
    |  Ajustement précis de l'objet en fonction de son contexte
    */
    AObjet.checkPositionAndAdjust(this)
  }
  /*
  |  Si l'objet a été déplacé verticalement, il faut actualiser son
  |  appartenance à un système.
  */
  if ( initTop != this.top ) this.associateWithSystem()
}

/**
 * Traitement de la ligne verticale pour les styles :
 * - Partie (prt)
 * 
 */
buildVerticalLine(){
  const line  = DCreate('SPAN',{class:'vline'})
  this._vline = line
  this.obj.appendChild(line)
  // Caler sa hauteur en fonction de height ou de la hauteur du système
  this.setVerticalLineHeight(this.data.height || (this.system.top - this.data.top))
}

setVerticalLineHeight(v){
  this.verticalLine.style.height = px(v)
}

get verticalLine(){
  return this._vline
}

/**
 * Construction du bouton pour réduire la cadence
 * */
buildSigneMoinsCadence(){
  this.signeMoinsCad = DCreate('BUTTON', {class:'moins_sign', text:'➖'})
  this.obj.appendChild(this.signeMoinsCad)
  listen(this.signeMoinsCad,'click',this.onClickSigneMoinsCadence.bind(this))
}
destroySigneMoinsCadence(){
  unlisten(this.signeMoinsCad,'click',this.onClickSigneMoinsCadence.bind(this))
  this.signeMoinsCad.remove()
  this.signeMoinsCad = null
  delete this.signeMoinsCad
}


/**
 * TRAITEMENT SIGNE PLUS DE CADENCE
 * 
 */
get hasSignePlusCadence(){return this.signePlusCad}
buildSignePlusCadence(){
  this.signePlusCad = DCreate('BUTTON', {class:'plus_sign', text:'➕'})
  this.obj.appendChild(this.signePlusCad)
  listen(this.signePlusCad,'click',this.onClickSignePlusCadence.bind(this))
}
destroySignePlusCadence(){
  unlisten(this.signePlusCad,'click',this.onClickSignePlusCadence.bind(this))
  this.signePlusCad.remove()
  this.signePlusCad = null
  delete this.signePlusCad
}

/**
 * Quand on clique le signe "+" se trouvant dans une cadence,
 * on l'aggrandit jusqu'à l'accord précédent
 * 
 * Qu'est-ce qu'est un accord précédent ? C'est un objet qui est
 * avant (x <) et qui se trouve presque sur le même y (à 10 px
 * près)
 * 
 */
onClickSignePlusCadence(e){

  var previousMark = null
  var prevCandidats = []
  
  for(var aobj of AObjet.items) {
    // console.log("Candidat pour la cadence : ", aobj)
    
    if ( aobj.isSysteme ) {
      // console.log("C'est un système, je le passe")
      continue
    }
    if (aobj.id == this.id){
      // console.log("C'est cet objet, je passe")
      continue
    }
    // TODO : en fait, il faudrait partir du "vrai" left (mais
    // c'est peut-être déjà le vrai left qui est utilisé)
    if (aobj.left > this.left){
      // console.log("Marque trop à gauche, je la passe", aobj)
      continue
    }
    if (aobj.top < this.top - 15){
      // console.log("Marque trop haute, je la passe", aobj)
      continue
    }
    if (aobj.top > this.top + 15){
      // console.log("Marque trop basse, je la passe", aobj)
    }
    prevCandidats.push(aobj)
  }
  if ( prevCandidats.length ) {
    if ( prevCandidats.length == 1 ) {
      previousMark = prevCandidats[0]
    } else {
      // On prend le candidat le plus proche de la cadence
      previousMark = prevCandidats.pop()
      prevCandidats.forEach(aobj => {
        if ( aobj.left > previousMark.left ) previousMark = aobj
      })
    }
    // console.log("Marque précédente trouvée : ", previousMark)
    const newLeft = previousMark.left - 20
    var diff = this.left - newLeft
    this.left   = newLeft
    this.width  = diff + this.obj.offsetWidth
    this.obj.style.width = px(this.width)

    this.hasSigneMoinsCadence || this.buildSigneMoinsCadence()

  } else {
    erreur("Impossible de trouver une marque d'accord avant.<br/>Je ne peux pas rallonger la cadence.")
  }
  return stopEvent(e)
}


/**
 * Quand on clique sur le bouton "-" se trouvant dans une cadence
 * pour la raccoucir d'un accord.
 * 
 */
onClickSigneMoinsCadence(e){

  //
  // Pour simplifier, on supprime tout, donc on redonne à 
  // cet objet sa taille initial
  // Il faut aussi supprimer le bouton
  var newWidth = 130 // la largeur normale
  var curWidth = this.obj.offsetWidth
  var newLeft = this.left + (curWidth - newWidth)
  this.left = newLeft
  this.obj.style.width = px(newWidth)
  this.destroySigneMoinsCadence()
  return stopEvent(e)
}

/**
 * Pour construire la marque de la cadence
 * 
 * Rappel : ce type est consigné dans this.cadenceType
 * 
 */ 
marquerCadence(){
  let divMType = DGet('.mtype', this.obj)
  if ( !divMType ){
    divMType = DCreate('DIV', {class:'mtype'})
    this.obj.appendChild(divMType)
  }
  divMType.innerHTML = CADENCES[this.cadenceType].name
}

/**
 * TRAITEMENT LIGNE DE PROLONGATION
 * 
 */

buildLigneProlongation(){
  const my = this
  if ( my.hasProlongLine ) return
  my.prolongLine = DCreate('SPAN', {class:'pline'})
  my.obj.appendChild(this.prolongLine)
  my.data.width || my.applyWidth(200)
  // Resizable
  $(my.obj).resizable({
      alsoResize: my.prolongLine
    , handles: 'e'
    , start: function(e, ui){
      }
    , stop: function(e, ui){
        my.applyWidth(my.prolongLine.offsetWidth + my.contentSpan.offsetWidth + 20)
      }
  })
}

setProlongLineWidth(v){
  // longueur du span content + longueur de la ligne
  const lineWidth = v - (this.contentSpan.offsetWidth + 20)
  this.prolongLine.style.width = px(lineWidth)
  this.width = v
}

get hasProlongLine(){return not(undefined == this.prolongLine) }

destroyLigneProlongation(){
  if (this.hasProlongLine){
    this.prolongLine.remove()
    delete this.prolongLine
    $(this.obj).resizable("disable")
  }
}

get height(){
  if ( this.isPartie ) {
    if ( this.obj ) {
      return this.verticalLine.offsetHeight
    } else {
      return this.data.height
    }
  } else {
    return super.height
  }
}
set height(v){
  this.isPartie && this.setVerticalLineHeight(v)
  super.height = v
}

applyWidth(v) {
  const my  = this
  if ( my.hasProlongLine ) {
    my.setProlongLineWidth(v)
  } else {
    this.setWidth(this.width)
  }
}

get type(){return this._type}
set type(t){
  this.obj && this._type && this.obj.classList.remove(this._type)
  this._type = t
  this.data.type = t
  this.obj && this.obj.classList.add(this._type)
}
get subtype(){return this._subtype || (this._sybtype = this.data.subtype)}
set subtype(v){
  // On retire le sous-type éventuellement appliqué
  this.obj && this._subtype && this.obj.classList.remove(this._subtype)
  this._subtype = v
  this.data.subtype = v
  this.obj && this.obj.classList.add(this._subtype)
}

// Le contenu complet, avec préfixe (aka type). Pour l'édition, par
// exemple, il faut tout remettre
get content(){ return this._content || (this._content = this.data.content)}
set content(v){
  this._content = v
  this.data.content = v
  this.contentSpan && (this.contentSpan.innerHTML = this.formated_content )
}

  get domId(){return this._domid || (this._domid = `amark-${this.id}`)}
}
