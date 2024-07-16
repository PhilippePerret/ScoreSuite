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
    listen(btn, 'click', BlocNotes.toggle.bind(BlocNotes))

    btn = DGet('button#btn-outils')
    listen(btn, 'click', Outils.toggle.bind(Outils))

    // Pour pouvoir masque le bouton "on air" en cas de souci (mais
    // ça ne devrait pas arriver)
    listen(this.onAirLight,'click', _ => {this.onAirLight.classList.add('hidden')})

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


  /**
  * Méthode appelée quand on sauve et qu’on évalue le code
  * pour fabriquer les images. Un "On air" s’allume dans 
  * l’interface et l’on attend le retour de l’application.
  */
  static setBuildingOn(){
    // Au cas où
    this.unsetAirLightProblem()
    if ( undefined == this.buildingOnCount ) this.buildingOnCount = 0;
    ++ this.buildingOnCount
    if ( ! this.buildingOn ) {
      this.onAirLight.classList.add('on')
      this.onAirLight.classList.remove('hidden')
    }
  }
  static setBuildingOff(){
    -- this.buildingOnCount
    if ( this.buildingOnCount <= 0 ) {
      this.onAirLight.classList.remove('on')
      this.onAirLight.classList.add('hidden')
    }
  }
  static setAirLightProblem(){
    -- this.buildingOnCount
    this.onAirLight.classList.add('error')
  }
  static unsetAirLightProblem(){
    this.onAirLight.classList.remove('error')
  }
  static get onAirLight(){
    return this._onairlight || ( this._onairlight = DGet('div#on-air-light'))
  }
}
