'use strict';

function px(nombre){
  return `${nombre}px`
}

function unpx(valeur){
  return Number(valeur.substring(0, valeur.length - 2))
}

function tooltip(msg){
  /** Pour afficher un message discret dans le footer **/
  window.__tooltipField || (window.__tooltipField = DGet('#tooltip'))
  window.__tooltipField.innerHTML = msg
}


function coordonnate(x, y){
  /** Méthode pour écrire les coordonnées de la souris en bas à
   ** gauche de l'écran **/
  window.__xyfield || (window.__xyfield = DGet('#coordonnates'))
  window.__xyfield.innerHTML = `x: ${x} y: ${y}`
}
