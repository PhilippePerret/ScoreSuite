'use strict';
/**
 * Class OptionsClass
 * 
 * Pour gérer les options et la configuration
 * 
 */

// Constante des types de champ par option
const DATA_OPTIONS = {
    'page':           {type:'select'}
  , 'mesure':         {type:'text'}
  , 'systeme':        {type:'select_or_other'}
  , 'proximity':      {type:'select'}
  , 'barres':         {type:'checkbox'}
  , 'stems':          {type:'checkbox'}
  , 'tune'    :       {type:'method', getter:'getTune', setter:'setTune'}
  , 'time'    :       {type:'select'}
  , 'auto_update_after_change': {type:'checkbox'}
  , 'staves_vspace':  {type:'text'}
  , 'staves'        : {type:'method', getter:'getStaves', setter:'setStaves'}
  , 'staves_names'  : {type:'none'}
  , 'staves_keys'   : {type:'none'}
  , 'disposition':    {type:'select'}
  , 'note_tune_fixed':{type:'checkbox'}
}

class OptionsClass {

/**
 * = public methods pour obtenir directement des valeurs avec
 *    Opions.<prop>
 * 
 */
get auto_update_after_change(){
  return this.getProperty('auto_update_after_change')
}

// Pour pouvoir faire Options.note_tune_fixed
get note_tune_fixed(){
  return this.getProperty('note_tune_fixed') 
}

/**
 * Initialiser les options
 * 
 * Ça consiste principalement à :
 *    - définir les propriétés Options.<property>
 *    - initialiser les valeurs aux valeurs par défaut
 * 
 */
init(){
  // 
  // On applique les réglages par défaut
  // 
  this.applique(CONFIG.default_options)
}

/**
 * Sauver les options
 * 
 */
save(){
  WAA.send({
    class:  'ScoreWriter::App',
    method: 'saveConfig',
    data:   {
        path:   Score.path
      , config: this.getAllValues()
    }
  })
}

/**
 * Méthode appelée par le bouton "Tout effacer et appliquer ces 
 * options"
 * Applique la configuration choisie.
 */
apply(reset){
  if (reset) {
    MesureCode.resetAll.call(MesureCode)
  } else {
    // Nombre de portées avant changement
    const mesun = MesureCode.table_mesures[0]
    const oldPorteesCount = mesun.nombrePortees
    console.log("Nombre de portées courant : ", oldPorteesCount)
    // Nombre de portées après changement
    const newPorteesCount = Score.nombrePortees
    console.log("Nouveau nombre de portées", newPorteesCount)
    if ( newPorteesCount != oldPorteesCount ) {
      console.log("Le nombre de portées a changé (%i -> %i). Il faut actualiser l'affichage.", oldPorteesCount, newPorteesCount)
      // TODO : il faut aussi ajouter une ligne avec du code (vide) dans
      // les mesures
      if ( newPorteesCount  < oldPorteesCount ) {
        /**
         * Si le nouveau nombre de portées est inférieur au nombre
         * actuel, il suffit de retirer le nombre voulu
         */
        // confirmation
        const methodOK = this.removeSystems.bind(this, oldPorteesCount - newPorteesCount)
        confirm("Cette opération détruit le code des portées supprimées. Êtes-vous sûr de vouloir procéder à cette opération ?", methodOK)
      } else /**/ {
        /**
         * 
         * Construction des nouvelles portées/systèmes
         * 
         * Si le nouveau nombre de portées est supérieur au nombre
         * actuel, il faut construire de nouvelles portées. 
         * Noter que dans ce cas, il est inutile de mettre un message
         * d'alerte de suppression comme dans l'autre cas
         */
        const firstPortee = oldPorteesCount + 1
        MesureCode.each(mescode => {
          for(var i = firstPortee; i <= newPorteesCount; ++i) {
            mescode.createPortee(i)
          }
        })
      }
    }
  }
  // console.log("table_mesures :", MesureCode.table_mesures)
}

/**
 * Méthode générale pour supprimer +nombre+ systèmes dans chaque
 * mesure.
 */
removeSystems(nombre){
  MesureCode.each(mescode => {
    mescode.removeSystems(nombre)
  })

}

getAllValues(){
  var actualData = {}
  for(const key in DATA_OPTIONS){
    Object.assign(actualData, {[key]: this.getProperty(key)})
  }
  console.info("this.actualData = ", actualData)
  return actualData
}

/**
 * Retourne TRUE si les données ont changé
 */
hasChangedFrom(oldData){
  var newData = this.getAllValues()
  for(const key in newData){
    if ( newData[key] != oldData[key] ){ 
      console.info("L'option de configuration %s a changé", key, oldData[key], newData[key])
      return true
    }
  }
  return false
}

/**
 * Réglage d'une propriété
 * 
 */
setProperty(property, value){
  // console.info("On doit mettre la propriété '%s' à %s", property, value)
  const dataProperty = DATA_OPTIONS[property]
  if ( undefined == dataProperty ){
    error("La propriété " + property + " n'est pas définie dans DATA_OPTIONS… Je dois renoncer à l'afficher.")
    return
  }
  switch(dataProperty.type) {
    case 'none':
      // 
      // C'est une propriété qui ne se règle pas directement, comme
      // par exemple les clés de portée (staves_names) ou leur nom
      // Ces valeurs seront réglées par une autre méthode
      // 
      break
    case 'checkbox':
      // 
      // Une configuration par CHECKBOX
      // 
      DGet('#cb_'+property).checked = value
      break
    case 'method':
      // 
      // Une configuration par MÉTHODE
      // 
      this[dataProperty.setter](value)
      break
    case 'select_or_other':
      // 
      // Une configuration par MENU ou CHAMP
      // 
      var menu = DGet('#'+property)
      if ( menu.querySelector(`option[value="${value}"]`) ) {
        menu.value = value
      } else {
        console.info("Le menu #%s n'a pas de valeur %s. Je mets other", property, value)
        menu.value = 'xxx'
        DGet('#other_'+property).value = value
      }
      break
    default:
      // 
      // Une configuration par autre type de champ
      // 
      value = value || ''
      console.log("Mettre le champ #%s à la valeur '%s'", property, value)
      DGet('#'+property).value = value    
  }
}

getProperty(property){
  const dataProperty = DATA_OPTIONS[property]
  if (undefined == dataProperty){
    console.error("La propriété '%s' est indéfinie…", property)
    error("Propriété " + property + ' indéfinie dans DATA_OPTIONS…')
    return null
  }
  switch(dataProperty.type) {
    case 'none':
      // La propriété est récupérée par un autre moyen
      break
    case 'checkbox':
      return DGet('#cb_'+property).checked
    case 'method':
      return this[dataProperty.getter]()
    case 'select_or_other':
      var value = DGet('#'+property).value
      if ( value == 'xxx') {
        value = DGet('#other_'+property).value.trim()
      }
      if ( value == '' ) value = null
      return value
    default:
      var value = DGet('#'+property).value    
      if ( value == '' ) value = null
      return value
  }
}

/**
 * Application des options
 * ------------------------
 * En règle générale, ce sont les options remontées de la partition
 * éditée en ce moment.
 * 
 * Pour appliquer les options +opts+ (par exemple récupérées d'un
 * code fourni par les outils)
 * 
 * @param opts {Hash} Avec en clé l'option et en valeur sa valeur
 */
applique(opts){
  console.info("* Application des options :", opts)
  var allOptions = {}
  for(var keyOption in opts){
    const datOption = DATA_OPTIONS[keyOption]
    const valOption = opts[keyOption]
    this.setProperty(keyOption, valOption)
    /*
    * Certaines options doivent s'appliquer tout de suite
    */ 
    switch(keyOption){
      case 'disposition':
        UI.setDisposition.call(UI, valOption)
        break
      case 'systeme':
      case 'staves':
        this.setSysteme(valOption)
        break
    }
  }
}

/**
 * Pour le nom de l'image (traitement à part)
 * 
 */
getImageName(){
  var imgname = this.imageNameField.value.trim()
  if (imgname == '') imgname = null;
  return imgname
}
setImageName(imgName){
  this.imageNameField.value = imgName
}
get imageNameField(){
  return this._imgnamefield || (this._imgnamefield = DGet('#image_name'))
}

/**
 * Méthode qu'on peut appeler depuis un élément DOM avec le
 * 'onchange', pour modifier quelque chose quand un choix d'option
 * est changé.
 * Cette méthode a été inaugurée pour la disposition. Quand on change
 * de disposition, cette méthode est appelée pour utiliser une autre
 * disposition d'écran.
 * 
 * @param objet {DOMElement}
 *        L'objet qui appelle la méthode car elle est appelée par :
 *        onchange="Options.onChange.call(Options,this)"
 *        On checke son id pour savoir quoi faire.
 */
onChange(objet){
  switch(objet.id){
    case 'disposition':
      this.applique({disposition: objet.value})
      break
    case 'systeme':
      Staff.reset()
      delete Options.data_ini
      Options.data_ini = null
      this.applique({systeme: objet.value})
      break
  }
}

/**
 * Pour régler la tonalité
 * 
 */
setTune(tune){
  var [note,alt] = tune.split('')
  this.menuTuneNote.value = note
  this.menuTuneAlt.value  = alt || ''
}
/**
 * @return {String} La tonalité
 */
getTune(){
  return this.menuTuneNote.value + this.menuTuneAlt.value
}
get menuTuneNote(){return DGet('select#tune_note')}
get menuTuneAlt (){return DGet('select#tune_alteration')}


/**
 * Pour définir les portées
 * Appelée par la méthode setProperties l'option 'staves', mais on
 * s'occupera dedans de toutes les définitions de staves (noms, 
 * clés, etc.)
 */
setStaves(staves){
  console.log("staves reçu par la méthode Options.setStaves :", staves)
  // this.setSystemsData()
}
getStaves(){
  console.warn("On doit implémenter la méthode getStaves")
}


/**
 * Réglage du système
 * 
 * +sys+ peut être une valeur symbolique, comme 'piano' ou 'quatuor',
 * ou un nombre de portées.
 * 
 */
setSysteme(sys){
  console.log("-> setSysteme(%s)", sys)
  Score.reset()
  const menuSysteme = DGet('#systeme')
  if ( isNaN(sys) ) {
    /*
    | Un type de système connu
    */
    menuSysteme.value = sys
  } else {
    /*
    | Un type de système personnalisé
    */
    const otreSysteme = DGet('#other_systeme')
    menuSysteme.value = 'xxx'
    otreSysteme.value = sys
  }
  this.setSystemsData()
}

setSystemsData(){
  // console.log("-> setSystemsData")
  /*
  | On détruit les rangées de définition de portée, à part la
  | première, qui servira de modèle
  | Note : ça détruit la définition dans le panneau d'option et
  | toutes les portées actuelles.
  */ 
  Staff.removeStaves()

  /*
  | Construction des portées en options en fonction des données
  */ 
  Staff.buildStavesInOptions()

}

getStavesData(){
  let dataKeys  = []
  let dataNames = []
  let keysArePertinent = false
  let namesArePertinent = false
  const nombrePortees = Score.nombrePortees;
  for(var istaff = 1; istaff <= nombrePortees; ++istaff){
    const staff = Staff.get(istaff)
    dataKeys.push(staff.key)
    if ( staff.key != 'G' ) keysArePertinent = true ;
    dataNames.push(staff.name)
    if ( staff.name ) namesArePertinent = true ;
  }
  var d = {}
  keysArePertinent  && Object.assign(d, {keys: dataKeys})
  namesArePertinent && Object.assign(d, {names: dataNames})
  return d
}

/**
 * Les options définies en configuration (config.js)
 * 
 */
get default(){return CONFIG.default_options}


}
const Options = new OptionsClass()
