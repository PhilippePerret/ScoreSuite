'use strict';
/**

  Class Form / et class FormObj
  ----------
  Gestion de la forme du morceau

  TODO
  ----
  * La marque de type 'mea' (mesure) pour savoir où se trouvent les
    partie


  

*/
class Form {


  static getData(){
    /** Récupère les données à enregistrer (s'il y en a) **/
    if ( this.items.length == 0 ) return null
    var alldata = []
    this.items.forEach(fobj => alldata.push(fobj.data))
    return alldata
  }

  static setData(alldata){
    this.items = []
    if ( not(alldata) || alldata.length == 0 ) return
    alldata.forEach(dobj => {
      const fobj = new FormObj(dobj)
      this.add(fobj)
    })
  }

  static updateOrdreObjets(){
    /** Après une modification quelconque, on actualise toujours 
     ** l'ordre des éléments par mesure, dans l'affichage générale
     ** de la forme ainsi que dans le menu 'Parent'
     **/
    const menuParents = FormObj.menuParents
    menuParents.innerHTML = ''
    this.items.sort(function(a,b){
      return a.start - b.start
    }).forEach(fobj => {
      /*
      |  Dans le menu 'Parent de…'
      */
      menuParents.appendChild(DCreate('OPTION',{value:fobj.id, text:fobj.name}))
      /*
      |  Dans l'affichage de la forme
      */
      this.listing.appendChild(fobj.obj)
    })
  }

  static onAddObjet(e){
    /** Appelée quand on clique sur le bouton "+" pour ajouter un
     ** objet formel. La méthode le crée et l'ajoute à la liste
     **/
    const fobj = new FormObj({id:this.items.length + 1})
    this.add(fobj)
    fobj.edit.call(fobj)
  }


  static add(fobj){
    /** Ajoute l'objet form +fobj+
     ** La méthode est aussi bien appelée à la création d'un nouvel
     ** objet formel qu'au chargement de l'analyse. 
     **/
    this.items.push(fobj)
    fobj.buildInList(this.listing)
  }


  static onDblClick(e){
    // Pour ne rien déclencher quand on double-click
    return stopEvent(e)
  }


  static init(){
    this.observe()
    this.items = []
    /*
    |  Peupler le menu des types d'objets forme
    */
    const menuTypes = DGet('select#fobj_types', this.panel)
    for(var type in FORMOBJ_TYPES){
      menuTypes.appendChild(DCreate('OPTION',{value:type, text:FORMOBJ_TYPES[type].name}))
    }
  }
  static observe(){
    listen(this.panel, 'dblclick', this.onDblClick.bind(this))
    listen(this.btnToggle,'click', this.togglePanel.bind(this))
    listen(this.btnAdd, 'click', this.onAddObjet.bind(this))
  }
  /**
  * Ouverture et fermeture du panneau de forme
  */
  static togglePanel(){this[this.isOpened ? 'hide' : 'show'].call(this)}
  static hide(){this.panel.classList.add('hidden');this.isOpened = false}
  static show(){this.panel.classList.remove('hidden');this.isOpened = true}


  /* --- HTML Objets --- */

  static get listing(){return this._lstobj||(this._lstobj = DGet('#form_objets'))}
  static get panel(){return this._panel || (this._panel = DGet('#panel_form'))}
  /* - boutons - */
  static get btnToggle(){return DGet('#form_button')}
  static get btnAdd(){return DGet('.btn-add', this.panel)}

}

/**
  
  class FormObj
  -------------
  Un objet formel. C'est par exemple une section, une partie

  Properties
  ----------
    type:       entre : partie, section, segment, 
    name:       Son nom
    start:    Première mesure/temps (<measure>:<temps>)
    end:      Dernière mesure/temps (<measure>:<temps>)
    inPlan:   Si true, est affiché dans le plan sur la table
    tag:      La marque (bloc de texte) qui contient l'objet formel

*/
class FormObj {

  static get(fobj_id){
    return Form.items[Number(fobj_id) - 1]
  }

  static get objTemplate(){return DGet('#formobj_template')}
  static get menuTypes(){ return this._menutypes || (this._menutypes = DGet('select#fobj_types'))}
  static get menuParents(){return this._menuparents || (this._menuparents = DGet('select#fobj_parents'))}


  static hideMenuTypeAndReturnValue(){
    this.menuTypes.classList.add('hidden')
    return this.menuTypes.value
  }
  static hideMenuParentAndReturnValue(){
    this.menuParents.classList.add('hidden')
    return this.menuParents.value
  }
  static showMenuTypesAndSetValue(fobj){
    this.menuTypes.classList.remove('hidden')
    fobj.fieldType.parentNode.insertBefore(this.menuTypes, fobj.fieldType)
    this.menuTypes.value = fobj.type
  }
  static showMenuParentAndSetValue(fobj){
    this.menuParents.classList.remove('hidden')
    fobj.fieldParent.parentNode.insertBefore(this.menuParents, fobj.fieldParent)
    this.menuParents.value = fobj.parent
  }

  constructor(data){
    this.data = data
  }

  edit(){
    /** Mise en édition de l'objet forme
     **/
    /*
    |  On remplace son champ input-text par son menu des types
    */
    this.toggleState()
    FormObj.showMenuTypesAndSetValue(this)
    this.fieldType.classList.add('hidden')
    FormObj.showMenuParentAndSetValue(this)
    this.fieldParent.classList.add('hidden')
  }

  save(){
    Form.updateOrdreObjets()
    this.toggleState()
    Analyse.current && Analyse.current.setModified()
  }

  setButtons(foredit){
    /** Réglage des petits boutons **/
    DGet('span.mini-btns', this.obj).classList[foredit?'add':'remove']('editing')
    DGet('button.btn-edit', this.obj).classList[foredit?'add':'remove']('hidden')
    DGet('button.btn-save', this.obj).classList[foredit?'remove':'add']('hidden')
    DGet('button.btn-delete', this.obj).classList[foredit?'remove':'add']('hidden')
  }

  onEdit(e){
    this.edit.call(this)
    return stopEvent(e)
  }

  onSave(e){
    /*
    |  On remplace le menu des types par son champ input-text
    */
    this.fieldType.classList.remove('hidden')
    this.type = FormObj.hideMenuTypeAndReturnValue()
    this.fieldType.innerHTML = FORMOBJ_TYPES[this.type].name
    this.parent = FormObj.hideMenuParentAndReturnValue()
    this.fieldParent.innerHTML = this.parent ? FormObj.get(this.parent).name : 'La pièce'
    this.tons   = this.getTonalites()
    this.name   = DGet('input.fobj-name', this.obj).value || `${FORMOBJ_TYPES[this.type].name} sans nom`
    this.start  = DGet('input.fobj-start',this.obj).value || 0
    this.end    = DGet('input.fobj-end', this.obj).value
    this.inplan = DGet('input.fobj-inplan').checked
    this.save()
    return stopEvent(e)
  }

  onClickDelete(e){
    message("Je dois apprendre à supprimer un élément")
    return stopEvent(e)
  }

  getTonalites(){
    var tons = []
    for(var i = 1; i < 7; ++i){
      var ton = DGet(`input.fobj-ton${i}`, this.obj).value
      ton && tons.push(ton)
    }
    return tons
  }

  setValues(){
    /** 
     ** Pour mettre les valeurs dans les champs
     ** (après la construction de l'objet dans sa liste)
    **/
    for(var prop in this.data){
      const value = this.data[prop]
      if ( prop == 'tons') {
        this.setTonalites(this.data.tons)
      } else {
        const oprop = DGet(`.fobj-${prop}`, this.obj) // n'existe pas toujours
        if ( not(oprop) ) {
          console.warn("L'objet .fobj-%s n'existe pas", prop)
          continue
        }
        switch(prop){
        case 'inplan':
          oprop.checked = value
          break
        case 'type':
          oprop.innerHTML = FORMOBJ_TYPES[value].name
          break
        case 'parent':
          oprop.innerHTML = value ? Form.get(Number(value)).name : '---'
          break
        default:
          oprop.value = value
        }
      }
    }
    this.setState(/* inEdition = */ false)
  }

  setTonalites(tonalites){
    tonalites = tonalites || []
    for(var i = 1; i < 7; ++i){
      DGet(`input.fobj-ton${i}`, this.obj).value = tonalites[i-1]||''
    }
  }

  toggleState(){
    const inEdition = not(this.obj.dataset.edit == 'true')
    this.setState(inEdition)
  }

  setState(inEdition){
    DGetAll('input', this.obj).forEach(o => o.disabled = not(inEdition))
    this.obj.dataset.edit = inEdition ? 'true' : 'false'
    this.setButtons(inEdition)
  }

  buildInList(container){
    /** Construction dans le listing de la forme.
     **/
    const o = this.constructor.objTemplate.cloneNode(true)
    o.id = this.domId
    this.obj = o
    container.appendChild(o)
    o.classList.remove('hidden')
    /* - Réglage plus fin - */
    DGet('.fobj-inplan', o).id = `fobj-${this.id}-disp`
    // console.debug("o = ", o)
    DGet('label.fobj-disp-lab', o).setAttribute('for', `fobj-${this.id}-disp`)
    /*
    |  On peut mettre les valeurs
    */
    this.setValues()
    /*
    |  Observation des éléments
    */
    listen(DGet('button.btn-edit', o)   ,'click'  ,this.onEdit.bind(this))
    listen(DGet('button.btn-save', o)   ,'click'  ,this.onSave.bind(this))
    listen(DGet('button.btn-delete', o) ,'click'  ,this.onClickDelete.bind(this))
  }
  

  buildOnTable(){
    /** Construction sur la table d'analyse, au curseur **/
  }


  get id(){return this.data.id}
  get name(){return this.data.name || ''}
  set name(v){this.data.name = v}
  get type(){return this.data.type}
  set type(v){this.data.type = v}
  get start(){return this.data.start ? Number(this.data.start) : ''}
  set start(v){this.data.start = v}
  get end(){return this.data.end ? Number(this.data.end) : ''}
  set end(v){this.data.end = v}
  get tons(){return this.data.tons || []}
  set tons(v){this.data.tons = v}
  get inplan(){return this.data.inplan}
  set inplan(v){this.data.inplan = v}

  /* --- Volatile Values --- */

  get domId(){return this._domid || (this._domid = `fobj-${this.id}`)}
  get fieldType(){ return DGet('span.fobj-type', this.obj)}
  get fieldParent(){ return DGet('span.fobj-parent', this.obj)}

}
