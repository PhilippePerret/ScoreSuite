'use strict';

class Tools {

  static toggle(){this.panneau.toggle.call(this.panneau)}
  static get panneau(){return this._pano || (this._pano = new Panneau(this))}
  static get panneauId(){return 'panneau_outils'}
  static onKeyPress(e){
    var returnU = onKeyDownUniversel(e)
    if ( isBool(returnU) ) return returnU
    if ( e.shiftKey && e.key == 'O' ) return this.toggle()
  }

  /**
  * Méthode appelée depuis le panneau pour lancer l'application
  * ScoreWriter dans le dossier courant
  */
  static runScoreWriter(){
    return message("Je ne parviens pas à lancer proprement score-writer…")
  }

  /* --- MuScore Code Methods --- */

  static onChooseAssistantCode(){
    /**
     ** Méthode appelée pour assister le code muscore à utiliser
     ** Elle est appelée par le menu qui permet d'insérer plein de
     ** choses dans le code.
     **/
    try {
      const code = this.menuAssistantCode.value
      this.musCodeField.value = code + "\n" + this.musCodeField.value
    } catch(err) {
      erreur(err)
    } finally {
      this.menuAssistantCode.selectedIndex = 0
    }

  }

  static get menuAssistantCode(){
    return this._massmuscode || (this._massmuscode = DGet('select#assistant_muscode'))
  }
  static get musCodeField(){
    return this._muscodefield || (this._muscodefield = DGet('textarea#music_score_code'))
  }

  static buildScoreFromCode(){
    /**
     ** Méthode appelée depuis le panneau des outils pour construire
     ** rapidement une image SVG de partition simple à partir du 
     ** code fourni.
     **/
    const muscode = this.musCodeField.value.trim()
    if ( muscode ) {
      WAA.send({
          class:  'ScoreAnalyse::App'
        , method: 'build_image_from_code'
        , data:   {path: Analyse.current.path, code: muscode}
      })
    } else {
      erreur("Il faut donner le code dans le champ.")
    }
  }
  static onBuiltScoreImage(data){
    /**
     ** Retour serveur de la méthode précédente
     **/
    if (data.ok) {
      console.debug("Retour de la construction de l'image : ", data)
      message("L'image a été construite avec succès.\nSon nom est dans le presse-papier, tu peux créer une image pour la voir tout de suite.")
    } else {
      console.error(data.error)
    }
  }



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
}

/**
 * Opérations à faire à l'ouverture du panneau des outils
 * 
 */
Tools.panneau.onOpen = function(){
  DGet('#value_ecart_preferences').innerHTML = Preferences.get('distance_systemes')
}
