'use strict';
class PanneauAnalyse extends Panneau {

  get PROPS(){return ['piece_title', 'composer', 'analyse_title','analyse_id','folder','analyst']}

  constructor(){
    super('panneau_infos')
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
