'use strict';

class AppClass {

/**
 * Méthode appelée par App::get_code côté serveur, pour remonter
 * le code actuel de la partition
 */
onGetCode(data){
  console.info("Retour de la relève du code serveur = ", data)
  if (data.ok) {  
    if (data.code) {
      App.traiteCodeInitial(data.code)
      Score.setData(data)
      Score.update(data.images, data.affixe)
      data.config && Options.applique(data.config)
    } else {
      MesureCode.createNew()
    }  
  } else {
    erreur(data.err_msg)
  }
}

/**
 * Méthode qui envoie le code au serveur pour construire l'image
 * 
 */
submitCode(){
  message("Actualisation en cours…", {keep: true})
  const finalCode = Score.getCodeFinal()
  //
  // On met le nom de l'image dans le formulaire (même si ce nom est
  // non défini)
  // 
  DGet('#image_name_in_form').value = Options.getImageName()
  // 
  // Envoi du code ou renoncement
  // 
  if ( ! finalCode ) {

    // 
    // S'il n'y a pas de code final (pour une erreur quelconque)
    // 
    console.error("Il n'y a pas de code… Score.getCodeFinal() n'a rien renvoyé.")
    return erreur("Une erreur s'est produite. Consulter la console.")

  } else {
    WAA.send({class:'ScoreWriter::App',method:'build_score',
      data:{
        code:     finalCode,
        affixe:   Options.getImageName()
      }
    })
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
  } else {
    erreur(data.err_msg.join('<br/>'))
  }
}

/**
 *
 * Méthode générale principale traitant un code complet donné
 * (ou remonté au lancement) 
 */
traiteCodeInitial(fullcode){
  console.info("fullcode reçu : ", fullcode)
  if ( undefined == fullcode ) {
    fullcode = DGet('#ini_code').value
  }
  if ( fullcode == '') {
    return error("Aucun code n'a été fourni.")
  }
  // 
  // On passe en revue chaque ligne pour définir les options
  // 
  var notes   = [] 
  var options = {}
  fullcode.forEach(line => {
    line = line.trim()
    if ( line.substring(0, 2) == '->') {
      // 
      // Nom de l'image
      // 
      const image_name = line.substring(2, line.length).trim()
      Options.setImageName(image_name)

    } else if ( line.substring(0, 2) == '--' ){
      // 
      // Une options quelconque
      // 
      var opts = line.substring(2, line.length).split(' ')
      var option = opts.shift()
      var valoption = opts.join(' ')
      switch(option){
        case'piano': case'solo': case'duo': case'trio': case'quatuor':
          console.info("Option %s rencontrée", option)
          valoption = option
          option    = 'systeme' 
          break
      }
      if ( valoption == '' ) valoption = true
      // console.log("L'option '%s' est mise à %s", option, valoption)
      options[option] = valoption
    } else {
      // 
      // Une ligne de notes
      // 
      // Si la ligne commence par \fixed, il faut le traiter
      if ( line.match(/^\\fixed /)) {
        // Retirer la marque
        var offset = line.indexOf('{') + 2
        line = line.substring(offset, line.length - 2)
        // Mettre l'option "Hauteur fixe"
        options['note_tune_fixed'] = true
      }
      // 
      notes.push(line)
    
    }
  })
  // 
  // Pour mémoire
  // 
  Options.data_ini = options
  // 
  // Traitement des options
  //
  Staff.reset()
  Options.applique(options)
  // 
  // Traitement des notes
  // 
  notes = notes.join("\n").trim()
  // console.info("Notes récupérées : ", notes )
  MesureCode.parse(notes)
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
  const imgname = Options.getImageName()
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
            affixe: Options.getImageName()
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
