'use strict';

$(document).ready(e => {
  
  // Log.level = LOG_ALL

  UI.prepare()
  Options.prepare()
  MusCode.prepare()
  OriginalScore.prepare()
  ScoreViewer.prepare()

  App.loadCurrent()
  
  console.log("Je suis fin prête.")

})

