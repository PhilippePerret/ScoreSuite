'use strict';

function px(nombre){
  return `${nombre}px`
}

function unpx(valeur){
  return Number(valeur.substring(0, valeur.length - 2))
}
