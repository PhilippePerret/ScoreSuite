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

onKeyDownOnAnalyse = function(e){}

onKeyUpOnAnalyse = function(e){
  // console.log("[KEY UP] e.key = '%s'", e.key)
  switch(e.key){
    case 'Backspace':
      AObjet.removeCurrentSelection()
      break

    case 's':
      if ( e.ctrlKey ) {
        console.log("Enregistrement…")
        Analyse.current && Analyse.current.saveAnalyseTags()
        return stopEvent(e)        
      }
      break
  }
}
