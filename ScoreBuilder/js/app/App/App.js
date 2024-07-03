'use strict';

class App {

  static get NAME(){ return 'Score Builder' }
  
  static loadCurrent(){
    WAA.send({class:"ScoreBuilder::App", method:"load", data:{}})
  }

  static onLoad(wData){
    // console.log("Je remonte avec : ", wData)
    MusCode.setMusCode(decodeURIComponent(wData.mus_code.replace(/\+/g, ' ')))
    // MusCode.setMusCode(decodeURI(wData.mus_code.replace(/\+/g, ' ')))
    MusCode.mus_file_path = wData.folder + '/' + wData.mus_file
    OriginalScore.setPages(wData.folder, wData.original_score_pages)
    ScoreViewer.setVignettes(wData)
    UI.setNameBackupButton(wData.nombre_backups)
  }

  /**
  * Pour repartir à zéro
  * 
  * Pour le moment, utilisé seulement par les tests
  */
  static resetAll(){

  }

  /**
  * Pour remonter une erreur depuis le serveur avec WAA.
  * (WAA.send(class:'App',method:'onError', data:{:message, :backtrace}))
  */
  static onError(err){
    erreur(err.message + " (voir en console)")
    console.error(err.message)
    console.error(err.backtrace)
  }
  
} // /class App
