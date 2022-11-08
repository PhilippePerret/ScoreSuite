'use strict';

/**
 * Pour faire des essais, on peut mettre du code ici, qui 
 * sera exécuté après avoir chargé et affiché l'analyse 
 * courante.
 */
function runAfterLoadingAndDisplayingAnalyse(){
  
  return

  message("Je vais lancer l'export des images dans 1 seconde…")
  setTimeout(function(){
    Analyse.exportImage.call(Analyse)
    message("C'est parti !")
  }, 1000)
}



$(document).ready(function(e){
  Message.init()
  UI.setInterface()
  App.load_analyse_if_exist()
  // Si on a besoin de faire une opération après le
  // chargement de l'analyse, on la code dans la fonction
  // runAfterLoadingAndDisplayingAnalyse ci-dessus
})


function run_on_test(){
  DGet('#piece_title').value = "L'œuvre analysée"
  DGet('#analyse_title').value = "La problématique dégagée"
  DGet('#analyse_id').value = 'premanalyse'
}
