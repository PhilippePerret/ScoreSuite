'use strict';
/**
 * class MesureCode
 * -----------------
 * Pour les input-text qui contiennent chaque mesure de code.
 * 
 * Principe :
 *  - une mesure-code contient toujours ses deux lignes
 * 
 */

// Largeur pour un caractère dans les champs de mesure
const WIDTH_PER_CHAR = 13

class MesureCode {

/**
 * @return {String} Le code complet
 * 
 * @param params {Hash}
 *      :from         Première mesure (première, par défaut)
 *      :to           Dernière mesure (fin, par défaut)
 *      :variables    OBSOLÈTE Si true, utiliser des variables (globales)
 *      :image_name   Si défini, c'est le nom de l'image finale
 *      :outputFormat   'normal', 'variables' ou 'data'
 */
static getFullCode(params){
  var c = []
  params = params || {}
  const outputFormat = params.outputFormat || 'normal'
  if ( undefined == params.from ) params.from = 1;
  if ( undefined == params.to   ) params.to   = this.count;
  const nombrePortees = Score.nombrePortees
  console.info("Export du code de la mesure %i à la mesure %i", params.from, params.to)
  for(var xportee = 0; xportee < nombrePortees; ++xportee){
    c.push([])
    for(var imesure = params.from - 1; imesure < params.to; ++ imesure){
      const mes = this.table_mesures[imesure]
      if (!mes) break ; // Numéro de dernière mesure trop grand
      var code = mes.getPorteeCode(parseInt(xportee,10) + 1).trim()
      if ( code == "" ) {
        // Ne rien faire
      } else if ( code.replace(/[0-9]/g) == '' ) {
        // <= le code est seulement un nombre, et que ce nombre est
        //    inférieur à la mesure courante, 
        // => Copie d'une autre mesure
        var imesure_copie = parseInt(code, 10) - params.from
        if ( imesure_copie < 0 ) {
          code = c[xportee][imesure_copie]
        } else {
          console.error("Impossible de faire une copie de la mesure %i. Elle se trouve après la mesure %i…", imesure_copie, imesure)
        }
      }
      c[xportee].push(code)
    }
    if ( outputFormat == 'normal' ) {
      // 
      // Si on ne doit pas utiliser des variables (cas normal), on
      // "compile" les messures
      // 
      c[xportee] = c[xportee].join(' | ').trim()
      // 
      // On vérifie qu'il n'y ait pas de mesure vide à la fin
      // 
      if ( c[xportee].endsWith('|') ) {
        c[xportee] = c[xportee].substring(0, c[xportee].length - 1).trim()
      }
    }
  }
  //
  // Retour en fonction du format de sortie
  // 
  switch(outputFormat){
    case 'normal':
      return this.getFullCodeNormal(params, c)
    case 'data':
      return this.getFullCodeInTableData(params, c)
    case 'variables':
      return this.getFullCodeInVariables(params, c)
  }
}

static getFullCodeNormal(params, portees){
  if ( Options.note_tune_fixed ) {
    console.info("Hauteur note en valeur absolue")
    const nombrePortees = Score.nombrePortees
    var portees_finales = []
    for (var xportee = 0; xportee < nombrePortees; ++xportee) {
      var iportee = parseInt(xportee,10) + 1
      var dataPortee = Staff.get(iportee)
      console.log("Data de portée %i : ", iportee, dataPortee)
      var hauteur = dataPortee.data.key == 'F' ? "c" : "c'";
      console.info("Hauteur fixe de portée %i : ", iportee, hauteur)
      portees_finales.push(`\\fixed ${hauteur} { ${portees[xportee]} }`)
    }
    portees = portees_finales;
  }
  portees = portees.join("\n")
  return portees
}

/**
 * Méthode utilisée pour retourne une version "table de données des
 * mesures" de la partition, pour une utilisation avec score-extract
 * (extraction de n'importe quelle mesure)
 * 
 * @param params  Cf. getFullCode ci-dessus
 * @param c       Liste du code par portée (c[portée 1], c[portée 2] 
 *                etc.). Construit dans la méthode getFullCode
 * 
 * @return Retourne une table ruby (en string) de la forme :
 *          ««««««««««««««««
 *          DATA_MESURES = {
 *            1 => ["main droite", "main gauche"], // ou + si + de portée
 *            2 => ["main droite", "main gauche"],
 *            3 => ["main droite", "main gauche"],
 *            4 => ["main droite", "main gauche"],
 *          }
 *          »»»»»»»»»»»»»»»»
 */
static getFullCodeInTableData(params, portees){
  const nombrePortees = Score.nombrePortees
  // 
  // Pour construire la table finale
  // 
  var table = []
  table.push('# encoding: UTF-8')
  table.push('# Il faut copier ce code dans un fichier "data_mesures.rb" dans un')
  table.push('# dossier dédié. Ensuite, il suffit d’ouvrir un terminal à ce dossier')
  table.push('# et de lancer "score-extract <from mesure> <to mesure> [options]"')
  table.push("# pour obtenir un extrait des mesures voulues.\n\n")
  table.push('DATA_MESURES = {')
  // 
  // Pour pour obtenir chaque mesure
  // 
  for(var xmesure = params.from; xmesure <= params.to; ++xmesure){
    const imesure = xmesure - params.from
    var portees_mesure = []
    portees.forEach(mesures => {
      portees_mesure.push(mesures[imesure])
    })
    table.push( '  ' + xmesure + ' => ["' + portees_mesure.join('", "').replace(/\\/g,'__DBLSLASH__') + '"],')
  }
  
  // 
  // Fin de la table
  // 
  table.push('}')

  // 
  // On ajoute en dessous le code pour pouvoir le rééditer dans
  // cette application
  // 
  table.push("\n\n\n")
  table.push("=begin\nCe code permettra de ré-éditer la partition\ndans MusicScoreWriter\n")
  table.push("Il suffit de le copier dans le panneau OUTILS, champ CODE INITIAL.\n\n")
  table.push(Score.getEnteteCodeMus().join("\n"))
  const params_for_full_code = Object.assign({}, params)
  params_for_full_code.outputFormat = 'normal'
  table.push(this.getFullCode(params_for_full_code))
  table.push("\n\n=end")

  // 
  // Finaliser la table
  // 
  table = table.join("\n").replace(/\\/g, '__SLASH__')

  return table
}

/**
 * Méthode utilisée pour retourner tout le code avec chaque mesure
 * dans une variable
 */
static getFullCodeInVariables(params, portees){
  const nombrePortees = Score.nombrePortees
  var vars = []
  for(var xmesure = params.from; xmesure <= params.to; ++xmesure){
    const varName = 'mesure' + String(xmesure)
    const imesure = xmesure - params.from
    vars.push([varName])
    for(var xportee = 0; xportee < nombrePortees; ++xportee){
      vars[imesure].push(portees[xportee][imesure])
    }
  }

  var codevar   = []
  var codescore = []
  vars.forEach( dvar => {
    const varName = dvar.shift()
    codescore.push(varName)
    codevar.push("\n" + varName + "==")
    dvar.forEach( mes => codevar.push(mes) )
  })
  codevar = codevar.join("\n")
  // console.log("vars: ", vars)

  // 
  // Pour rassembler les portées
  // 
  const lineScore = codescore.join(' ')
  codescore = []
  for(var xportee = 0; xportee < nombrePortees; ++xportee){
    codescore.push("\\fixed c' { " + lineScore + ' }')
  }

  if ( params.image_name ) {
    params.image_name = "-> " + params.image_name + "\n"
  } else {
    params.image_name = ""
  }
  return codevar + "\n\n" + params.image_name + codescore.join("\n")

}

/**
 * Méthode qui "parse" le code +code+
 * Parser signifie : le décomposer en systèmes (autant que de lignes)
 * et le découper en mesure, pour reconstruire l'affichage et pouvoir
 * le modifier.
 * 
 * Cette méthode est appelée par la méthode App.traiteCodeInitial()
 * qui parse un code complet donné par les outils pour reproduire un
 * code complet.
 * 
 */
static parse(code){
  this.reset()
  // console.log("Je dois parser le code :", code)
  const porteesCode = code.split("\n")
  const nombrePortees = Score.nombrePortees = porteesCode.length
  console.info("Nombre de portées = %i", nombrePortees)
  for(var iportee = 0; iportee < nombrePortees; ++ iportee){
    var mesuresCode = porteesCode[iportee];
    while ( mesuresCode.endsWith('|') ){
      mesuresCode = mesuresCode.substring(0, mesuresCode.length - 1)
    }
    // console.log("Étude de la mesuresCode : ", mesuresCode)
    mesuresCode = mesuresCode.split(' | ')
    // console.log("Mesures de code : ", mesuresCode)
    for(var imesure = 1, len = mesuresCode.length; imesure <= len; ++imesure){
      let mesure;
      if ( iportee == 0 ) {
        // 
        // Si c'est la première portée de la mesure-code, on
        // crée une nouvelle mesure-code. Cela crée toutes les 
        // portée superposée de la mesure courante.
        // 
        mesure = this.createNew()
      } else {
        mesure = this.table_mesures[imesure - 1]
        mesure || console.error("Impossible d'obtenir la mesure-code ")
      }
      // 
      // Dans tous les cas, on définit le code
      // de la portée x
      //
      var c = mesuresCode[imesure - 1].trim()
      // console.log("Code mesure = ", c)
      mesure.setPorteeCode(1 + iportee, c)
    }
  }
}

/**
 * Méthode "tournant" la méthode +method+ sur chaque mesure-code
 * 
 * Rappel : une "mesure-code", c'est un ensemble de portées par 
 * système
 * 
 * #exemple
 *    MesureCode.each(mes => console.log(mes.code))
 * 
 */
static each(method){
  if ( this.count == 0 ) return
  this.table_mesures.forEach(mesure => method(mesure))
}

/**
 * Méthode appelée par le bouton "+" pour créer une nouvelle 
 * mesure-code. Ou quand on doit recréer une partition
 */
static createNew(data){
  const mesure = new this(this.getNextId());
  if (data) mesure.data = data
  mesure.build()
  mesure.focus()
  this.add(mesure)
  return mesure
}

/**
 * Pour détruire la mesure courante
 * Si elle contient du code, on demande confirmation
 * 
 */
static removeCurrent(){
  if ( this.current ) {
    var confirmed = true
    if ( this.current.isNotEmpty ){
      confirmed = confirm("Voulez-vous vraiment détruire la mesure "+ this.current.number +" ?")
    }
    if ( confirmed ) {
      this.current.obj.remove()
      this.table_mesures.splice(this.current.number - 1, 1)
      this.lastId = 0
      this.table_mesures.forEach(mes => mes.updateId(this.getNextId()))
      message("La mesure #" + this.current.number + " a été supprimée.")
      this.current = null
    }
  } else {
    error("Il faut choisir la mesure à détruire en focussant dans un de ses champs-portée.")
  }
}
/**
 * Pour ajouter la mesure-code +mesure+ à la liste Array des mesures
 *
 */
static add(mesure){
  if (!this.table_mesures) this.table_mesures = []
  this.table_mesures.push(mesure)
}

/**
 * Retourne le nombre de mesures
 * 
 */
static get count(){
  if (!this.lastId) this.lastId = 0;
  return this.lastId
}

/**
 * Méthode appelée quand on change le numéro de la première mesure
 * 
 */
static onChangeFirstMesureNumber(ev){
  this.firstMeasureNumber = UI.getFirstNumber()
  this.each(mescode => mescode.updateMeasureNumber())
  return stopEvent(ev)
}

static get firstMeasureNumber(){return this._firstnum || ( this._firstnum = UI.getFirstNumber())}
static set firstMeasureNumber(v){this._firstnum = v}


static getNextId(){
  if (!this.lastId) this.lastId = 0;
  return ++ this.lastId;
}


/**
 * Quand on clique sur le bouton pour réinitialiser tout
 * 
 */
static resetAll(){
  this.reset()
  this.createNew()
}

static reset(){
  this.container.innerHTML = ""
  this.table_mesures = []
  this.lastId = 0
}


static get container(){
  return this._container || (this._container = document.querySelector('#mesures_code'))
}

// --- INSTANCE ---

constructor(id, notes){
  this.id     = id
  this.notes  = notes
}

/**
 * Retourne le code de la portée +xportee+ de cette mesure-code
 * 
 */
getPorteeCode(xportee) {
  xportee = xportee || 1
  const val = this.obj.querySelector('.mesure_code.portee'+xportee).value
  // console.info("Code de la portée " + xportee + " du système " + this.id, val)
  return val
}
setPorteeCode(xportee, code){
  // console.log("Je dois mettre la portée " + xportee + " à : ", code)
  this.obj.querySelector('.mesure_code.portee'+xportee).value = code
  this.setWidth()
}

/**
 * Retourne TRUE quand il n'y a aucun code
 * 
 */
get isEmpty(){
  for(var iportee = 1; iportee <= Score.nombrePortees; ++iportee){
    if ( this.getPorteeCode(iportee) != "" ) return false
  }
  return true
}
get isNotEmpty(){return !this.isEmpty}

/**
 * Méthode qui permet de définir la taille de la mesure en fonction
 * de son contenu (à chasse fixe)
 * Elle est appelée :
 *  - quand on reprend un code au chargement de la page
 *  - quand on blure d'une mesure quelconque
 * 
 */
setWidth(){
  // console.log("-> setWidth")
  // 
  // On prend le texte le plus long
  // 
  // On en profite aussi pour voir si la mesure est complètement
  // définie (i.e. toutes ses portées contient du code)
  // 
  var max = 0
  this.complete = true; // pour savoir si toutes les portées sont définies
  this.eachObjetMesure(mes => {
    var c = mes.value.trim()
    if ( c.length > max ) max = c.length
    else if ( c.length == 0 ) {
      this.complete = false
    }
  })
  // 
  // Une valeur minimale
  // 
  max || (max = 10);

  // 
  // On met tous les champs à la même longueur
  // 
  this.eachObjetMesure(mes => {
    mes.style.width = px(max * WIDTH_PER_CHAR)
  })
}

/**
 * Pour se placer dans le premier champ (en haut)
 * 
 */
focus(porteeIndex = 1){
  this.obj.querySelector('.mesure_code.portee'+porteeIndex).focus()
}

/**
 * Mesure pour actualiser l'identifiant de la mesure (par exemple après
 * une suppression ou une insertion de mesure)
 * 
 * Pour bien comprendre : 
 *    - l'id est le nombre de la mesure-code dans la liste
 *    - number est le nombre réel de la mesure, en fonction du numéro
 *      de première mesure défini
 * 
 */
updateId(newId){
  this.id = newId
  this.updateMeasureNumber()
}

/**
 * Méthode pour définir le numéro de mesure de cette mesure-code et
 * l'afficher au-dessus des champs
 * 
 */
updateMeasureNumber(){
  this._number = null
  this.obj.querySelector('.mesure_number').innerHTML = this.number
}
get number(){return this._number || (this._number = this.calcNumber())}
set number(v){this._number = v}
calcNumber(){
  return this.id + this.constructor.firstMeasureNumber - 1
}


get isLastMesure(){
  return this.number == MesureCode.count
}


/**
 * Méthode qui boucle sur chaque champ de texte de mesure de
 * cette mesure-code
 * 
 */
eachObjetMesure(methode){
  const nombrePortees = 0 + Score.nombrePortees
  for (var iportee = 1; iportee <= nombrePortees; ++iportee) {
    const omesure = this.obj.querySelector('.mesure_code.portee' + iportee)
    methode(omesure)
  }  
}

/**
 * Méthode de construction de la mesure-code
 */
build(){
  const o = DCreate('DIV', {class:'mesure_code'})
  // 
  // On met le champ pour le numéro de mesure
  // 
  o.appendChild(DCreate('DIV', {class:'mesure_number', text: this.number}))
  this.obj = o
  /**
   * 
   * On ajoute autant de systèmes qu'il en faut
   * 
   */
  for (var isys = 1; isys <= Score.nombrePortees; ++isys) {
    this.createPortee(isys)
  }

  this.constructor.container.appendChild(this.obj)

  this.observe()

}

/**
 * Méthode ajoutant la portée d'index 1-start iPortee
 * 
 */
createPortee(iPortee){
  this.obj.appendChild(DCreate('INPUT', {type:'text', 'data-portee': iPortee, class:'mesure_code portee' + iPortee}))  
}

observe(){
  // console.log("-> observe", this)
  this.eachObjetMesure(mes => {
    mes.addEventListener('blur', this.onBlurMesure.bind(this, mes))
    mes.addEventListener('focus', this.onFocusPortee.bind(this, mes))
    mes.addEventListener('change',this.onChangeMesure.bind(this,mes))
  })
}

/**
 * Appelée quand on focusse dans une portée
 * 
 * Note : on ferme l'éventuel panneau ouvert.
 * 
 */
onFocusPortee(mes, ev){
  this.setCurrent(mes)
  Onglet.closeIfCurrent()
  return stopEvent(ev)
}

/**
 * Appelée pour se positionner dans le champ suivant
 * 
 * Cette méthode a été inaugurée pour palier le fait que le champ
 * d'adresse se sélectionne quand on est sur le dernier champ
 * Maintenant, lorsque l'on est sur le dernière champ, c'est une
 * nouvelle mesure qui est créée.
 * 
 * Le comportement est le suivant :
 *  - si l'on ne se trouve pas sur la dernière portée (en bas), on
 *    passe à la portée suivante.
 *  - si l'on se trouve sur la dernière portée (en bas) et qu'il y a
 *    une mesure suivante, on focusse sur sa première portée
 *  - si l'on se trouve sur la dernière portée de la dernière mesure,
 *    on crée une nouvelle mesure.
 * 
 */
focusNextField(){
  const indexPorteeCourante = parseInt(this.currentField.getAttribute('data-portee'),10)
  const isLastPortee = indexPorteeCourante == Score.nombrePortees ;
  const isLastMesure = this.number == MesureCode.count
  if ( !isLastPortee ) {
    // 
    // <= Ce n'est pas la dernière portée 
    // => On focusse dans la portée suivante (en dessous)
    // 
    this.focus(indexPorteeCourante + 1)

  } else if ( isLastMesure ) {
    // 
    // <= Dernière portée de dernière mesure
    // => On doit créer une nouvelle mesure
    // 
    MesureCode.createNew()

  } else {
    // 
    // <= Dernière portée de non dernière mesure
    // => Focusser dans la première portée de la mesure suivante
    // 
    const nextMesure = MesureCode.table_mesures[this.number]
    nextMesure && nextMesure.focus()
  }
}

/**
 * Méthode appelée quand on quitte une mesure
 * 
 * Lorsqu'on quitte une mesure, on doit :
 */
onBlurMesure(mesure, ev){
  return stopEvent(ev)
}

/**
 * Si le contenu d'une mesure a changé, il faut :
 *    - adapter sa largeur à son contenu (en tenant compte de toutes
 *      les portées de la mesure)
 *    - actualiser la partition (sauf option contraires) si toutes 
 *      les portées de la mesure sont définies 
 * 
 * @param {DOMElement} mesure La mesure en tant qu'objet du DOM
 * 
 */
onChangeMesure(mesure, ev){
  this.setWidth()

  // 
  // Si la mesure est complète (toutes ses portées remplies) on doit
  // actualiser la partition. 
  // Noter qu'il faut le faire après setWidth car c'est setWidth qui
  // définit la valeur the this.complete
  // 
  console.info("Options.auto_update_after_change = ", Options.auto_update_after_change)
  Options.auto_update_after_change && this.isComplete() && App.submitCode()

  return stopEvent(ev)
}

/**
 * Méthode permettant de détruire +nombre+ portées dans la mesure
 * courante (changement de configuration).
 */
removeSystems(nombre){
  var portees = Array.from(this.portees)
  console.log("portées : ", portees)
  for(var i = 0; i < nombre; ++i){ portees.pop().remove() }
  this._nbstaves = null
  delete this._nbstaves
  this._portees = null
  delete this._portees
}

/**
 * @return TRUE Si la mesure est "complète", c'est-à-dire si toutes
 * ses portées contiennent du code.
 * 
 * La méthode est utile pour quand l'option "actualiser après 
 * changement" est activée.
 * 
 */
isComplete(){
  var oui = true
  this.portees.forEach(oportee => {
    if ( !oui ) return // pour accélérer
    if ( oportee.value.trim().length == 0 ){ oui = false }
  })
  console.info("isComplete ?", oui)
  return oui
}
// Nombre de portées réellement affichées
get nombrePortees(){
  return this._nbstaves || (this._nbstaves = this.portees.length)
}
// Les objets DOM de chaque portée
get portees(){
  return this._portees || (this._portees = this.getPortees())
}
getPortees(){
  return DGetAll('.mesure_code', this.obj)
}


/**
 * Pour mettre cette mesure (et ce champ en courant)
 * 
 * Pour bien comprendre : cette mesure-code contient chaque portée
 * du système. Par exemple, elle contient 4 mesures pour un quatuor,
 * donc 4 champs pour entrer les notes.
 * Quand on focusse dans un champ on a donc :
 *    - MesureCode.current      Qui est l'instance mesureCode courante (celle du champ focussé)
 *    - <cette mesure>.current  Qui est le field de la mesure en question (si vraiment c'est nécessaire, à l'avenir, on pourra imaginer faire une instance.
 */
setCurrent(field){
  this.currentField = field
  this.constructor.current = this
}

/**
 * Méthode pour ajouter le texte +text+ au champ courant de cette
 * mesure-code, donc le currentField
 * 
 */
addInCurrentStaff(text){
  var t = this.getCurrentFieldContent().trim()
  this.setCurrentFieldTo(t + ' ' + text)
}
setCurrentFieldTo(txt){
  this.currentField.value = txt
  this.setWidth()
}
getCurrentFieldContent(){
  return this.currentField.value
}


}//class MesureCode
