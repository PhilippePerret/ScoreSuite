/**
* Voir la classe UI qui définit ces raccourcis. 
*/

function onKeypressOnAnalyse(e){

  switch(e.key){

    case 'M':
      console.log("Ouverture du manuel")
      Manuel.toggle.call(Manuel)
      break

    case 'P':
      console.log("Ouverture les préférences")
      Preferences.toggle.call(Preferences)
      break

    default:

      console.log("e.key = '%s'", e.key, e)
  }
}

onKeyDownOnAnalyse = function(e){

  var returnU = onKeyDownUniversel(e)
  
  // 
  // Si la combinaison a été traitée par le gestionnaire
  // universel
  // 
  if ( returnU === true || returnU === false) {
    return returnU
  }

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

  if ( e.metaKey && e.key == 's' ) {
    console.log("Enregistrement…")
    Analyse.current && Analyse.current.saveAnalyseTags()
    return stopEvent(e)
  }

  return null;
}
