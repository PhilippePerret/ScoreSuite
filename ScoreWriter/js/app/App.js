'use strict';

class AppClass {

get version(){return '2.1.0'}

getCode(){
  /** = Main =
   ** Méthode appelée au chargement de l'app pour remonter le code
   ** de l'image spécifiée ou la dernière image éditée.
   **/
  WAA.send({
      class:'ScoreWriter::App'
    , method:'get_code'
    , data: { default:null, config:null}
  })
}

onGetCode(data){
  /** = main =
   **
   ** Méthode qui reçoit le code de l'image remonté du serveur.
   ** App.onGetCode
   **/
  // console.debug("Relève code serveur = ", data)
  if (data.ok) {  
    if (data.code) {
      try {
        /*
        |  On commence par appliquer la configuration
        */
        this.applyConfig(data.config)
        const notes = App.traiteCodeInitial(data.code)
        MesureCode.parse(notes)
        Score.setData(data)
        Score.update(data.images, data.affixe)
        /*
        |  On applique à nouveau les configurations
        */
        this.applyConfig(data.config)
      } catch(err) {
        console.error(err)
        erreur(err + '<br>Je dois m’interrompre.')
      }
    } else {
      MesureCode.createNew()
    }  
  } else {
    erreur(data.err_msg)
  }
}

applyConfig(config) {
  if (config) {
    if ( config.app_version && Number(config.app_version.split('.')[0]) >= 2 ) {
      console.info("Configuration de version >=2 (=> application)")
      Config.setData(config)
    } else {
      erreur("C'est un ancien fichier de configuration. Je ne peux plus le traiter. Il faut que tu règles à nouveau les configurations.")
    }
  } else {
    Config.initialize()
  }
}

buildImage(){
  /** = main =
   ** 
   ** Envoie le code au serveur pour construire l'image
   ** Dans beaucoup de cas, c'est la méthode la plus importante,
   ** puisqu'elle permet de produire le code MusisScore ainsi que 
   ** l'image SVG attendue. C'est en quelque sort l'enregistrement de
   ** l'image.
   **/
  message("Fabrication de l'image en cours…", {keep: true})
  const finalCode = Score.getCodeFinal()
  if ( finalCode ) {
    Config.reset() // pour forcer le recalcul
    WAA.send({class:'ScoreWriter::App',method:'build_score',
      data:{
          code:     finalCode
        , affixe:   Config.imageName
        , config:   Config.data4save
      }
    })
  } else {
    /*
    |  S'il n'y a pas de code final (pour une erreur quelconque)
    */
    console.error("Il n'y a pas de code… Score.getCodeFinal() n'a rien renvoyé.")
    return erreur("Une erreur s'est produite. Consulter la console.")
  }
}

/**
 * Méthode de retour de la construction du code
 * On force l'actualisation des images avec les
 * nouvelles images fabriquées
 */
onScoreBuilt(data){
  if ( data.ok ) {
    Score.update(data.images)
    message("Partition construite avec succès.")
  } else {
    erreur(data.err_msg.join('<br/>'))
  }
}

traiteCodeInitial(fullcode){
  /** Méthode générale principale traitant un code complet donné ou
   ** remonté au lancement 
   **/
  console.info("fullcode reçu : ", fullcode)
  fullcode = fullcode || DGet('#ini_code').value
  fullcode || raise("Aucun code n'a été fourni.")
  /*
  |  On passe en revue chaque ligne pour ajuster les options
  */
  var notes   = [] 
  var options = {}
  var onlyOneStaff = false, staffCount, stavesKeys, stavesNames ;
  fullcode.forEach(line => {
    line = line.trim()
    if ( line.substring(0, 2) == '->') {
      /*
      |  Nom de l'image
      */
      Config.imageName = line.substring(2, line.length).trim()

    } else if ( line.substring(0, 2) == '--' ){
      /*
      |  Une option quelconque
      */
      var dopt    = line.substring(2, line.length).split(' ')
      var option  = dopt.shift()
      var valopt  = dopt.join(' ') || true
      switch(option){
        case'piano':case'sonate-violon':case'quatuor':
          Config.setValue('piece-staves-dispo', option)
          break
        case 'staves': // Nombre de portées
          staffCount = Number(valopt)
          Config.setMenuDisposition(staffCount)
          onlyOneStaff = staffCount == 1
          break
        case 'staves_keys':
          stavesKeys = valopt.split(',').reverse
          stavesKeys.length == staffCount || raise(`Le nombre de clés définies (${stavesKeys.length}) ne correspond pas au nombre de portées (${staffCount})`)
          break
        case 'staves_names':
          stavesNames = valopt.split(',').reverse
          stavesNames.length == staffCount || raise(`Le nombre de clés définies (${stavesNames.length}) ne correspond pas au nombre de portées (${staffCount})`)
          break
        case'tune': case'metrique':
          Config[option] = valopt
          break
        case 'barres': 
          Config.setValue('mscore-opt-barres', true)
          break
        case 'no_stem':
          Config.setValue('mscore-opt-stems', false)
          break
      }
    } else {
      /*
      |  Une ligne de notes
      */
      if ( line.match(/^\\fixed /)) {
        /*
        |  Si la ligne indique que les notes sont en hauteur fixe, il
        |  faut retirer cette marque et régler les configurations.
        */
        var offset = line.indexOf('{') + 2
        line = line.substring(offset, line.length - 2)
        Config.setValue('mscore-tune-fixed', true)
      }
      if ( onlyOneStaff && line.startsWith('\\cle') ) {
        /*
        |  Cas d'une ligne unique avec une clé autre que G (on doit
        |  retirer la clé)
        */
        line = line.replace(/^\\cle (F|UT[1-4]) /, '').trim()
      }
      // 
      notes.push(line)
    
    }
  })
  /*
  |  Définition de la disposition des portées (noter que pour le 
  |  moment, si c'est une image qui a sa configuration, l'opération
  |  sera faite deux fois : 1 fois ici, 1 fois avec le fichier de
  |  configuration de l'image)
  */
  if ( staffCount ) {
    const data_staves = []
    for (var i = 0 ; i < staffCount ; ++i) {
      data_staves.push({
          key:  (stavesKeys  && stavesKeys[i])  || 'G'
        , name: (stavesNames && stavesNames[i]) || ''
      })
    }
    Config.setValue('piece-staves-dispo', data_staves)
  }

  /*
  |  Traitement des notes
  */
  notes = notes.join("\n").trim()
  // console.info("Notes récupérées : ", notes )
  return notes
}

/**
 * Procédure de production du code .mus final
 * 
 */
produceFinalCode(){
  var params = {}
  const field = DGet('#final_code')

  // 
  // Format de sortie des données.
  // 
  const outputFormat = DGet('#output_format').value
  console.info("Format de sortie : ", outputFormat)
  
  Object.assign(params, {outputFormat: outputFormat})
  let from_mes  = DGet('#output_from_mesure').value.trim()
  from_mes  = from_mes == '' ? 1 : parseInt(from_mes,10)
  Object.assign(params, {from: from_mes})
  let to_mes    = DGet('#output_to_mesure').value.trim()
  to_mes    = to_mes == '' ? Score.count : to_mes
  Object.assign(params, {from: from_mes, to:to_mes})
  const imgname = Config.imageName
  if ( imgname != '' ) Object.assign(params, {image_name:imgname})

  field.value = Score.getCodeFinal(params)
  field.style.height = px(200)
}

/**
 * 
 * Construire le fichier 'data_mesures.rb' dans le dossier
 * courant.
 * 
 */
produceMesureDataFile(data){
  if (undefined == data) {
    // Production de l'opération
    const RubyCode = Score.getCodeFinal({outputFormat:'data'})
    console.log("rubyCode : ", RubyCode)
    WAA.send({
        class:'ScoreWriter::App'
      , method:'build_mesures_data_file'
      , data:{
            affixe: Config.imageName
          , code: RubyCode
        }
      })
  } else {
    // Retour de l'opération
    if (data.ok) {
      message("Fichier mesures_data.rb construit avec succès.")
    } else {
      erreur(data.error)
    }
  }
}

/**
 * Pour forcer la production du code en cas de problème
 * 
 */
forceCodeFinal(){
  const field = DGet('#final_code')
  let codePortees = {}
  // 
  // On boucle sur les mesures tant qu'on en trouve
  // 
  DGetAll('#mesures_code > div').forEach(div => {
    DGet('input[type="text"][data-portee]', div).forEach(input => {
      var indexPortee = parseInt(input.getAttribute('data-portee'),10)
      if ( undefined == codePortees[indexPortee] ) {
        Object.assign(codePortees, { [indexPortee]: []})
      }
      codePortees[indexPortee].push(input.value.trim())
    })
  })
  //
  // On rassemble tout le code
  // 
  var code = []
  for( var iportee in codePortees ) {
    code.push(codePortees[iportee].join(' | '))
  }
  code = code.join("\n")
  field.value = code 
  field.style.height = px(200)
}

}//AppClass


const App = new AppClass()
