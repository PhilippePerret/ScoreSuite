'use strict';
/**
  
  Class ScoreClass
  -----------------
  
  Pour gérer la partition en tant qu'ensemble de portées et de
  mesures
  
  Utiliser la constante 'Score' qui est une instance de cette classe.
  
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
  Config.initialize()
}

reset(){
  const _props = ['_stavescount','_systeme']
  _props.forEach( _prop => {
    delete this[_prop]
    this[_prop] = null
  })
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
  Config.reset()

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

  /*
  |  Toutes les notes/mesures définies
  */
  var fullCode = MesureCode.getFullCode(params)
  /*
  |  Cas spécial d'une portée unique avec clé différente de la
  |  clé de sol.
  */
  if ( Config.isOneStaffNotC ) {
    fullCode = `\\cle ${Config.get('piece-staves-dispo')[0].key} ${fullCode}`
  }
  c.push(fullCode)
  c = c.join("\n")

  return c
}

/**
* @return le code pour l'entête du fichier .mus qui servira à 
* produire l'image.
* @param c {Array} Liste des codes déjà insérés
*/
getEnteteCodeMus(c){
  var dispo
  c = c || []
  this.page && c.push('--page ' + this.page)
  switch(dispo = Config.get('piece-staves-dispo')){
  case 'piano'    : c.push('--piano')   ; break
  case 'quatuor'  : c.push('--quatuor') ; break
  case 'sonate-violon'  : 
    c.push('--staves 3')
    c.push('--staves_keys F,G,G')
    break
  default:
    c.push(`--staves ${dispo.length}`)
    if ( dispo.length > 1 ) {
      var keys = [], names = [];
      var has_names = false
      for (var portee of dispo) {
        if (portee.name && portee.name.length > 0 ) {
          has_names = true
          break
        }
      }
      for ( portee of dispo) {
        portee.key  && keys.push(portee.key)
        has_names   && names.push(portee.name)
      }
      keys.length  && c.push(`--staves_keys  ${keys.reverse().join(', ')}`)
      has_names && c.push(`--staves_names ${names.reverse().join(', ')}`)
    }
  }

  /*
  |  Prendre les valeurs de configuration utiles
  */
  const metrique    = Config.get('piece-metrique')
  var st_vspace     = Config.get('mscore-staves-vspace')
  if ( st_vspace == 'undefined') st_vspace = null // bug
  const proximity   = Config.get('mscore-proximity')
  const imageName   = Config.get('mscore-image-name')
  const firstMesu   = Config.get('mscore-first-mesure')
  const pageFormat  = Config.get('mscore-format-page')

  Config.get('mscore-opt-stems')   || c.push('--no_stem')
  Config.get('mscore-opt-barres')  && c.push('--barres')
  c.push(`--tune ${Config.tune}`)
  /*
  |  Options obligatoirement définies
  */
  c.push(`--mesure ${firstMesu ? firstMesu : 'OFF'}`)
  /*
  |  Options conditionnelles
  */
  metrique  && c.push(`--time ${metrique}`)
  st_vspace && c.push(`--staves_vspace ${st_vspace}`)
  proximity && c.push(`--proximity ${proximity}`)
  pageFormat && c.push(`--page ${pageFormat}`)
  /*
  |  Nom de l'image
  */
  imageName && c.push(`-> ${imageName}`)

  return c
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
