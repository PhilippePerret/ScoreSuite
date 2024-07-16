'use strict';


class Outils extends Panneau {

  static prepare(){

    this.close()
    this.watch()
    this.observe()

  }



  static observe(){

    listen(this.bntInitRubyModule,'click', this.onClickInitRubyModule.bind(this))
    listen(this.btnOpenRubyModule,'click', this.onClickOpenRubyModule.bind(this))
  
    // La fenêtre doit être déplaçable
    $(this.panneau).draggable()

  }


  /**
  * Méthode appelée quand on clique sur le bouton "Initier le module
  * ruby". Le construit côté serveur.
  */
  static onClickInitRubyModule(ev){
    WAA.send({class:"ScoreBuilder::MusCode", method:"init_ruby_module", data:{}})
    return stopEvent(ev)
  }
  // Retour de la précédente
  static onRubyModuleInitied(wdata){
    if ( wdata.ok ) {
      message("Module ruby initié avec succès.")
    } else {
      erreur(wdata.error )
    }
  }

  /**
  * Méthode appelée par le bouton pour ouvrir le module ruby dans
  * l’éditeur courant
  */
  static onClickOpenRubyModule(ev){
    WAA.send({class:"ScoreBuilder::MusCode", method:"open_ruby_module", data:{}})
    return stopEvent(ev)
  }
  // Retour de la précédente
  static onRubyModuleOpened(wdata){
    if ( wdata.ok ) {
      message("Module ruby ouvert avec succès.")
    } else {
      erreur(wdata.error )
    }
  }

  // === Tous les boutons ===

  static get bntInitRubyModule(){
    return this._btninitmodruby || (this._btninitmodruby = DGet('button#init-module-ruby', this.panneau))
  }

  static get btnOpenRubyModule(){
    return this._btnopenrbmod || (this._btnopenrbmod = DGet('button#btn-open-ruby-module', this.panneau))
  }


  static get panneau(){
    return this._panneau || (this._panneau = DGet('#panneau-outils'))
  }
}
