'use strict';

const ERROR_NO_IMAGE = "Image non définie."
class AppClass {

  /**
   * Pour zoomer ou dézoomer la partition
   */
  zoomIn(){
    this.zoomScore(this.zoom + 5)
  }
  zoomOut(){
    this.zoomScore(this.zoom - 5)
  }
  zoomScore(zoomValue){
    if ( zoomValue < 5 ) {
      return erreur("Valeur de zoom trop petite.")
    }
    document.querySelector('#score').style.zoom = `${zoomValue}%`
    this.zoom = zoomValue
  }
  get zoom(){return this._zoom || 100 }
  set zoom(v) {
    this._zoom = v
    document.querySelector('#zoom_value').innerHTML = `${v} %`
  }

  /**
   * Pour demander au serveur le chemin de la partition à découper
   * 
   * La méthode est appelée pour faire la demande (data = undefined)
   * et pour la recevoir du serveur avec le chemin dans data
   */
  askForScore(waadata){
    if ( undefined == waadata ) {
      WAA.send({class:'ScoreCutting::App', method:'get_score_path'})
    } else if ( waadata.ok ) {
      UI.setNumberOfFirstSystem(waadata.next_system_number)
      this.load_image(waadata.path)
    } else {
      if ( waadata.error == ERROR_NO_IMAGE ) {
        message(AIDE_UTILISATION)
      } else {
        erreur(waadata.error)
      }
    }
  }

  /**
   * Pour charger l'image de chemin d'accès +path+
   * 
   */
  load_image(path){
    if ( !path || path == ''){
      return erreur("Il faut définir le chemin d'accès en premier argument.")
    } else {
      console.info("Chargement de partition: ", path)
      this.source   = path
      UI.score.src  = path
      UI.score.addEventListener('load', _ => {
        /* -- Partition chargée -- */
        UI.setImageName()
        message(AIDE_DECOUPAGE)
      })
      UI.score.addEventListener('error', function(e){
        alert("Une erreur s'est produite pendant le chargement. Vérifier le chemin d'accès à la partition.")
      })
    }
  }


  /**
  * @api
  * 
  * Méthode appelée par le bouton "Page suivante" qui doit charger
  * la page de partition suivante.
  */
  loadNextPage(){
    WAA.send({class:"ScoreCutting::App", method:"get_other_page", data:{for_next:true, folder:this.score_folder, source:this.score_name}})
  }
  loadPrevPage(){
    WAA.send({class:"ScoreCutting::App", method:"get_other_page", data:{for_next:false, folder:this.score_folder, source:this.score_name}})
  }
  onLoadOtherPage(waadata){
    if (waadata.ok) {
      const other_page = waadata.other_page
      this.reset()
      this.load_image([other_page.folder,other_page.source].join('/'))
    } else {
      erreur(waadata.msg)
    }
  }

  reset(){
    this._folder = null
    this._name   = null
    this.removeMarksEmportePiece()
    this.removeDecoupeLines()
  }

  get score_folder(){
    this._folder || this.getImageFolderAndName()
    return this._folder
  }
  get score_name(){
    this._name || this.getImageFolderAndName()
    return this._name
  }
  getImageFolderAndName() {
    var chemin = this.source.split('/')
    this._name    = chemin.pop()
    this._folder  = chemin.join('/')
  }


  /**
   * Confirmer la découpe
   * 
   * Dans cette méthode, on "surligne" les parties qui vont produire
   * les systèmes (en indiquant leur) pour que l'utilisateur confirme
   * l'opération de découpe
   * 
   */
  confirmeDecoupe(){
    const lignes = UI.getTopsOfLignesCoupe()
    //console.log("Top des lignes : ", lignes)
    if ( lignes.length == 0 ) return error("Il faut placer au moins 2 lignes de découpe !");
    // Il faut qu'il y ait un nombre paire
    if ( 0 != ((lignes.length / 2) % 1)) {
      return error("Il doit obligatoirement y avoir un nombre paire de lignes (la ligne de début et la ligne de fin de chaque partie.");
    }

    /*
     * On relève les paires de lignes de découpe, mais ici
     * seulement pour un aperçu.
     */
    let div;
    let data = {};
    let isysteme = UI.getNumberOfFirstSystem() - 1
    for (var i = 0; i < lignes.length ; i += 2){
      data.top    = lignes[i]
      data.bas    = lignes[1 + i]
      data.height = data.bas - data.top
      div = document.createElement('DIV')
      div.className = 'emporte_piece'
      div.style.top = px(data.top)
      div.style.height = px(data.height)
      document.body.appendChild(div)
      let span = document.createElement('SPAN')
      span.className = 'file_name'
      span.innerHTML = `systeme-${++isysteme}.jpg`
      div.appendChild(span)
    }

    // afficher le bouton pour confirmer
    UI.showBoutonsConfirmation()

  }

  /**
  * Une fois la découpe faite (dans l’image réelle), on peut supprimer les
  * lignes de coupe
  */
  removeDecoupeLines(){
    document.body.querySelectorAll('.ligne_coupe').forEach(div => div.remove())
  }
  removeMarksEmportePiece(){
    document.body.querySelectorAll('.emporte_piece').forEach(div => div.remove())
  }

  /**
   * Pour renoncer à la découpe et ré-ajuster les lignes
   */
  renoncerDecoupe(){
    UI.hideBoutonsConfirmation()
    this.removeDecoupeLines()
    this.removeMarksEmportePiece()
  }

  /**
   * 
   * Pour produire les lignes de coupe et le code
   * 
   */
  buildCodeDecoupe(confirmed){
    if ( ! confirmed ){ return this.confirmeDecoupe()}
    UI.showAction("Découpe des images en cours. Merci de patienter…")
    UI.hideBoutonsConfirmation()
    const lignes = UI.getTopsOfLignesCoupe()
    //console.log(lignes)
    var codes = []
    let isysteme = UI.getNumberOfFirstSystem() - 1
    var data = {
        source: this.score_name
      , folder: this.score_folder
    }
    /*
     * Relève de toutes les valeurs de découpe
     *
     * (on doit tenir compte du zoom)
     */
    const zo = 100 / this.zoom ;
    // console.info("zo = ", zo)
    for (var i = 0; i < lignes.length ; i += 2){
      // data.top    = parseInt(lignes[i] * zo, 10)
      // data.bas    = parseInt(lignes[1 + i] * zo, 10)
      data.top    = lignes[i] * zo
      data.bas    = lignes[1 + i] * zo
      data.height = data.bas - data.top
      data.dest   = `system-${++isysteme}.jpg`
      var code = "" + TEMP_CODE_DECOUPE
      ;['folder','source','height','top','dest'].forEach(prop => {
        var regexp = new RegExp(`__${prop.toUpperCase()}__`)
        code = code.replace(regexp, data[prop])
      })
      codes.push(code)
    }
    // - On règle le numéro nature du prochain système -
    UI.setNumberOfFirstSystem(1 + isysteme)
    codes = codes.join(";") + ' 2>&1'
    UI.codeField.value = codes

    WAA.send({class:"ScoreCutting::App", method:"run_bash_code", data:{folder:this.score_folder, source:this.score_name, code: codes}})
  }

  onCutScore(data){
    if ( data.ok ) {
      message(CONFIRMATION_DECOUPE_EFFECTUED.replace(/__FOLDER__/, this.score_folder))
    } else {
      erreur(data.error)
    }
  }

}
const App = new AppClass()

const AIDE_UTILISATION = `
<p><b>Utilisation de Score Cutting</b></p>
<p>Pour utiliser ScoreCutting, vous devez :</p>
<ul>
<li>produire une image (jpg, png, tiff) de la partition à découper,</li>
<li>ouvrir un Terminal au dossier qui la contient,</li>
<li>puis jouer la commande <code>score-cutting</code>.</li>
</ul>
`

const AIDE_DECOUPAGE = `
<p>La partition est chargée !</p>
<p>Double-cliquez aux endroits où vous voulez placer des lignes de coupe. Il doit obligatoirement y en avoir deux par système.</p>
<p>Enfin, cliquez sur le bouton « Découper » pour vérifier et procéder à la découpe après confirmation.</p>
`

// Si requête ajax : /opt/homebrew/bin/convert
// const TEMP_CODE_DECOUPE = '/opt/homebrew/bin/magick /Users/philippeperret/Sites/ScoreCutting/__SOURCE__ -crop 0x__HEIGHT__+0+__TOP__ ./__DEST__ 2>&1'
const TEMP_CODE_DECOUPE = 'cd "__FOLDER__" && /opt/homebrew/bin/magick ./__SOURCE__ -crop 0x__HEIGHT__+0+__TOP__ ./systems/__DEST__'
