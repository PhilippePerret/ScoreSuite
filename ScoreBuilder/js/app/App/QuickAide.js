'use strict';


class QuickAide extends Panneau {

  static prepare(){
    this.close()
    this.watch()
  }

  static get btnClose(){
    return this._btnclose || (this._btnclose = DGet('.btn-close', this.panneau))
  }
  
  static get panneau(){
    return this._panneau || (this._panneau = DGet('#panneau-quick-aide'))
  }

}
