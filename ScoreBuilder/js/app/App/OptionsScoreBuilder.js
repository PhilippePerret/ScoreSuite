'use strict';

let OPTIONS_SBUILDER  = {
    ScreensOrder: ['original-score','mus-code','viewer']
  , window_size:  [3400,1440]
}


const LEFTS             = [0,33,66.6]

class OptionsScoreBuilder extends Panneau {

  static prepare(){

    this.close()
    this.watch()
    this.observe()

  }

  /**
  * = main =
  * 
  * Application des options à l’interface et autre
  * 
  */
  static applyOptions(keys){
    // console.log("OPTIONS_SBUILDER:", OPTIONS_SBUILDER)
    if ( undefined === keys ) { keys = Object.keys(OPTIONS_SBUILDER) }
    else if ( 'string' == typeof keys ) { keys = [keys] }
    keys.forEach(key => this['apply_'+key](OPTIONS_SBUILDER[key]) )
  }

  // === Sous-méthode d’application des options ===

  static apply_ScreensOrder(data){
    for ( var i = 0; i < 3; ++i ) {
      const screen_affix = data[i];
      const left = LEFTS[i];
      const divId = `section#section-${screen_affix}`
      const div   = document.querySelector(divId)
      div.style.left = `${left}%`
    }
  }
  static apply_window_size(data){/* rien à faire ici */}


  // ========= FIN DES MÉTHODES D’APPLICATION ==========

  /**
  * = main =
  * 
  * Enregistrement des options Score-Builder
  */
  static save(){
    WAA.send({
      class:  'ScoreBuilder::App',
      method: 'save_config_sbuilder',
      data:   {options: OPTIONS_SBUILDER}
    })
  }

  static observe(){

    // Pour l’option de positionnement des trois "screens"
    $( "ul#screens-position", this.panneau ).sortable({
      update: this.onStopPlacingScreens.bind(this)
    });
    $( "ul#screens-position", this.panneau ).disableSelection();

    // La fenêtre doit être déplaçable
    // $(this.panneau).draggable()

  }


  /**
  * Récupérer les données et les places dans OPTIONS_SBUILDER
  */
  static getValues(){

  }

  /**
  * Pour placer toutes les valeurs d’option dans le formulaire
  * 
  * @rappel
  *   Les valeurs d’options sont toutes les valeurs définies par
  *   ’--<clé option>’ dans le fichier MUS.
  */
  static setValues(values){
    // console.log("-> Options.setValues avec", values)
    Object.values(OPTIONS_SBUILDER).forEach( odata => {

    })

  }


  static onStopPlacingScreens(ev, ui){
    // On relève la position des écrans
    const screensOrder = []
    document.querySelectorAll('ul#screens-position li.screen').forEach(li =>{
      screensOrder.push(li.id.split('_')[1])
    })
    OPTIONS_SBUILDER.ScreensOrder = screensOrder
    this.applyOptions('ScreensOrder');
    this.save()
  }


  static get btnClose(){
    return this._btnclose || (this._btnclose = DGet('.btn-close', this.panneau))
  }
  static get panneau(){
    return this._panneau || (this._panneau = DGet('#panosb'))
  }
}
