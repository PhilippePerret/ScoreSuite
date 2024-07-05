'use strict';

$(document).ready(e => {
  
  // Log.level = LOG_ALL

  UI.prepare()
  Options.prepare()
  BlocNotes.prepare()
  Helper.prepare()
  MusCode.prepare()
  OriginalScore.prepare()
  ScoreViewer.prepare()

  App.loadCurrent()
  
  console.log("Je suis fin prête.")

  // Pour gagner du temps au développement
  // BlocNotes.open()
  // Pour ouvrir tout de suite le panneau des options
  // Options.open()

})

