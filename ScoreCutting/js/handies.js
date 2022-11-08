'use strict';

function px(nombre){
  return `${nombre}px`
}

function unpx(valeur){
  return Number(valeur.substring(0, valeur.length - 2))
}


function message(str){
  UI.showMessage(str)
  return true
}
function error(err){
  //console.log("-> error(%s)", err)
  UI.showError(err)
  return false
}
function erreur(err){return error(err)}
