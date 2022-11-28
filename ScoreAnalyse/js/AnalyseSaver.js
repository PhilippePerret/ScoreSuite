'use strict';
/**
 * 
 * AnalyseSaver
 * ============
 * 
 */


/**
 * La tolérance pour considérer que deux objets sont à la même hauteur
 * 
 */
const TOLERANCE_Y = 20 ;

/**
 * Méthode qui retourne TRUE quand les nombres y1 et y2, représentant
 * des offsetTop, sont à moins de TOLERANCE_Y, donc sont considérés
 * comme proches
 */
function nearY(y1, y2){
  return Math.abs(y2, y1) < TOLERANCE_Y
}

const SUFFIXES_DATA_RECORDS = ['infos','systemes','aobjets','preferences']

class AnalyseSaver {

  /**
   * Appelée par le bouton "Sauver"
   */
  static save(){
    if ( Analyse.current ) {
      console.log("Enregistrement…")
      try {      
        /*
        |  On vérifie qu'il n'y ait pas de problèmes
        */
        Analyse.current.checkDataBeforeSave()
        /*
        |  On prend le scroll actuel pour pouvoir le remettre
        */
        Preferences.set('last_scroll' , window.scrollY)
        /*
        |  Sauvegarde des marques
        */
        this.saveAnalyseTags(Analyse.current)
        /*
        |  Sauvegarde des préférences
        */
        this.savePreferences(Analyse.current)
        /*
        |  Sauvegarde des informations et des systèmes
        */
        this.saveInfos(Analyse.current)
        console.log("Enregistrement terminé.")

      } catch(err){
        
        erreur(err + '<br><br>Je ne peux pas procéder à l’enregistrement.')
        console.error("Enregistrement interrompu.")
      
      }
    } else {
      erreur("Il faut ouvrir ou créer une analyse, pour la sauver.")
    }
  }

  static saveInfos(analyse){
    this.analyse = analyse
    var newInfos = Analyse.panneau_infos.getData()
    Object.assign(newInfos, {
        systems:  Systeme.getData()
      , form:     Form.getData()
    })
    analyse.data.infos = newInfos
    WAA.send({
      class:    'ScoreAnalyse::Analyse',
      method:   'save_infos',
      data:     {infos: newInfos, path: analyse.data.path}
    })
  }

  static onSavedInfos(data){
    if ( data.ok ) {
      console.info("CONF: Infos de l'analyse enregistrées.")
    } else {
      console.error("Problème à l'enregistrement des infos de l'analyse…")
    }
  }

  static savePreferences(analyse){
    this.analyse = analyse
    WAA.send({
      class:  'ScoreAnalyse::Analyse',
      method: 'save_preferences',
      data:   {path:analyse.path, preferences: Preferences.getData()}
    })
  }
  static onSavedPreferences(data){
    if ( data.ok ) {
      console.info('CONF: Préférences de l’analyse enregistrées.')
    } else {
      console.error('Problème à l’enregistrement des infos de l’analyse…')
    }
  }

  /**
   * Enregistrement des tags d'analyse
   * -------------------------
   * C'est la méthode la plus complexe puisqu'elle doit associer dans
   * un premier temps les objets à leur système et ensuite les
   * classer.
   * 
   */
  static saveAnalyseTags(analyse){
    console.log("Enregistrement des objets…")
    this.analyse = analyse
    // La liste qui va contenir tous les tags d'analyse
    var atags = []
    AObjet.items.forEach(objet => {
      if ( objet.isSystem  ) return
      atags.push(objet.data)
    })

    console.log("Objets à sauver : ", atags)
    WAA.send({
      class:'ScoreAnalyse::Analyse',
      method:'save_tags',
      data: {analyse_id: analyse.id, path:analyse.path, tags: atags}
    })

  }
  static onSavedAnalyseTags(data){
    if ( data.ok ) {
      console.info("Marques de l'analyse enregistrées.")
      console.log("= ATags enregistrées =")
      this.analyse.modified = false
    } else {
      console.error("Problème à l'enregistrement des marques de l'analyse…")
    }
  }



  /**
   * Méthode de classement des objets
   * --------------------------------
   * Cette méthode doit permettre d'avoir une liste classée des 
   * objets. Mais elle fonctionne de façon simple maintenant que les
   * objets sont associés à leur système. Il suffit de les vérifier
   * de gauche à droite
   */
  static objetSorting(a, b){
    return a.left < b.left ? -1 : 1
  }

  /**
   * Pour marquer que l'enregistrement est en cours 
   * (c'est une lumière rouge en haut à gauche)
   * 
   */
  setActif(){
    this.redLight.classList.add('hidden')
  }
  unsetActif(){
    this.redLight.classList.add('hidden')
  }

  get redLight(){
    return this._redlight || (this._redlight = DGet('#red-light'))
  }
}
