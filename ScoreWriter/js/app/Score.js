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
  Options.applique(CONFIG.default_options) //TODO À SUPPRIMER
  NewConfiguration.initialize()
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
  Config.reset

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
  |  Cas spéciale d'une portée unique avec clé différente de la
  |  clé de sol.
  */
  if ( Config.isOneStaffNotC ) {
    fullCode = `\\cle ${Config.get('piece-staves-dispo')[0].key} ${fullCode}`
  }
  c.push(fullCode)
  c = c.join("\n")
  console.debug("Le code complet :\n", c)
  
  throw "Tout arrêter"

  return c
}

/**
* @return le code pour l'entête du fichier .mus qui servira à 
* produire l'image.
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
    if ( Number(dispo) > 1 ) {
      stavesData.keys   && c.push('--staves_keys '  + stavesData.keys.reverse().join(', '))
      stavesData.names  && c.push('--staves_names ' + stavesData.names.reverse().join(', '))
    }
  }

  /*
  |  Prendre les valeurs utiles
  */
  const metrique  = Config.get('piece-metrique')
  const st_vspace = Config.get('mscore-staves-vspace')
  const proximity = Config.get('mscore-proximity')
  const imageName = Config.get('mscore-image-name')
  const firstMesu = Config.get('mscore-first-mesure')

  Config.get('mscore-opt-stems')   || c.push('--no_stem')
  Config.get('mscore-opt-barres')  && c.push('--barres')
  c.push(`--tune ${Config.tune}`)
  /*
  |  Options conditionnelles
  */
  firstMesu && c.push(`--mesure ${firstMesu}`)
  metrique  && c.push(`--time ${metrique}`)
  st_vspace && c.push(`--staves_vspace ${st_vspace}`)
  proximity && c.push(`--proximity ${proximity}`)
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
