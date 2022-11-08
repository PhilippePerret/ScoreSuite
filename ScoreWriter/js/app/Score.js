'use strict';
/**
 * Class ScoreClass
 * -----------------
 * 
 * Pour gérer la partition
 * 
 * Utiliser la constante 'Score'
 * 
 */

class ScoreClass {

/**
 * Pour définir (mémoriser) les données du score courant
 * 
 */
setData(data){
  this.path = data.affixe // pour tous les enregistrements
}

/**
 * Pour appliquer les options par défaut
 * 
 */
resetOptions(){
  Options.applique(CONFIG.default_options)
}

reset(){
  const _props = ['_stavescount','_systeme']
  _props.forEach( _prop => {
    delete this[_prop]
    this[_prop] = null
  })
}

/**
 * Retourne le nombre de portées (par système)
 * 
 * Par exemple, si c'est un piano, on retourne 2, si c'est un trio
 * on retourne 3.
 * 
 */
get nombrePortees(){
  return this._stavescount || (this._stavescount = this.countStaves())
}
set nombrePortees(v){ this._stavescount = v }
countStaves(){
  if ( this.isPiano || this.isDuo ) {
    return 2
  } else if ( this.isTrio ) {
    return 3
  } else if ( this.isQuatuor ) {
    return 4
  } else if ( this.isMono ) {
    return 1
  } else {
    return parseInt(this.systeme,10)
  }
}

get isMono    (){return this.systeme == 'mono'}
get isPiano   (){return this.systeme == 'piano'}
get isDuo     (){return this.systeme == 'duo'}
get isTrio    (){return this.systeme == 'trio'}
get isQuatuor (){return this.systeme == 'quatuor'}

get tune          (){ return this.getOption('tune')}
get metrique      (){ return this.getOption('time')}
get mesure        (){ return this.getOption('mesure')}
get page          (){ return this.getOption('page') }
get proximity     (){ return this.getOption('proximity')}
get staves_vspace (){ return this.getOption('staves_vspace')}
get systeme   (){ 
  return this._systeme || (this._systeme = this.getOption('systeme')) 
}

getOption(key){
  return Options.getProperty(key)
}
/**
 * = main =
 * 
 * Grand méthode qui construit le code complet de la
 * partition, avec les options et tous les détails.
 * C'est par exemple ce code qui est envoyé pour la fabrication de
 * la partition.
 * 
 * @return  le code {String} final, en langue music-score, pour 
 *          construire l'image de la partition
 * 
 * @param params {Hash} 
 *    :from         Depuis cette mesure (toujours défini, 1 par défaut)
 *    :to           Jusqu'à cette mesure (idem)
 *    :image_name   Nom éventuel de l'image
 *    :outputFormat Format de sortie des données :
 *                    normal      Comme son nom l'indique
 *                    variables   Chaque mesure dans une variable
 *                    data        Sous forme de table de données
 */
getCodeFinal(params){
  params = params || {}
  var c = []
  this._systeme = null

  if ( params.outputFormat == 'data' ) {

    // 
    // Format pour score-extraction
    // 
    // (peut-être qu'il y aura des choses à mettre un jour, en
    //  fonction des options et du développement du programme)
    // 

  } else {

    // 
    // Format autre que data de mesures (mais on en a quand même
    // besoin pour mettre le code à copier-coller pour le ré-éditer)
    // cf. getFullCodeInTableData
    // 
    c = this.getEnteteCodeMus(c)

  }

  // 
  // On prend toutes les notes
  // 
  c.push(MesureCode.getFullCode(params))
  c = c.join("\n")
  // console.log("Le code complet : ", c)
  return c
}

getEnteteCodeMus(c){
  c = c || []
  this.page && c.push('--page ' + this.page)
  if ( this.isPiano ) {
    c.push('--piano')
  } else if ( this.isQuatuor ) {
    c.push('--quatuor')
  } else if ( this.nombrePortees > 1) {
    c.push('--staves ' + this.nombrePortees)
  }
  // 
  // Données pour les portées
  // 
  const stavesData = Options.getStavesData()
  // console.info("stavesData:", stavesData)
  stavesData.keys   && c.push('--staves_keys '  + stavesData.keys.reverse().join(', '))
  stavesData.names  && c.push('--staves_names ' + stavesData.names.reverse().join(', '))

  this.getOption('stems')  || c.push('--no_stem')
  this.getOption('barres') && c.push('--barres')
  this.staves_vspace  && c.push('--staves_vspace '  + this.staves_vspace)
  this.tune           && c.push('--tune '           + this.tune)
  this.metrique       && c.push('--time '           + this.metrique)
  this.mesure         && c.push('--mesure '         + this.mesure)
  this.proximity      && c.push('--proximity '      + this.proximity)
  /**
   * Nom de l'image
   */
  c.push('-> ' + this.imageName)
  return c
}

/**
 * Retourne le nom de l'image par défaut ou défini
 */
get imageName(){
  return Options.getImageName() || 'default'
}

/**
 * Pour forcer l'actualisation de l'image de la partition
 * ou des images de la partition
 * 
 */
update(images){
  const container = ImgScore.container
  const containerScrollTop = container.scrollTop
  container.innerHTML = ''
  var i = 0
  var images_count = images.length;
  images.forEach(image_relpath => {
    const img_id = `score-${++i}`
    let img = DCreate('IMG', {id: img_id})
    container.appendChild(img)
    img.src = image_relpath+'?'+(new Date().getTime())
    img.addEventListener('load', () => {
      images_count --
      if ( images_count == 0 ) {
        // Quand toutes les images sont chargées, on réajuste
        // le container au niveau de son zoom et son scrolling
        ImgScore.setScoreContainer({scrollTop:containerScrollTop})
      }
    })
  })
}

}//ScoreClass

const Score = new ScoreClass()
