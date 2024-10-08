"use strict";

class Score {
  static get current(){return this._current}
  static set current(score) {this._current = score}

  /**
  * = main =
  * 
  * @api
  * 
  * Méthode principale appelée pour charger le score dont les données
  * sont +scoreData+
  * 
  * @note
  *   Cette méthode est appelée :
  *     - quand on drag & drop un système sur la fenêtre
  *     - quand on demande à passer au système suivant et qu’un
  *       système a été trouvé
  */
  static display(scoreData){
    UI.imager.innerHTML = '<img id="system" src="">'
    const score = new Score(scoreData)
    UI.score = score
    score.isValid()
      .then(score.display_and_wait.bind(score))
      .catch(err => {
        this.current = null
        this.afterDisplay()
        erreur(err)
      })
  }
  
  static afterDisplay(){
    UI.setBoutonNextName()    
  }

  static prepare(){
    this.nextNumField.value = 1
  }

  static nextNumero(){
    let nextNum = parseInt(this.nextNumField.value,10)
    if (isNaN(nextNum)) nextNum = 1
    this.nextNumField.value = 1 + nextNum
    return nextNum
  }
  static currentNumero(){
    return this.nextNumField.value;
  }

  static get nextNumField(){return DGet("#next-numero")}


  static alignAllNumbers(ev){
    if ( ! this.current ) {
      return erreur("Il faut ouvrir une partition à numéroter.")
    }
    this.current.alignAllNumeros(ev.metaKey)
  }


  constructor(data){
    this.data = data
    // console.log("Data :", this.data)
    Score.current = this
    this.numeros = []
  }

  /**
  * Une fois que la validité du fichier envoyé à été contrôlée,
  * on l’affiche pour pouvoir le tagguer.
  */
  display_and_wait(){
    UI.hideDropper()
    UI.showImager()
    this.field.src = `system.jpg?${this.file.name}`
    UI.imageName = this.file.name
    Score.afterDisplay()
    message(`Double-cliquer à l’endroit voulu pour placer le numéro ${Score.currentNumero()}.`)
  }


  /**
  * Méthode appelée pour ajouter un numéro de mesure à data.x et
  * data.y
  */
  addMesureAt(data){
    // Rectification
    data.y = data.y - 40
    // Le numéro
    const numero = Score.nextNumero()
    var obj = DCreate("DIV", {
      text: numero, 
      "data-numero": numero,
      "data-x": data.x,
      "data-y": data.y,
      class:"numero-mesure", 
      style:this.mesureStyle(data)
    })
    UI.imager.appendChild(obj)
    // Après avoir inscrit le numéro, on rectifie pour que son centre
    // soit bien au clic de souris
    this.rectifPositionMesure(obj)
    // On doit pouvoir déplacer le numéro
    $(obj).draggable()
    this.numeros.push(obj) // plus tard, une instance
  }

  rectifPositionMesure(mes){
    const rectifH = mes.offsetHeight / 2
    const rectifW = mes.offsetWidth / 2
    const newTop  = mes.offsetTop - rectifH
    const newLeft = mes.offsetLeft - rectifW
    // console.info("mes.offsetTop = %s - Rectif = %s - New top = %s", mes.offsetTop, rectifH, newTop)
    mes.style.top   = px(newTop)
    mes.style.left  = px(newLeft)
    mes.dataset.x = newLeft
    mes.dataset.y = newTop
  }


  /**
  * Appelé par le bouton pour graver les numéros sur la partition
  */
  printNumbers(){
    // On prépare la donnée
    var dataNumbers = []
    this.numeros.forEach(numero => {
      dataNumbers.push({
          numero:   numero.dataset.numero
        , x:        numero.offsetLeft
        , y:        numero.offsetTop + 19 + UI.verticalAdjustment
      })
    })
    WAA.send({class:"ScoreNumbering::Score", method:"print_numbers", data:{filename:this.file.name, numbers:dataNumbers, style:{fonte:Styler.getFontFamily(), size:Styler.getFontSize(), color:Styler.getFontColor()}}})
  }
  onNumbersPrinted(waaData){
    if (waaData.ok){
      message("Les numéros ont été imprimés avec succès.")
    } else {
      erreur(waaData.msg)
    }
  }

  /**
  * Méthode qui va aligner les numéros
  * 
  * Fonctionnement : on commence par grouper les numéros d’une même
  * ligne. Ensuite, on prend le plus haut (le plus petit) et on
  * aligne tous les numéros du groupe dessus.
  * 
  * Si on tient la touche META en cliquant sur le bouton, on force
  * l’alignement par le bas.
  */
  alignAllNumeros(alignOnBottom){
    const tolerance = Math.round(UI.alignTolerance / 2)
    /**
    * TEMPS 1 : Grouper les numéros par proximité
    */
    const groupes = []
    let groupHasNotBeenFound = true;
    this.numeros.forEach(numero => {
      const numTop = numero.offsetTop
      if ( groupes.length ) {
        groupHasNotBeenFound = true
        groupes.forEach( groupe => {
          if ( numTop >= groupe.min && numTop <= groupe.max ) {
            groupe.numeros.push(numero)
            groupHasNotBeenFound = false
          }
        })
      } else {
        // Au tout début, on crée un groupe avec ce numéro
        groupHasNotBeenFound = true
      }
      if ( groupHasNotBeenFound ) {
        let top = numero.offsetTop
        groupes.push({numeros: [numero], top: top, min: top-tolerance, max: top+tolerance })
      }
    })
    // console.log("groupes = ", groupes)
    /**
    * TEMPS 2 : Rechercher dans chaque groupe le numéro le plus haut
    *           (ou le plus bas si alignOnBottom) et en tirer la 
    *           valeur top valide
    */
    groupes.forEach(groupe => {
      groupe.numeros.forEach( numero => {
        const ntop = numero.offsetTop
        const cond = alignOnBottom ? ntop > groupe.top : ntop < groupe.top;
        if ( cond ) groupe.top = ntop
      })
    })
    /**
    * TEMPS 3 : Alignement de tous les numéros du groupe sur le top
    *           défini pour ce groupe
    */  
    groupes.forEach(groupe => {
      const top_px = px(groupe.top)
      groupe.numeros.forEach( numero => {
        numero.style.top  = top_px
        numero.dataset.y  = groupe.top
        // console.log("Numéro mis à %s", top_px, numero)
      } )
    })

    message("Tous les numéros ont été alignés sur le plus haut.")
  }


  // @return Le style du numéro
  mesureStyle(data){
    var styles = []
    styles.push(`top:${data.y}px`)
    styles.push(`left:${data.x}px`)
    styles.push(`font-family:${Styler.getFontFamily()}`)
    styles.push(`font-size:${Styler.getFontSize()}px`)
    styles.push(`color:${Styler.getFontColor()}`)
    return styles.join(";")
  }

  // Pour modifier le style de tous les numéros
  setEachNumero(property, value) {
    this.numeros.forEach(numero => {
      numero.style[property] = value
    })
  }

  /**
  * @return True si le fichier draggué est bien une image. Dans le
  * cas contraire, affiche un message d’erreur et renvoie false
  * 
  * On vérifie aussi que ce soit bien une image du dossier où on
  * se trouve.
  */
  isValid(){
    return new Promise((ok, ko) => {
      this.okExist = ok
      this.koExist = ko
      if ( this.type != "image/jpeg" ) {
        ko(`Le type de l’image glissée doit être JPEG (image/jpeg). Le type courant est ${this.type}…`)
      } else {
        this.checkIfImageExist()
      }
      return true
    })
  }

  checkIfImageExist(){
    message("Vérification de l’existence de l’image…")
    WAA.send({class:"ScoreNumbering::Score", method:"check_existence", data:{name:this.file.name}})
  }
  imageExists(waaData){
    if (waaData.ok) {
      message("L’image existe bien.")
      this.okExist()
    } else {
      message("")
      this.koExist(waaData.msg) 
    }
  }

  get field(){
    return DGet("#system", UI.imager)
  }
  get system(){return this.field}

  get type(){
    return this.item.type
  }
  // En temps que fichier
  get file(){return this.data.file || this.data.files[0]}
  // En temps qu’item transféré
  get item(){return this.data.item || this.data.items[0]}
}
