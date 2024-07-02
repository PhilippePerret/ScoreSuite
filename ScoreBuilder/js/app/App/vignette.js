'use strict';


const MINIATURE_WIDTH   = 60
const MINIATURE_GUTTER  = 10

class Vignette {

  constructor(owner, options){
    this.owner = owner
    this.options = options
  }

  build(){
    const vig = DCreate('DIV',{class:"vignette"})
    vig.style.width = px(MINIATURE_WIDTH)
    vig.style.marginLeft = px(MINIATURE_GUTTER)
    vig.appendChild(DCreate('IMG'),{src: ""})
    this.owner.vignettesContainer.appendChild(vig)
    this.obj = vig
    this.watch()
  }

  watch(){
    if ( this.options.droppable ) {      
      listen(this.obj, "drop",      this.onDrop.bind(this))
      listen(this.obj, "dragover",  this.onDragOver.bind(this))
      listen(this.obj, "dragleave",   this.onDragOut.bind(this))
    }
  }

  display(){
    this.img.src = this.file.name
    if ( ! this.watched ) {
      listen(this.obj,'click', this.onClick.bind(this))
      this.addCss('clickable')
      this.watched = true
    }
  }
  // Pour ne plus écouter le click sur la vignette
  unlisten(){
    if ( this.watched ) {
      unlisten(this.obj,'click', this.onClick.bind(this))
      this.watched = false
    }
  }

  // @api
  // Pour définir l’image de la vignette
  set image(imgPath){
    console.log("Image path mis à ", imgPath)
    this.file = {name: imgPath}
    this.display()
  }

  /**
  * @api
  * Méthode permettant de supprimer l’image qui est peut-être dans
  * le champs
  */
  unsetImage(){
    this.file = {name: ""}
    this.display()
    this.unlisten()
  }

  onClick(ev){
    stopEvent(ev)
    this.owner.imgCurrentPage.src = this.file.name
    return false
  }

  // Quand on lâche une image dessus
  onDrop(ev){
    stopEvent(ev)
    this.data = ev.dataTransfer
    this.display()
    /**
    * TODO Faire quelque chose de beaucoup plus important pour
    * faciliter le travail : si l’image possède un indice, on doit
    * chercher sur le disque si d’autres images existent (la suite
    * de la partition) et les charger automatiquement à la suite
    * de cette image. De cette manière, il suffira de glisser une
    * image de la partition pour les charger toutes d’un coup.
    * (ci-dessus, c’est seulement quand le propriétaire est la
    * partition)
    */
    console.warn("LIRE LE TODO.")
    return false
  }
  // Quand on passe au-dessus de la vignette avec un fichier
  onDragOver(ev){
    // TODO Ne le faire que si l’extension est valide
    stopEvent(ev)
    ev.dataTransfer.dropEffect = "move";
    this.addCss("dropped")
  }
  // Quand on sort du survol de la vignette
  onDragOut(ev){
    // TODO Ne le faire que si l’extension est valide
    ev.dataTransfer.dropEffect = "stop";
    this.remCss("dropped")
    stopEvent(ev)
  }

  addCss(cssName){
    this.obj.classList.add(cssName)
  }
  remCss(cssName){
    this.obj.classList.remove(cssName)
  }

  get img(){
    return this._img || ( this._img = DGet('img', this.obj))
  }

  get file(){
    return this._file || (this._file = this.data.file || this.data.files[0])
  }
  set file(v) {
    this._file = v
  }
}
