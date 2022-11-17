'use strict';
/*

  Gestion des préférences de l'application
  ----------------------------------------

  Version propre
  --------------

*/

class PreferencesClass {

/**
 * @return la valeur de préférence de la clé +key+
 * @usage     Preferences.get(<key>)
 */
get(key){return this.data[key].value || this.data[key].default}
set(key,value){
  this.data[key].value = value

  if ( this.prefsBuilt ) {  
    let element = DGet(`#${key}`)
    if ( element ) {  
      switch(this.data[key].type){
        case 'checkbox':
          element.checked = value
          break
        case 'inputtext':
          element.value = value
          break
      }
    } else {
      console.error("L'élément préférences #%s est introuvable…", key)
    }
  }

}

toggle(key){
  this.set(key, !this.get(key))
}

/**
 * Appelé après le chargement de l'analyse (et donc, par exemple, la
 * fabrication des systèmes)
 */
afterLoadingAnalyse(){
  const locked = this.get('lock_systems')
  Systeme[locked ? 'lockAll':'unlockAll'].call(Systeme)
  UI.btnLockSystems.classList[ locked ? 'add' : 'remove']('pressed')
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

erreurNoSavePrefs(){
  erreur("Pour le moment, je ne sais pas enregistrer les préférences. Éditer le fichier 'preferences.yaml' pour modifier les valeurs.")
}

saveData(key,value){
  console.log("Je dois apprendre à sauver %s dans %s", value, key)
  // Rectification de la valeur en fonction du typeV
  switch(this.data[key].typeV){
  case 'number': value = Number(value)
  }
  Object.assign(this.data[key], {value: value})
  // console.debug("this.data = ", this.data)
  this.erreurNoSavePrefs()
}

/**
 * Appel au chargement de l'application
 */
init(){
  this.data = PreferencesAppData;
  this.insertStylesCSSInHead();
}

toggle(){
  this.isOpened ? this.hide() : this.open()
}
// Pour ouvrir le panneau
open(){
  return this.erreurNoSavePrefs()
  this.obj ? this.show() : this.build()
  this.isOpened = true
}
hide(){
  this.obj.classList.add('hidden')
  this.isOpened = false
}
show(){
  this.obj.classList.remove('hidden')
}

// @return TRUE si le panneau des préférences a été construit
get prefsBuilt(){
  return true && this.obj
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
    this.stylesTagInHead = DCreate('STYLE',{type:'text/css', text: this.buildSelectorsInHead()})
    document.head.appendChild(this.stylesTagInHead)
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
  Object.values(PreferencesAppData).forEach(dp => {
    if ( undefined == dp.selector ) return ;
    selectors.push(`${dp.selector} {${dp.selector_value.replace(/__VALUE__/g, my.get(dp.id))}}`)
  })
  return selectors.join("\n")  
}

// Construction du panneau
build(){
  var o = DCreate('SECTION', {id:'preferences-panel'})
  o.appendChild(DCreate('DIV', {id:'tip-close', text:"(⇧ P pour fermer)"}))
  o.appendChild(DCreate('H2',{text:'Préférences'}))

  // Pour simplifier l'écriture
  const DA = this.data

  Object.values(PreferencesAppData).forEach( dp => {
    if ( dp.type == 'inputtext'){
      o.appendChild(this.buildInputText(dp))
    } else if ( dp.type == 'checkbox' ) {
      o.appendChild(this.buildCheckBox(dp))
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
 

/**
 * Construction d'un checkbox pour le panneau de préférences
 * 
 */
buildCheckBox(params){
  const d = DCreate('DIV', {class:'div-checkbox div-data'})

  // La case à cocher    
  const cb = DCreate('INPUT',{type:'checkbox', id: params.id, value:params.value})
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
  const lab = DCreate('LABEL', {for:params.id, text: params.label})
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
  const prop = params.id.split('-')[1]
  const div = DCreate('DIV', {id:`div-${params.id}`, class:'type-valeur div-data'})
  const lab = DCreate('LABEL', {text:params.label})
  div.appendChild(lab)
  const field = DCreate('INPUT', {type:'text', id:params.id, value: params.value||params.default})
  div.appendChild(field)
  field.addEventListener('change', function(e){my.saveData(params.id, field.value)})
  // La description (if any)
  if (params.description){
    div.appendChild(DCreate('DIV', {class:'description', text:params.description}))
  };

  return div
}

}//PreferencesClass
const Preferences = new PreferencesClass()
// Si on veut utiliser 'Pref[<key>]' on peut ajouter à la fin de
// Preferences_AppData.js :
//    const Pref = Preferences.data
// Note : ne pas le mettre ici, car le fichier Preferences_AppData.js
// n'est pas encore chargé et ça plantera.
