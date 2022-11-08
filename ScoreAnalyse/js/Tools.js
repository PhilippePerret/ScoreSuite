'use strict';

class Tools {

  /**
   * Méthode permettant de répartir les systèmes de façon
   * uniforme.
   * Utilisé au tout départ pour écarter les systèmes.
   * Utilisé ensuite pour maintenant un certain écart tout en
   * déplacement tous les éléments du système.
   */
  static distributeSystem(ecart){
    ecart = ecart || Preferences.get('distance_systemes')
    ecart = parseInt(ecart,10)
    console.log("-> distributeSystem(%i)", ecart)
    var current_top = Preferences.get('top_first_system')
    Systeme.each(sys => {
      sys.top = current_top
      current_top += sys.full_height + ecart
      console.log("Système #%i top = %i heigh %i / real_top = %i full_height = %i", sys.index, sys.top, sys.height, sys.real_top, sys.full_height)
    })
    message("Il faut penser à enregistrer l'analyse.")
  }

  static togglePanneau(){
    this.panneau.toggle()
  }

  static get panneau(){
    return this._pano || (this._pano = new Panneau('panneau_outils'))
  }
}

/**
 * Opérations à faire à l'ouverture du panneau des outils
 * 
 */
Tools.panneau.onOpen = function(){
  DGet('#value_ecart_preferences').innerHTML = Preferences.get('distance_systemes')
}
