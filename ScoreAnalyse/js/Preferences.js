'use strict';
/*

  Gestion des préférences de l'application
  ----------------------------------------

  Version propre
  --------------

*/

class PreferencesClass {

setValuesSaved(savedData){
  for(var prop in savedData){
    const dprop = this.data[prop]
    const value = (function(v, type){
      switch(type){
      case 'boolean': return v == 'true';
      case 'number' : return Number(v);
      default: return v
      }
    })(savedData[prop], dprop.typeV)
    Object.assign(this.data[prop], {value: value})
  }
}

/**
 * @return la valeur de préférence de la clé +key+
 * @usage     pref(<key>) OU Preferences.get(<key>)
 */
get(key){
  // console.debug("pref %s = %s (%s) in ", key, this.data[key].value, typeof this.data[key].value, this.data)
  return this.data[key].value || this.data[key].default
}
set(key,value){
  this.data[key].value = value

  let element = DGet(`#pref-${key}`)
  if ( element ) {  
    switch(this.data[key].type){
      case 'checkbox':
        element.checked = value
        break
      case 'inputtext':
      case 'select':
        element.value = value
        break
    }
  } else {
    console.error("L'élément préférences #%s est introuvable…", key)
  }

}

toggle(key){
  this.set(key, !this.get(key))
}

onChange_thiness_cellule_line(){
  AMark.bSnap = this.getValueOf('thiness_cellule_line')
}
onChange_grid_horizontal_space(){
  AMark.snap && (AMark.snap = this.getValueOf('grid_horizontal_space'))
}
onChange_grid_vertical_space(){
  AMark.snap && (AMark.snap = this.getValueOf('grid_vertical_space'))
}
onChange_theme(){
  const theme = this.getValueOf('theme')
  const theme_data = this.themes[theme]
  // console.debug("theme_data = ", theme_data)
  for (var key in theme_data) {
    if ( key == 'name' ) continue
    this.set(key, theme_data[key])
  }
  /*
  |  Actualisation des codes en dur pour l'analyse courante
  */
  this.insertStylesCSSInHead()
}


getValueOf(key, defaut){
  /**
   ** Méthode retournant la valeur de la clé préférence +key+ dans
   ** son champ (souvent après une modification) en lui donnant son
   ** bon type (défini en vtype dans les préférences de l'app.)
   **/
  const dkey = PreferencesAppData[key]
  if ( not(DGet(`#pref-${key}`)) ) {
    erreur("Impossible de trouver l'élément préférence d'identifiant #"+key)
    return null
  }
  switch(dkey.type){
  case 'checkbox':
    return DGet(`#pref-${key}`).checked
  default:
    return DGet(`#pref-${key}`).value || defaut
  }
}

/**
 * Appelé après le chargement de l'analyse (et donc, par exemple, la
 * fabrication des systèmes)
 */
afterLoadingAnalyse(){
  this.build()
  this.insertStylesCSSInHead();
  this.prepareOnChangeMethods()
  const locked = this.get('lock_systems')
  Systeme[locked ? 'lockAll':'unlockAll'].call(Systeme)
  UI.btnLockSystems.classList[ locked ? 'add' : 'remove']('pressed')
}

/* --- Themes Methods --- */

themesAsMenu(){
  /**
   ** Retourne la liste des thèmes pour peupler le menu des thèmes
   **/
  return this.themes || this.loadThemes()
}

loadThemes(){
  /**
   ** Méthode qui charge les thèmes pour les afficher dans les 
   ** préférences
   **/
  WAA.send({class:'ScoreAnalyse::App', method:'load_themes', data:{}})
  return [{name:'Commun', value:'commun'}, {name:'Discret', value:'discret'}]
}
onLoadedThemes(data){
  /**
   ** Méthode qui reçoit vraiment la liste des thèmes et leurs 
   ** données et alimente le menu pour choisir le thème courant
   **/
  this.menuThemes = DGet('select#pref-theme')
  this.menuThemes.innerHTML = ''
  const themes = data.themes
  this.themes = {}
  themes.forEach(theme => {
    console.debug("theme = ", theme)
    var name = theme.name
    name = name.substring(0,1).toUpperCase() + name.substring(1, name.length).toLowerCase()
    this.menuThemes.appendChild(DCreate('OPTION',{value:theme.name, text:name }))
    Object.assign(this.themes, {[theme.name]: theme})
  })
}

loadTheme(theme_name){
  WAA.send({class:'ScoreAnalyse::App', method:'load_theme', data:{theme_name: theme_name}})
}
onLoadedTheme(data){
  // data.theme_data = les données du thème
  // data.theme_name = le nom du thème (son affixe de fichier)
}

/**
 * @return Une table des données avec en clé la clé des préférences
 * et en valeur la valeur. Pour enregistrement.
 * 
 */
getData(){
  var prefs = {}
  Object.keys(PreferencesAppData).forEach( key => {
    Object.assign(prefs, {[key]: this.get(key) })
  })
  return prefs
}

saveData(key,value){
  // console.debug("-> saveData(%s, %s)", key, value)
  // Rectification de la valeur en fonction du typeV
  switch(this.data[key].typeV){
  case 'number': value = Number(value)
  }
  Object.assign(this.data[key], {value: value})
  Analyse.setModified()
}

/**
 * Appel au chargement de l'application
 * (avant le chargement de l'analyse)
 */
init(){
  this.data = PreferencesAppData;
}

prepareOnChangeMethods(){
  const my = this
  Object.values(PreferencesAppData).forEach(dpref => {
    const key = dpref.id
    const methChange = `onChange_${key}`
    const obj = DGet(`#pref-${key}`)
    if ( 'function' == typeof my[methChange] ) {
      listen(obj,'change', my[methChange].bind(my))
    }
    /*
    |   Dans tous les cas, on met une méthode lambda qui va consigner
    |   la valeur
    */
    var methode ;
    switch(dpref.type){
    case 'checkbox':
      methode = (function(key, obj){this.saveData(key, obj.checked)}).bind(my, key, obj)
      break
    case 'inputtext':
    case 'select':
      methode = (function(key, obj){this.saveData(key, obj.value)}).bind(my, key, obj)
      break
    }
    listen(obj,'change', methode)
  })
}

toggle(){
  this.isOpened ? this.hide() : this.open()
}
// Pour ouvrir le panneau
open(){
  this.show()
  this.isOpened = true
}
hide(){
  this.obj.classList.add('hidden')
  this.isOpened = false
}
show(){
  this.obj.classList.remove('hidden')
}

/**
 * Méthode qui applique les préférences de style dans l'interface
 * 
 * Fonctionnement
 * --------------
 * On écrit une balise STYLE dans le dom, à la fin du HEAD (donc 
 * après toutes les définitions) où vont être reprises toutes les
 * valeurs en les affectant aux classes (selectors) adéquats.
 * Par exemple, la préférence 'marque_accords_size' définit la taille
 * des marques d'accord dans l'application Table d'analyse. Donc, on
 * met dans cette balise style :
 *    div.aobj.acc {font-size: <size>px;}
 * 
 * Dès qu'une préférence de ce type (on les reconnait au fait 
 * qu'elles définisssent la propriété 'selector') est modifiée, on 
 * actualise cette balise style.
 */
insertStylesCSSInHead(){
  const my = this
  if ( this.stylesTagInHead ) {
    this.updateStylesInHead()
  } else {
    this.stylesTagInHead = DCreate('STYLE',{id:'styles-selectors', type:'text/css', text: this.buildSelectorsInHead()})
    document.head.appendChild(this.stylesTagInHead)
    this.stylesTagInHead.disabled = false
  }
}
/**
 * Méthode pour actualiser les préférences dans les selectors de
 * head
 */
updateStylesInHead(){
  this.stylesTagInHead.innerHTML = this.buildSelectorsInHead()
}
buildSelectorsInHead(){
  const my = this
  var selectors = []
  selectors.push('/* Code produit automatiquement par les propriétés \'selector:\' des préférences */')
  Object.values(PreferencesAppData).forEach(dp => {
    if ( undefined == dp.selector ) return ;
    selectors.push(`${dp.selector} {${dp.selector_value.replace(/__VALUE__/g, my.get(dp.id))}}`)
  })
  selectors = selectors.join("\n")
  // console.debug("selectors = ", selectors)
  return selectors
}

// Construction du panneau
build(){
  if ( this.isBuilt ) {
    console.error("Le panneau préférences est déjà construit.")
    return
  }
  var o = DCreate('SECTION', {id:'preferences-panel', class:'hidden'})
  o.appendChild(DCreate('DIV', {id:'tip-close', text:"(⇧ P pour fermer)"}))
  o.appendChild(DCreate('H2',{text:'Préférences'}))

  // Pour simplifier l'écriture
  const DA = this.data

  Object.values(PreferencesAppData).forEach( dp => {
    if ( dp.type == 'inputtext'){
      o.appendChild(this.buildInputText(dp))
    } else if ( dp.type == 'checkbox' ) {
      o.appendChild(this.buildCheckBox(dp))
    } else if ( dp.type == 'select' ) {
      o.appendChild(this.buildMenuSelect(dp))
    } else if ( dp.type == 'pressoir' ) {
      o.appendChild(this.buildChoixPressoirs(dp))
    }
    // Si des précisions sont à apporter
    if ( dp.precision ) {
      o.appendChild(DCreate('DIV',{class:'description', text:dp.precision}))
    }
  })

  document.body.appendChild(o)

  this.obj = o
  this.observe()

  this.isBuilt = true

}

observe(){
  $(this.obj).draggable()
  listen(this.obj, 'dblclick', e => {
    console.log("-> double click préférences")
    return stopEvent(e)
  })
  listen(this.obj, 'click', e => { 
    e.stopPropagation()
    e.preventDefault()
    return false
  })
}
 

buildMenuSelect(params){
  /**
   ** Construit et retourne un menu select
   **/
  const div = DCreate('DIV', {class:'div-data type-valeur'})

  const label = DCreate('LABEL', {text: params.label })
  div.appendChild(label)

  const menu = DCreate('SELECT', {id: `pref-${params.id}`})
  div.appendChild(menu)

  
  var values = params.values;
  if ( 'function' == typeof values) {
    values = values.call()
  }
  values.forEach( dvalue => {
    menu.appendChild( DCreate('OPTION',{value:dvalue.value, text:dvalue.name} ) )
  })

  return div
}
/**
 * Construction d'un checkbox pour le panneau de préférences
 * 
 */
buildCheckBox(params){
  const d = DCreate('DIV', {class:'div-checkbox div-data'})

  /*
  |  ID DOM de l'élément
  */
  const domId = `pref-${params.id}`

  // La case à cocher    
  const cb = DCreate('INPUT',{type:'checkbox', id: domId, value:params.value})
  d.appendChild(cb)

  if ( undefined == params.value ) {
    cb.checked = params.default
  } else {
    cb.checked = params.value
  }

  listen(cb, 'click', e => {
    e.stopPropagation()
    this.set(params.id, !this.get(params.id))
    return true
  })

  // Le label
  const lab = DCreate('LABEL', {for:domId, text: params.label})
  d.appendChild(lab)

  // listen(lab, 'click', e => {
  //   e.stopPropagation()
  //   return true
  // })

  // La description (if any)
  if (params.description){
    const dd = DCreate('DIV', {class:'description', text:params.description})
    d.appendChild(dd)
  };

  return d

}

/**
 * Construction d'un pressoir à valeurs pour le panneau des préférences
 * 
 */
buildChoixPressoirs(params){
  const my = this
  const div = DCreate('DIV', {id:`div-${params.id}`, class:'type-valeur div-data'})
  const lab = DCreate('LABEL', {text:params.label})
  div.appendChild(lab)
  const val = Number(this.data[params.id]||0) 
  const btn = DCreate('BUTTON', {id:params.id, text: params.values[val]})
  btn.setAttribute('data-index', val)
  div.appendChild(btn)
  btn.addEventListener('click', function(e){
    let curIdx = Number(btn.getAttribute('data-index'))
    curIdx = (curIdx + 1) % params.values.length
    btn.innerHTML = params.values[curIdx]
    btn.setAttribute('data-index', curIdx)
    my.saveData(params.id, curIdx)
  })
  // La description (if any)
  if (params.description){
    div.appendChild(DCreate('DIV', {class:'description', text:params.description}))
  };

  return div
}
/**
 * Construction d'un pressoir à valeurs pour le panneau des préférences
 * 
 * L'identifiant doit toujours être construit avec le nom :
 * 
 *    default-<nom de la propriété Preferences>
 * 
 * Par exemple, si la propriété est 'snap_width' (qu'on obtient dans
 * le programme par 'Preferences.snap_width') alors l'identifiant ici
 * doit être "default-snap_width"
 * 
 */
buildInputText(params){
  const my = this
  const domId = `pref-${params.id}`
  const prop = params.id.split('-')[1]
  const div = DCreate('DIV', {id:`div-${params.id}`, class:'type-valeur div-data'})
  const lab = DCreate('LABEL', {text:params.label})
  div.appendChild(lab)
  const field = DCreate('INPUT', {type:'text', id:domId, value: params.value||params.default})
  div.appendChild(field)
  // La description (if any)
  if (params.description){
    div.appendChild(DCreate('DIV', {class:'description', text:params.description}))
  };
  return div
}


}//PreferencesClass
const Preferences = new PreferencesClass()
const pref = Preferences.get.bind(Preferences)
// Si on veut utiliser 'Pref[<key>]' on peut ajouter à la fin de
// Preferences_AppData.js :
//    const Pref = Preferences.data
// Note : ne pas le mettre ici, car le fichier Preferences_AppData.js
// n'est pas encore chargé et ça plantera.
