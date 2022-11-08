'use strict';

/**
  Reçoit une définition des propriétés, par exemple :
  [
      {name:'id', hname: "#", type:'hidden'}
    , {name:'prenom', hname, 'Prénom'}
    , ...
  ]
  … et retourne un +container+ avec les champs de formulaires désirés
  +container+ peut être créé simplement par DCreate('DIV')
**/

function listen(objet, eventType, method){
  objet.addEventListener(eventType, method)
}
function unlisten(objet, eventType, method){
  objet.removeEventListener(eventType, method)
}

function stopEvent(e){
  e.preventDefault()
  e.stopPropagation()
  return false
}

function DGet(selector, container){
  container = container || document
  return container.querySelector(selector)
}

function DCreate(tagName,attrs){
  attrs = attrs || {}
  var o = document.createElement(tagName);
  for(var attr in attrs){
    var value = attrs[attr]
    switch (attr) {
      case 'text':
        o.innerHTML = value;
        break;
      case 'inner':
        if ( !Array.isArray(value) ) value = [value]
        value.forEach(obj => o.appendChild(obj))
        break;
      case 'css':
      case 'class':
        o.className = value;
        break;
      default:
        o.setAttribute(attr, value)
    }
  }
  return o;
}

class DOM {
  static showIf(domEl, condition){
    domEl[condition ? 'removeClass' : 'addClass']('hidden')
    return condition
  }
  constructor(domEl){
    this.obj = domEl
  }
  showIf(condition){ return this.constructor.showIf(this.obj, condition)}
}
