'use strict'
/**
 * Class AnalyseDisplayer
 * ----------------------
 * Pour écrire sur la table d'analyse une analyse
 * 
 * Note : c'est l'ancien Reader, qui fonctionne maintenant avec 
 *        WAA.
 */


class AnalyseDisplayer {

/**
 * = main =
 * 
 * Méthode principale pour afficher l'analyse {Analyse} +analyse+
 * transmise en argument.
 * 
 * @return TRUE si l'affichage s'est bien passé
 */
static display(analyse){
  console.log("-> AnalyseDisplayer.display()", analyse)
  // return
  /** 
   * Nettoyage général et notamment de la table d'analyse
   * s'il y avait déjà une analyse affichée. Normalement ça
   * n'arrive pas
   */ 
  this.cleanUp()

  //
  // Application des métadonnées
  //
  Analyse.panneau_infos.setData(analyse.infos)

  // 
  // Application des préférences
  // (elles serviront aussi pour l'affichage des systèmes et des
  // marques, donc il faut les prendre avant d'inscrire les systèmes
  // et les marques)
  // 
  this.setPreferences(analyse.preferences)

  //
  // Affichage des systèmes
  //
  this.displaySystems(analyse)

  //
  // Affichage des marques d'analyse
  //
  this.displayAnalyseTags(analyse.tags)

  console.log("= AFFICHAGE OK =")

  return true
}

/**
 * Nettoyage général de la table d'analyse
 */
static cleanUp(){
  UI.TableAnalyse.innerHTML = ''
}

/**
 * On met les métadonnées de l'analyse dans le
 * panneau des métadonnées
 */
static setMetadata(metadata){
  Object.keys(metadata).forEach( key => {
    DGet('#metadata_' + key).value = metadata[key]
  })
}

/**
 * Application des préférences (principalement pour la suite)
 * 
 */
static setPreferences(appPrefs){
  if ( appPrefs ) {
    /**
      * Apparemment, à la création d'une analyse, appPrefs n'est
      * pas défini.
      */  
    Object.keys(appPrefs).forEach(prefKey => {
      PreferencesAppData[prefKey].value = appPrefs[prefKey]  
    })
  }
  Preferences.init()

}

/**
 * Affichage des systèmes
 * 
 * On s'assure en même temps qu'ils soient bien répartis (espacés),
 * ce qui est surtout utile à la création de l'analyse
 * 
 */
static displaySystems(analyse){
  const systems = analyse.systems
  systems.forEach(sys => {
    sys.build()
  })
}

/**
 * Méthode principale qui réécrit les marques d'analyse
 * 
 * Il y a deux cas :
 *  1)  la vitesse de lecture est à 100 : on place rapidement
 *      les marques
 *  2)  la vitesse est inférieure à 100 : on "joue" l'analyse en
 *      affichant progressivement les marques.
 * 
 */
static displayAnalyseTags(tags){
  tags.forEach(tag => tag.build_and_observe())
}

/**
 * Calcul de la fréquence de lecture
 * 
 * Rappel : 0 = vitesse la plus lente, 99 = vitesse la plus élevée
 * 
 * 0  donnera 5000 (5 secondes entre chaque marque)
 * 99 donnera 50   (1 centième de secondes entre chaque marque)
 * 
 */
calcFrequenceLecture(){
   this.frequenceLecture = (100 - Preferences.get('vitesse_relecture')) * 50
}

/**
 * Affichage de la prochaine marque si elle existe
 * 
 */
afficheNextMarque(){
  if ( this.timerMarque ) {
    clearTimeout(this.timerMarque)
    this.timerMarque = null
  }
  const marque = this.marques.shift()
  if ( marque ) {
    this.drawAMarque(marque)
    this.timerMarque = setTimeout(this.afficheNextMarque.bind(this), this.frequenceLecture)
  } else {
    this.setFinLecture()
  }
}

setFinLecture(){
  console.log("Fin de la lecture")
}

// /**
//  * Lecture (création) de l'objet de données +data+
//  * 
//  */
// drawAMarque(data){
//   // console.log("Je traite la lecture de l'objet : ", data)
//   const o = new AMark(data)
//   o.setValues(data)
//   o.build_and_observe()
//   // TODO Scroller pour voir la marque
// }

  
}// AnalyseDisplayer
