'use strict';
/**


  class NewConfiguration
  ----------------------
  Gestion nouvelle des configurations

  Utiliser la constance Config
  Par exemple : Config.getData()

*/

/**
* Données de configuration
* 
* Les méthodes get (getter de valeur), si elles sont particulières,
* doivent porter un nom en fonction de domId, en replaçant les 
* "-<minuscule>" par des "<majuscules>" avec "get" devant. Par 
* exemple : 'piece-metrique' => setPieceMetrique et getPieceMetrique
* 
* Méthodes onChange
* ------------------
* Si Config répond à une méthode dont le nom est :
*     onChange_<domId camélisé>
*     (par exemple, pour mscore-first-mesure :
*        onChange_mscoreFirstMesure(e))
* … alors cette méthode sera automatiquement appelée au changement
* d'une valeur dans ce champ.
*/
const NEWCONFIGS_DATA = [
    {domId:'piece-tune-note'      ,default:'C'}
  , {domId:'piece-tune-alter'     ,default:'='}
  , {domId:'piece-metrique'       ,default:'C'}
  , {domId:'piece-staves-dispo'   ,default:'piano'}
  , {domId:'mscore-image-name'    ,default:'essai'}
  , {domId:'mscore-format-page'   ,default:'A4'}
  , {domId:'mscore-first-mesure'  ,default:null ,type:'int'}
  , {domId:'mscore-proximity'     ,default:5    ,type:'int'}
  , {domId:'mscore-opt-barres'    ,default:true ,type:'cb'}
  , {domId:'mscore-opt-stems'     ,default:true ,type:'cb'}
  , {domId:'mscore-tune-fixed'    ,default:false,type:'cb'}
  , {domId:'mscore-staves-vspace' ,default:'9'}
  , {domId:'ui-disposition'       ,default:'left_right'}
  , {domId:'ui-auto-build'        ,default:false,type:'cb'}
]

/**
* Fabrication de la table de configuration
* (pour pouvoir obtenir les données de configuration à partir de 
*  leur clé)
*/
const NEWCONFIGS_TABLE = {}
NEWCONFIGS_DATA.forEach(dconfig => {
  Object.assign(NEWCONFIGS_TABLE, {[dconfig.domId]: dconfig})
})

class NewConfiguration {

  /* --- Public Methods --- */

  reset(){
    delete this._tbldata
    this._tbldata = undefined
  }

  get(key) { 
    /** @return La valeur de configuration de clé +key+. **/
    return this.tableData[key] }
  getValueOf(key){ 
    /** @alias  **/
    return get(key) }
  set(key, value){
    /** Actualise la valeur, mais seulement dans la tableData
     ** (pour ne pas avoir à tout réactualiser)
     **/
    Object.assign(this.tableData, {[key]: value})
  }

  get tableData(){
    /** {Object} Table de toutes les valeurs de configuration 
     ** relevées par this.getData. En clé l'identifiant (key) de
     ** la valeur de configuration, avec trait ou trait plat (par
     ** exemple 'mscore-image-name' ou 'mscore_image_name') et en
     ** valeur sa valeur définie ou par défaut.
     ** Note : c'est cette table qui est enregistrée dans le fichier
     ** .config de l'image.
     **/
    return this._tbldata || (this._tbldata = this.getData())
  }

  /* --- Raccourcis pour les données --- */

  get imageName(){
    return this.get('mscore-image-name')
  }
  set imageName(v){
    this.setValue('mscore-image-name', v)
  }

  get firstMesure(){
    return this.get('mscore-first-mesure') || 1
  }

  get stavesCount(){
    /** @return le nombre de portées **/
    var dispo
    switch(dispo = this.get('piece-staves-dispo')){
    case 'piano':         return 2
    case 'sonate-violon': return 3
    case 'quatuor':       return 4
    default:              return Number(dispo)
    }
  }

  get tune(){
    return this.getPieceTune() // valeur composite (2 selects)
  }
  set tune(v){
    this.setPieceTune(v) // valeur composite (2 selects)
  }

  get tuneIsFixed(){
    /** @return true si les hauteurs de notes sont en valeur
     ** absolues.
     **/
    return this.get('mscore-tune-fixed')
  }

  get updateAfterChange(){
    /** @return true s'il faut actualiser l'image après toute
     ** modification de mesure
     **/
    return this.get('ui-auto-build')
  }

  get proximity(){
    /** @return la proximité ou null **/
    const p = this.get('mscore-proximity')
    return p == 5 ? null : p
  }

  get isOneStaffNotC(){
    /** @return true si la configuration des portées comporte une
     ** seule portée et que cette portée n'est pas en clé de SOL
     **/
    const dispo = this.get('piece-staves-dispo')
    return dispo.length == 1 && dispo[0].key != 'G'
  }

  get UIDisposition(){
    /** @return la configuration de l'écran **/
    return this.get('ui-disposition')
  }

  /* --- Functional Methods --- */

  getData(){
    /** = main =
     ** Main method qui récolte toutes les données afin de pouvoir
     ** les enregistrer dans la configuration de l'image.
     ** 
     ** La relève fonctionne ainsi :
     **   - s'il existe une méthode pour relever la donnée, on
     **     l'utilise.
     **   - sinon, on relève simplement la valeur dans le panneau
     ** 
     ** @return La table des données qu'il suffit d'enregistrer pour
     ** l'image donnée.
     **/
    var data = {app_version: App.version}
    NEWCONFIGS_DATA.forEach(dconfig => {
      var value ;
      const domId = dconfig.domId
      const propN = domId.replace(/\-([a-z])/g, '_$1')
      const getMethod = `get-${domId}`.replace(/\-([a-z])/g,function(tout, lettre){return lettre.toUpperCase()})
      if ( 'function' == typeof this[getMethod] ){
        value = this[getMethod].call(this)
      } else {
        const obj = DGet(`#config-${domId}`)
        switch(dconfig.type){
        case 'cb':
          value = !!obj.checked; break
        case 'int':
          value = obj.value || dconfig.default
          value = value && parseInt(value,10)
          break
        default:
          value = obj.value || dconfig.default
        }
      }
      /*
      |  On met la valeur dans la table, sous les deux noms de 
      |  propriété, avec tiret et avec tiret plat.
      */
      Object.assign(data, {[propN]: value, [domId]: value})
      /*
      |  On les met aussi dans la donnée de configuration (même si
      |  ça ne sert à rien pour le moment)
      */
      Object.assign(dconfig , {value: value, prop: propN})
    })
    console.debug("Data config à enregistrer", data)
    return data
  }

  setData(data){
    /** = main =
     ** 
     ** Main method qui reçoit les données de configuration de l'image
     ** et les applique au panneau des configurations.
     ** 
     **/
    const dataKeys = Object.keys(data)
    NEWCONFIGS_DATA.forEach(dconfig => {
      const domId = dconfig.domId
      const propN = domId.replace(/\-([a-z])/g, '_$1')
      if ( not(dataKeys.includes(propN)) ) return ;
      const value = data[propN]
      console.log("Set propriété '%s' avec la valeur %s", propN, value)
      this.setValue(domId, value)
    })
  }

  setValue(key, value){
    /** Pour régler une valeur unique
     **/
    const dconf = NEWCONFIGS_TABLE[key] || raise(`La clé '${key}' est introuvable dans les données de configurations.`)
    const setMethod = `set-${key}`.replace(/\-([a-z])/g,function(tout, lettre){return lettre.toUpperCase()})
    if ( 'function' == typeof this[setMethod] ){
      /*
      |  Une méthode dédiée pour appliquer la valeur
      */
      this[setMethod].call(this, value)
    } else {
      /*
      |  Ou on la met telle quelle dans son champ
      */
      const obj = DGet(`#config-${key}`)
      switch(dconf.type){
      case 'cb':
        obj.checked = value
        break
      default:
        obj.value = value
      }
      /*
      |  Si une méthode onChange existe, il faut l'appeler
      */
      const meth = `onChange_${key}`.replace(/\-([a-z])/g,function(tout, lt){return lt.toUpperCase()})
      if ('function' == typeof this[meth]) {this[meth].call(this) }
    }
  }

  initialize(){
    /** Applique les données de configuration par défaut
     ** La méthode est appelée par le bouton "Tout réinitialiser"
     **/
    var data = {}
    NEWCONFIGS_DATA.forEach(dconfig => {
      const domId = dconfig.domId
      const propN = domId.replace(/\-([a-z])/g, '_$1')
      Object.assign(data, {[propN]: dconfig.default})
    })
    this.setData(data)
  }

  prepare(){
    /** Prépare le panneau de configuration
     ** Pour le moment, ne fait que poser les observeurs sur les
     ** champs qui doivent être suivis.
     **/
    NEWCONFIGS_DATA.forEach(dconfig => {
      const propCam = dconfig.domId.replace(/\-([a-z])/g, function(tout, lettre){return lettre.toUpperCase()})
      const onChangeMeth = `onChange_${propCam}`
      if ( 'function' == typeof this[onChangeMeth] ) {
        console.debug("Je pose un observer onChange sur le champ 'config-%s'", dconfig.domId)
        const obj = DGet(`#config-${dconfig.domId}`)
        listen( obj,'change', this[onChangeMeth].bind(this) )
      }
    })
  }

  onChange_uiDisposition(){
    /** Méthode appelée quand on change la disposition de l'interface
     **/
    UI.setDisposition.call(UI, this.menuDisposition.value)
  }

  get menuDisposition(){
    return DGet('select#config-ui-disposition')
  }

  /* 
    --- Staff Methods ---
  */
  setMenuDisposition(value){
    this.menuStaffDispo.value = value
  }

  setPieceStavesDispo(value){
    /** Application de la disposition des portées dans le panneau
     ** de configuration
    ***/
    /*
    |  On efface les éventuelles définition de portées
    */
    this.divOtherStaves.innerHTML = ""
    switch(value){
    case'piano': case'sonate-violon':case'quatuor':
      this.setMenuDisposition(value)
      break
    default:
      /*
      |  Un nombre déterminé de portées, avec des définitions
      */
      var idx = 0
      value.forEach(dstaff => {
        this.setStaff(dstaff, ++idx)
      })
    }
  }
  getPieceStavesDispo(){
    /** Récupération de la disposition des portées dans le panneau
     ** de configuration.
     **/
    var value;
    switch(value = this.menuStaffDispo.value){
    case'piano':case'sonate-violon':case'quatuor':
      return value
    default:
      /*
      |  Un nombre de mesures défini, avec clé et nom
      */
      const staffCount = Number(value)
      const staves = []
      for(var i = 1; i <= staffCount; ++i ) {
        const div = DGet(`divrow#config-staff-${i}`)
        staves.push({
            key:  DGet('select.staff-key', div).value
          , name: DGet('input.staff-name', div).value
        })
      }
      return staves
    }
  }

  /**
  * Méthode appelée lorsque l'on change la valeur du nombre de
  * portées (la disposition, ou le dispositif).
  */
  onChange_pieceStavesDispo(){
    this.divOtherStaves.innerHTML = ""
    var dispo = this.menuStaffDispo.value
    switch(dispo){
    case'piano': case'sonate-violon':case'quatuor':
      this.hideFirstStaff()
      this.menuStaffDispo.value = dispo
      break
    default:
      /*
      |  Un nombre déterminé de portées (avec clé et nom)
      */
      this.showFirstStaff()
      this.setStaff({key:'G',name:''}, 1)
      dispo = Number(dispo)
      for ( var idx = 2; idx <= dispo; ++idx){
        this.buildStaff(idx)
      }
    }
  }

  setStaff(staffData, index){
    const divStaff = DGet(`divrow#config-staff-${index}`) || this.buildStaff(index)
    DGet('select.staff-key', divStaff).value = staffData.key
    DGet('input.staff-name', divStaff).value = staffData.name
  }

  buildStaff(index){
    const divS = this.divFirstStaff.cloneNode(true)
    divS.id = `config-staff-${index}`
    DGet('span.staff-index', divS).innerHTML = index
    this.divOtherStaves.appendChild(divS)
    return divS
  }

  showFirstStaff(){this.divFirstStaff.classList.remove('hidden')}
  hideFirstStaff(){this.divFirstStaff.classList.add('hidden')}

  get menuStaffDispo(){
    return DGet('select#config-piece-staves-dispo')
  }
  get divOtherStaves(){
    return DGet('div#config-other-staves')
  }
  get divFirstStaff(){
    return DGet('divrow#config-staff-1')
  }

  /* 
    -- F
  */

  /* 
    --- Tune Methods ---
  */

  getPieceTune(){
    var t = this.menuTuneNote.value
    switch(this.menuTuneAlteration.value){
      case '=': return t
      case 'b': return t + 'es'
      case '#': return t + 'is'
    }
  }
  setPieceTune(tune){
    this.menuTuneNote.value = tune.substring(0,1)
    this.menuTuneAlteration.value = (function(v){
      switch(v.substring(1, v.length)){
      case ''   : return '='
      case 'es' : return 'b'
      case 'is' : return '#'
      }
    })(tune)
  }

  get menuTuneNote(){
    return DGet('select#config-piece-tune-note')
  }
  get menuTuneAlteration(){
    return DGet('select#config-piece-tune-alter')
  }

  /* 
    --- Metrique Methods --- 
  */

  getPieceMetrique(){
    const value = this.menuMetrique.value
    if ( value == '') {
      return null
    } else if ( value == 'xxx' ) {
      return this.fieldAutreMetrique.value || 'C'
    } else {
      return value
    }
  }
  setPieceMetrique(value){
    if ( DGet(`option[value="${value}"]`,this.menuMetrique) ) {
      this.menuMetrique.value = value
    } else {
      this.menuMetrique.value = 'xxx'
      this.fieldAutreMetrique.value = value
    }
    this.onChange_pieceMetrique()
  }

  /**
  * Méthode appelée quand on change la métrique (pour gérer le champ
  * qui permet d'en mettre une "à la main")
  */
  onChange_pieceMetrique(){
    const isVisible = this.menuMetrique.value == 'xxx'
    this.fieldAutreMetrique.classList[isVisible?'remove':'add']('invisible')
  }

  get menuMetrique(){
    return DGet('select#config-piece-metrique')
  }
  get fieldAutreMetrique(){
    return DGet('input#config-piece-autre-metrique')
  }

  /* --- First Measure Methods --- */

  onChange_mscoreFirstMesure(e){
    const number = this.fieldFirstMeasure.value
    this.set('mscore-first-mesure', number || null)
    MesureCode.onChangeFirstMesureNumber.call(MesureCode, number)
  }

  get fieldFirstMeasure(){
    return DGet('#config-mscore-first-mesure')
  }

  /* --- General Methods --- */


  /**
  * Méthode appelée par les boutons "Appliquer" et "Tout effacer et
  * appliquer"
  * Si +resetAll+ est true, il faut tout effacer.
  */
  applyConfig(resetAll){
    console.debug("Je dois apprendre à appliquer les choix")

  }

}

const Config = new NewConfiguration()
