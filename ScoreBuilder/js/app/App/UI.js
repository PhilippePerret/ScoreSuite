'use strict';

class UI {
  static prepare(){

    let btn;
    
    this.espaceButtonTitle()

    // Redimensionner pour prendre tout l’écran
    window.resizeTo(screen.width, screen.height)

    listen(this.btnBuild, "click", this.onClickBuild.bind(this))
    listen(this.btnBackup,'click', this.onClickBackup.bind(this))

    btn = DGet('button#btn-bloc-note')
    listen(btn, 'click', BlocNotes.open.bind(BlocNotes))

  }

  static setNameBackupButton(nombreBackup){
    this.btnBackup.innerHTML = `Nettoyer les backups (${nombreBackup})`
    this.btnBackup.classList[nombreBackup>5?'remove':'add']('hidden')
  }

  /**
  * Méthode appelée quand on clique sur le bouton "Build" pour
  * forcer la construction de la partition.
  */
  static onClickBuild(ev){
    stopEvent(ev)
    MusCode.saveAndEvaluateCode()
    return false
  }


  /**
  * Méthode appelée pour nettoyer les backups
  */
  static onClickBackup(){
    WAA.send(
      {
        class:"ScoreBuilder::MusCode", 
        method:"cleanupBackups", 
        data: {mus_file: MusCode.mus_file_path}
      })
  }
  static onCleanedUpBackup(wData){
    if (wData.ok){
      message("Dossier backups nettoyé.")
      this.setNameBackupButton(wData.nombre_backups)
    } else {
      erreur(`Problème en nettoyant les backups : ${wData.error}`)
    }
  }

  // Le bouton de construction
  static get btnBuild(){return DGet("#btn-build")}
  static get btnBackup(){return DGet("#btn-backup")}

  /**
  * Pour que la souris ne masque pas le début du title des boutons
  */
  static espaceButtonTitle(){
    document.querySelectorAll('button').forEach(button => {
      if ( button.title ) {
        button.title = '      ' + button.title
      }
    })
  }
}
