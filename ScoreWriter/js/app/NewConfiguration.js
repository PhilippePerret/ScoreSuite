'use strict';
/**


  class NewConfiguration
  ----------------------
  Gestion nouvelle des configurations

*/

/**
* Données de configuration
* 
* Les méthodes get (getter de valeur), si elles sont particulières,
* doivent porter un nom en fonction de domId, en replaçant les 
* "-<minuscule>" par des "<majuscules>" avec "get" devant. Par 
* exemple : 'piece-metrique' => setPieceMetrique et getPieceMetrique
*/
const NEWCONFIGS_DATA = [
    {domId:'piece-tune-note'      ,default:'C'}
  , {domId:'piece-tune-alter'     ,default:'='}
  , {domId:'piece-metrique'       ,default:'C'}
  , {domId:'piece-staves-dispo'   ,default:'piano'}
  , {domId:'mscore-image-name'    ,default:'essai'}
  , {domId:'mscore-format-page'   ,default:'A4'}
  , {domId:'mscore-first-mesure'  ,default:'1'}
  , {domId:'mscore-proximity'     ,default:'5'}
  , {domId:'mscore-opt-barres'    ,default:true, type:'cb'}
  , {domId:'mscore-opt-stems'     ,default:true, type:'cb'}
  , {domId:'mscore-tune-fixed'    ,default:false, type:'cb'}
  , {domId:'mscore-staves-vspace' ,default:'9'}
  , {domId:'ui-disposition'       ,default:'left_right'}
]

class NewConfiguration {

  /**
  * = main =
  * Main method qui récolte toutes les données afin de pouvoir
  * les enregistrer dans la configuration de l'image.
  * 
  * La relève fonctionne ainsi :
  *   - s'il existe une méthode pour relever la donnée, on
  *     l'utilise.
  *   - sinon, on relève simplement la valeur dans le panneau
  * 
  * @return La table des données qu'il suffit d'enregistrer pour
  * l'image donnée.
  */
  static getData(){
    var data = {}
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
        default:
          value = obj.value
        }
      }
      Object.assign(data, {[propN]: value})
      /*
      |  On les met aussi dans la donnée de configuration
      */
      Object.assign(dconfig , {value: value, prop: propN})
    })
    // console.debug("Data config à enregistrer", data)
    return data
  }

  /**
  * = main =
  * 
  * Main method qui reçoit les données de configuration de l'image
  * et les applique au panneau des configurations.
  * 
  */
  static setData(data){
    const dataKeys = Object.keys(data)
    NEWCONFIGS_DATA.forEach(dconfig => {
      const domId = dconfig.domId
      const propN = domId.replace(/\-([a-z])/g, '_$1')
      if ( not(dataKeys.includes(propN)) ) return ;
      const value = data[propN]
      // console.log("Set propriété '%s' avec la valeur %s", propN, value)
      const setMethod = `set-${domId}`.replace(/\-([a-z])/g,function(tout, lettre){return lettre.toUpperCase()})
      if ( 'function' == typeof this[setMethod] ){
        this[setMethod].call(this, value)
      } else {
        DGet(`#config-${domId}`).value = value
      }
    })
  }

  /**
  * Méthode appelée quand on change la disposition de l'interface
  */
  static onChangeUIDisposition(){
    UI.setDisposition.call(UI, this.menuDisposition.value)
  }

  /* 
    --- Staff Methods ---
  */
  static setPieceStavesDispo(value){
    /*
    |  On efface les éventuelles définition de portées
    */
    this.divOtherStaves.innerHTML = ""
    switch(value){
    case'piano': case'sonate-violon':case'quatuor':
      this.menuStaffDispo.value = value
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
  static getPieceStavesDispo(){
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
  static onChangeStaffDispo(){
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

  static setStaff(staffData, index){
    const divStaff = DGet(`divrow#config-staff-${index}`) || this.buildStaff(index)
    DGet('select.staff-key', divStaff).value = staffData.key
    DGet('input.staff-name', divStaff).value = staffData.name
  }

  static buildStaff(index){
    const divS = this.divFirstStaff.cloneNode(true)
    divS.id = `config-staff-${index}`
    DGet('span.staff-index', divS).innerHTML = index
    this.divOtherStaves.appendChild(divS)
    return divS
  }

  static showFirstStaff(){this.divFirstStaff.classList.remove('hidden')}
  static hideFirstStaff(){this.divFirstStaff.classList.add('hidden')}

  static get menuStaffDispo(){
    return DGet('select#config-piece-staff-dispo')
  }
  static get divOtherStaves(){
    return DGet('div#config-other-staves')
  }
  static get divFirstStaff(){
    return DGet('divrow#config-staff-1')
  }

  /* 
    --- Metrique Methods --- 
  */

  static getPieceMetrique(){
    const value = this.menuMetrique.value
    if ( value == 'xxx' ) {
      return this.fieldAutreMetrique.value || 'C'
    } else {
      return value
    }
  }
  static setPieceMetrique(value){
    if ( DGet(`option[value="${value}"]`,this.menuMetrique) ) {
      this.menuMetrique.value = value
    } else {
      this.menuMetrique.value = 'xxx'
      this.fieldAutreMetrique.value = value
    }
    this.onChangeMetrique()
  }

  /**
  * Méthode appelée quand on change la métrique (pour gérer le champ
  * qui permet d'en mettre une "à la main")
  */
  static onChangeMetrique(){
    const isVisible = this.menuMetrique.value == 'xxx'
    this.fieldAutreMetrique.classList[isVisible?'remove':'add']('invisible')
  }

  static get menuMetrique(){
    return DGet('select#config-piece-metrique')
  }
  static get fieldAutreMetrique(){
    return DGet('input#config-piece-autre-metrique')
  }


  /* --- General Methods --- */


  /**
  * Méthode appelée par les boutons "Appliquer" et "Tout effacer et
  * appliquer"
  * Si +resetAll+ est true, il faut tout effacer.
  */
  static applyConfig(resetAll){
    console.debug("Je dois apprendre à appliquer les choix")

  }



  /* --- HTML Elements --- */


  static get menuDisposition(){
    return DGet('select#config-ui-disposition')
  }

}
