class UIClass {

  /**
   * Pour activer les raccourcis courants (utilisés au cours de 
   * l'analyse en elle-même)
   * 
   */
  reactiveCurrentShortcuts(){
    // console.info("-> activation des raccourcis d'analyse")
    window.onkeyup    = onKeyUpOnAnalyse.bind(null)
    window.onkeydown  = onKeyDownOnAnalyse.bind(null)
    window.onkeypress = onKeypressOnAnalyse.bind(null)
  }
  /**
   * Pour désactiver les raccourcis courants (par exemple lorsqu'on
   * ouvre un panneau, comme le panneau des données de l'analyse)
   * 
   */
  desactiveCurrentShortcuts(){
    // console.info("-> désactivation des raccourcis d'analyse")
    window.onkeyup    = null
    window.onkeydown  = onKeyDownUniversel
    window.onkeypress = null
  }

  /**
   * Pour modifier un texte
   * 
   */
  editer(str){
    this.editeur.value = str
    return this.editeur.newValue;
  }

  get editeur(){
    return this._editor || (this._editor = new Editeur())
  }

  /**
   * Préparation de l'interface en début de session
   * 
   */
  setInterface(){

    Preferences.init()

    // Le menu du pied de page
    SelectionTool.init()

    // Le menu "Bords" du pied de page
    BordersTool.init()
        
    const hauteurFen  = window.innerHeight
    const moitieFen   = parseInt(hauteurFen / 2,10)


    this.TableAnalyse.onfocus = (e) => {
      this.TableAnalyse.style.border = "2px solid blue"
    }
    this.TableAnalyse.focus()

    // Observation des éléments de l'interface
    //
    this.observe()

    /**
     * Activation des raccourcis clavier
     */
    UI.reactiveCurrentShortcuts()

    AObjet.resetSelection()
  }

  observe(){
    listen(window, 'dblclick', this.onDoubleClick.bind(this))
    // listen(this.TableAnalyse, 'click', (e)=>{/*console.log("Un clic sur la table d'analyse.")*/})

    listen(this.btnLockSystems, 'click', Systeme.toggleLock.bind(Systeme))
    listen(this.btnSaveAnalyse, 'click', AnalyseSaver.save.bind(AnalyseSaver))
  
    listen(DGet('#outil_alignement'), 'change', AMark.alignerSelection.bind(AMark))
    
    listen(DGet('footer'), 'click', function(e){return stopEvent(e)})

    // Pour gérer les sélections
    TableAnalyse.observe()

  }

  onDoubleClick(e){

    // On crée un nouvel élément
    AMark.createNew.call(AMark, e)

    return stopEvent(e)
  }

  /**
   * La lumière rouge/verte d'état d'enregistrement
   * 
   */
  eteinsRedLight(){
    this.btnSaveAnalyse.classList.remove('actived')
    this.redLight.classList.remove('red')
  }
  allumeRedLight(){
    this.btnSaveAnalyse.classList.add('actived')
    this.redLight.classList.add('red')
  }
  get redLight(){
    return this._redlight || (this._redlight = DGet('#red-light'))
  }


  /**
   * Méthode qui déplace tous les objets se situant en dessous de
   * +fromTop+ d'un montant de +dec+ pixels (+dec+ peut être négatif)
   * sauf l'objet d'identifiant +saufId+
   * 
   * Cette méthode est utilisée quand on déplace les systèmes
   */
  moveAllObjetUnder(fromTop, dec, saufId){
    console.log("Déplacer à partir de %i pour %i pixels", fromTop, dec)
    document.querySelectorAll('.aobj').forEach(obj => {
      console.log("Objet", obj, obj.offsetTop)
      if ( obj.offsetTop < fromTop || obj.id == saufId) return
      obj.style.top = px(obj.offsetTop + dec)
    })
  }

  get PanneauMetadata(){
    return this._panometadata || (this._panometadata = new Panneau('panneau_infos'))
  }

  // Le picto pour verrouiller les systèmes
  get btnLockSystems(){return this._btnlocksys || (this._btnlocksys = DGet('footer #cb_staves_lock'))}
  // Le picto pour activer l'enregistrement
  get btnSaveAnalyse(){return this._btnrecord || (this._btnrecord = DGet('footer #cb_recording'))}

  get panneauStave(){
    return this._stavepanel || (this._stavepanel = DGet('iframe#staves2'))
  }
  get TableAnalyse(){
    return this._tableana || (this._tableana = DGet('body section#content'))
  }
}
const UI = new UIClass()
