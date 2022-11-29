'use strict';
class PanneauInfos {

  get PROPS(){return ['piece_title', 'composer', 'analyse_title','analyse_id','folder','analyst']}

  toggle(){ this.panneau.toggle.call(this.panneau)}
  get panneau(){return this._pano||(this._pano = new Panneau(this))}
  get panneauId(){return 'panneau_infos'}
  onKeyPress(e){
    var returnU = onKeyDownUniversel(e)
    if ( isBool(returnU) ) return returnU
    if ( e.shiftKey && e.key == 'I' ) return this.toggle()
  }

  /**
   * Retourne les données du panneau
   * 
   */
  getData(){
    var data = {}
    this.PROPS.forEach(prop => {
      Object.assign(data, {[prop]: DGet(`#metadata_${prop}`).value})
    })
    return data
  }

  /**
   * Renseigne les champs du panneau avec les données de
   * +data+
   * 
   */
  setData(data){
    this.PROPS.forEach(prop => {
      DGet(`#metadata_${prop}`).value = data[prop]||''
    })
  }

  /**
   * @param params Table ou liste des propriétés qui sont
   *        absolument attendues.
   */
  checkData(params){

  }
}
