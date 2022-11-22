'use strict';
/** ---------------------------------------------------------------------

  MÉTHODES PRATIQUES
  ------------------
  Version 1.4.0

# 1.4.0
  Ajout de la méthode 'confirm' en remplacement de la
  méthode originale (qui ne fonctionne pas, en WAA)

# 1.3.1
  Ajout de l'alias erreur() pour error()
  
# 1.3.0
  Ajout de la méthode unpx() qui fait l'inverse de px()

# 1.2.0
  Ajout de la méthode focusIn. Qui permet de focusser dans un élément
  en triggant un évènement focus.

# 1.1.1
  Amélioration de stopEvent pour désactiver encore plus de choses

# 1.1.0
  Modification de la méthode with_pixels -> px
  + Elle peut recevoir maintenant, dans les objets, des valeurs qui ont
    déjà leur unité et ne seront pas transformées. Pour ne pas avoir à
    compliquer la définition de l'attribut style lorsqu'il y a d'autres
    valeurs comme des zooms, des polices, etc.
# 1.0.2
  Ajout de la méthode 'px'
*** --------------------------------------------------------------------- */

// Pour focus dans un élément en triggant un évènement focus
// Mais bon… ça ne semble pas marcher…
function focusIn(element) {
  // var eventType = "onfocusin" in element ? "focusin" : "focus",
  //   , bubbles = "onfocusin" in element,
  //   , event;
  var eventType = 'focus'
    , bubbles = false
    , event

  if ("createEvent" in document) {
    event = document.createEvent("Event");
    event.initEvent(eventType, bubbles, true);
  }
  else if ("Event" in window) {
    event = new Event(eventType, { bubbles: bubbles, cancelable: true });
  }

  element.focus();
  element.dispatchEvent(event);
}

// Méthode à utiliser en catch des promesses
function onError(err){
  console.error(err)
  erreur("Une erreur est survenue, consulter la console.")
}

/**
* Pour ajouter les pixels aux valeurs numériques (*) :
*
* (String)  "12" => "12px"
* (Number)  12 => "12px"
* (Object)  {top: 24, left: 34} => {top: "24px", left: "34px"}
*
* Si +asStyle+ est true, on retourne la donnée sous forme d'attribut style
* c'est-à-dire {top:24, left:34} => "top:24px;left:34px;"
* (ça n'est bien entendu valable que pour les Object(s))
*
* (*) Et seulement aux valeurs numériques, c'est-à-dire qu'on peut
*     laisser des propriétés déjà réglées sans problème.
***/
function px(vals, asStyle = false){
  if ('string' == typeof(vals) || 'number' == typeof(vals)) {
    return `${vals}px`
  } else {
    var newh = {}
    for(var k in vals){
      var val = vals[k]
      Object.assign(newh, { [k]: (isNaN(val) ? val : val+'px') })
    }
    if (asStyle){
      var str = []
      for(var k in newh){str.push(`${k}:${newh[k]};`)}
      return str.join('')
    } else {
      return newh
    }
  }
}

function unpx(valeur){
  return Number(valeur.substring(0, valeur.length - 2))
}


function raise(msg){
  erreur(msg)
  throw new Error(msg)
}

const NOW = new Date()

/**
  Retourne le temps en secondes
  @documented
**/
function humanDateFor(timeSeconds){
  if (undefined === timeSeconds){ timeSeconds = new Date()}
  if ('number' != typeof(timeSeconds)) timeSeconds = parseInt(timeSeconds.getTime() / 1000)
  var d = new Date(timeSeconds * 1000)
  return `${String(d.getDate()).padStart(2,'0')} ${(String(d.getMonth()+1)).padStart(2,'0')} ${d.getFullYear()}`;
}

function stopEvent(ev){
  ev.stopPropagation();
  ev.preventDefault();
  ev.stopImmediatePropagation()
  ev.returnValue = false
  return false
}

function dorure(str){return `<span style="color:#e9e330;background-color:blueviolet;padding:1px 6px;">${str}</span>`}

function clip(what, msg){
  const field = DCreate('textarea',{text:what})
  document.body.appendChild(field)
  field.focus()
  field.select()
  document.execCommand('copy')
  msg && message(msg)
  field.remove()
}


/**
* Pour charger un module du dossier 'js/module'
***/
function loadJSModule(moduleName){
  moduleName.endsWith('.js') || (moduleName += '.js')
  return new Promise((ok,ko)=>{
    const script = DCreate('SCRIPT',{src:`js/module/${moduleName}`, type:"text/javascript"})
    document.body.appendChild(script)
    script.addEventListener('load', ok)
  })
}

function message(str, options){
  UISystem.showMessage(str, options)
  return true
}
function error(err, options){
  //console.log("-> error(%s)", err)
  UISystem.showError(err, options)
  return false
}
function erreur(err,options){
  return error(err,options)
}

class BoiteConfirmation {
  confirm(question, method_ok, method_cancel){
    this.obj || this.build_and_observe()
    this.boiteMessage.innerHTML = question
    this.method_ok      = method_ok
    this.method_cancel  = method_cancel
    this.show()
  }

  onOK(){
    this.hide()
    this.method_ok && this.method_ok()
  }
  onCancel(){
    this.hide()
    this.method_cancel && this.method_cancel()
  }

  show(){this.obj.classList.remove('hidden')}
  hide(){this.obj.classList.add('hidden')}
  
  build_and_observe(){
    this.build()
    this.observe()
  }

  build(){
    const div = DCreate('DIV', {id:'boite_confirmation', class:'hidden'})
    this.boiteMessage = DCreate('DIV', {class:'message'})
    div.appendChild(this.boiteMessage)
    const divBoutons = DCreate('DIV', {class:'buttons'})
    div.appendChild(divBoutons)
    this.btnOK = DCreate('BUTTON', {text:'OK', class:'btn-ok'})
    this.btnCancel = DCreate('BUTTON', {text:'Renoncer', class:'btn-cancel'})
    divBoutons.appendChild(this.btnCancel)
    divBoutons.appendChild(this.btnOK)
    this.obj = div
    document.body.appendChild(this.obj)
  }
  observe(){
    this.btnOK.addEventListener('click', this.onOK.bind(this))
    this.btnCancel.addEventListener('click', this.onCancel.bind(this))
  }

}
function confirm(msg, method_ok, method_cancel){
  if (undefined == window.boite_confirmation) {
    window.boite_confirmation = new BoiteConfirmation()
  }
  window.boite_confirmation.confirm(msg, method_ok, method_cancel)
}

