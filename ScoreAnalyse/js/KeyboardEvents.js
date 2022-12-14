/**
* Voir la classe UI qui définit ces raccourcis. 
*/

function onKeypressOnAnalyse(e){

  switch(e.key){

    case 'I':
      Analyse.panneau_infos.toggle.call(Analyse.panneau_infos)
      break

    case 'M':
      Manuel.toggle.call(Manuel)
      break

    case 'P':
      Preferences.toggle.call(Preferences)
      break

    case 'O':
      Tools.toggle.call(Tools)
      break

    default:

      // console.log("e.key = '%s'", e.key, e)
  }
}

onKeyDownOnAnalyse = function(e){

  // console.debug("-> onKeyDownOnAnalyse")
  var returnU = onKeyDownUniversel(e)
  
  // 
  // Si la combinaison a été traitée par le gestionnaire
  // universel
  // 
  if ( returnU === true || returnU === false) {
    return returnU
  }

  switch(e.key){
  case 'ArrowRight':
  case 'ArrowLeft':
  case 'ArrowDown':
  case 'ArrowUp':
    sens = e.key.replace(/^Arrow/,'').toLowerCase()
    multi     = e.shiftKey  ? 10 : 1
    precision = e.altKey    ? 1  : 4
    AMark.moveSelection(sens,multi,precision)
    return stopEvent(e)
  }

  // console.log("e.key = '%s'", e.key)

}

onKeyUpOnAnalyse = function(e){
  // console.log("[KEY UP] e.key = '%s'", e.key)
  switch(e.key){
    case 'Backspace':
      AObjet.removeCurrentSelection()
      break
  }
}

/**
* Quelle que soit la situation, ce gestionnaire de Key-down est 
* appelé.
* Il doit absolument retourne null s'il n'a rien faire et true ou
* false dans l'autre cas, pour retourner cette valeur.
*/
onKeyDownUniversel = function(e){

  if ( e.metaKey ) {
    switch(e.key) {
      case 's':
        Analyse.current && AnalyseSaver.save(Analyse.current)
        return stopEvent(e)
      case 'z':
        if (e.shiftKey) {
          return Cancel.unzLast(e)
        } else {
          return Cancel.zLast(e)
        }
    }
  }

  return null;
}
