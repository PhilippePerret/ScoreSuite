'use strict';
/**
 * Pour gérer l'analyse en tant que telle
 * Principalement pour les échanges avec le serveur, puisque ce 
 * module a été initié quand on est passé à la version WAA de l'app
 * 
 * NOTE : les méthodes de classe sont placées après les méthodes
 *        d'instance.
 * 
 */
class Analyse {


  static setModified(){
    /** Pour avoir à seulement utiliser Analyse.setModified() **/
    this.current && this.current.setModified()
  }

  constructor(data){
    this.data = data;
  }

  get modified(){ return this._modified }
  set modified(v){
    if ( this.loading ) return ;
    this._modified = v
    if (v) {
      UI.allumeRedLight()
    } else {
      UI.eteinsRedLight()
    }
  }
  setModified(){this.modified = true}
  unsetModified(){this.modified = false}


  defineWindowSize(largeur, hauteur){
    /**
     ** Méthode appelée quand on change la taille de la fenêtre, pour
     ** pouvoir l'enregistrer. 
     **/
    Preferences.set('window_width'  , largeur)
    Preferences.set('window_height' , hauteur)
    this.setModified()
  }

  scrollToLastPosition(){
    window.scrollTo({top:pref('last_scroll') || 0})
  }

  /**
   * Retourne un nouvel identifiant unique
   * 
   */
  newId(){
    if (undefined == this._lastId) this._lastId = 0;
    return ++ this._lastId
  }

  /**
   * Pour afficher une analyse
   * 
   * Note : ça la met en analyse courante
   */
  display(){
    this.loading = true
    Analyse.current = this
    /*
    |  Affichage de l'analyse
    */
    if ( false == AnalyseDisplayer.display(this) ) {
      Analyse.current = null
    } else {
      Systeme.setLockSystemsOnLoad()
      TableAnalyse.setHeight()
      /*
      |  Si on veut jouer du code après l'affichage de l'analyse
      */
      runAfterLoadingAndDisplayingAnalyse()
    }
    this.loading = false
    return this; // chainage
  }



/* --- Color Methods --- */

/**
* Méthode qui bascule de la version couleur à la version noir et 
* blanc de l'affichage de l'analyse.
*/
toggleModeColor(modeON){
  if ( modeON && not(DGet('style#mode_couleur')) ) {
    this.buildStyleTagForModeColor()
  }
  DGet('style#mode_couleur').disabled = !modeON
}
/**
* Construire la balise <style> pour le mode couleur
*/
buildStyleTagForModeColor(){
  var styles = []
  Object.values(PreferencesAppData).forEach(dp =>{
    if ( dp.typeV != 'color' ) return
    var color = Preferences.get(dp.id)
    styles.push(`${dp.selectors} {border-color:#${color}!important;color:#${color}!important;}`)
  })
  styles = "\n/* Ce code est produit automatiquement en fonction des préférences */\n" + 
    styles.join("\n") + "\n"
  const tag = DCreate('STYLE', {id:'mode_couleur', type:'text/css', text: styles})
  console.debug("tag =", tag)
  document.head.appendChild(tag)
}

/* --- Staff Methods --- */

/**
 * Méthode qui compare les images systèmes du dossier 
 * (this.data.systems_in_folder) avec les systèmes définis pour le
 * moment dans l'analyse et tient compte des changements.
 * 
 */
checkSystems(){
  const imgSystems = this.data.systems_in_folder
  // console.log("imgSystems = ", imgSystems)
  // console.log("Systèmes courants = ", this.systems)
  const nombreSystemesInitial = Object.keys(this.systems).length
  /*
  * Table de comparaison
  * --------------------
  * Par commodité, on fait une table des systèmes courant avec en
  * clé le nom de l'image et en valeur l'instance, qui servira tout
  * à la fin.
  */
  const table_systems = {}
  this.systems.forEach(sys => {
    Object.assign(table_systems, {[sys.data.image_name]: sys})
  })
  // console.log("table_systems = ", table_systems)
  /*
  * On peut vérifier maintenant la concordance (systèmes ajoutés et
  * systèmes retirés)
  */
  const unknownSystemsNames = []
  imgSystems.forEach( sys_img_name => {
    if ( undefined == table_systems[sys_img_name] ) {
      // <= C'est un nouveau système
      // => On le met dans la liste des inconnus
      unknownSystemsNames.push(sys_img_name)
    } else {
      // <= C'est un système connu
      // => On le retire de la table de comparaison
      delete table_systems[sys_img_name]
    }
  })
  /*
  * Conclusion à tirer :
  *   - les systèmes de unknownSystemsNames sont à ajouter
  *   - les systèmes qui reste dans table_systems sont à retirer
  *   - s'il n'y a aucune différence, on peut s'arrêter là
  */
  const nombreSystemesARetirer = Object.keys(table_systems).length
  if (unknownSystemsNames.length + nombreSystemesARetirer == 0) {
    return console.info("= Le nombre de systèmes n'a pas changé.")
  }
  if (unknownSystemsNames.length) {
    console.info("Nombre de systèmes à ajouter : %i", unknownSystemsNames.length)
  }
  if (nombreSystemesARetirer) {
    console.info("Nombre de systèmes à retirer : %i", nombreSystemesARetirer)
    Object.values(table_systems).forEach( sys => {
      delete this.systems[sys.index - 1]
    })
  }
  /*
  * Il faut ajouter les systèmes nouveaux aux bons endroits. Pour ça,
  * on se sert de la liste des noms de systèmes dans le dossier, qui
  * est classée par ordre alphabétique.
  * On en profite en même temps pour créer les nouvelles instances.
  */
  const newSystems = []
  var last_top = 0
  imgSystems.forEach(img_name => {
    if ( table_systems[img_name] ) {
      // <= Un système qui existe déjà
      // => On l'ajoute tel quel
      newSystems.push(table_systems[img_name])
    } else {
      // <= Un nouveau système
      // => On lui crée une nouvelle instance
      const newSystem = new Systeme(this, {
          image_name: img_name
        , top:  last_top + 100
        , left: 0
      })
      newSystems.push(newSystem)
    }
    last_top = newSystems[newSystems.length - 1].top
  })
  this.systems = newSystems
  console.info("Nouvelle valeur systems : ", this.systems)

  this.setModified()
}

  /**
   * Les méthodes de sauvegarde
   */
  saveInfos(){        AnalyseSaver.saveInfos(this)}
  savePreferences(){  AnalyseSaver.savePreferences(this)}
  saveAnalyseTags(){  AnalyseSaver.saveAnalyseTags(this)}

  checkDataBeforeSave(){
    /**
     ** Méthode qui fait quelques vérification avant de procéder à
     ** l'enregistrement des données.
     ** @return true en cas de succès, false otherwise
     **/
      AObjet.items.forEach(o => {
        try {
          if ( o.type == 'systeme' ) {
            /*
            |  Check des systèmes
            */
          } else {
            /*
            |  Check des marques d'analyse
            */
            o.data.top  || o.corrigeDataValue('top')
            o.data.left || o.corrigeDataValue('left')
            o.data.top          || raise("Le top de l'objet n'est pas défini.")
            o.data.left         || raise("Le left ne l'objet n'est pas défini.")
            isNaN(o.data.top)   && raise("Le top devrait être un nombre.")
            isNaN(o.data.left)  && raise("Le left de l'objet devrait être un nombre")
          }
        } catch(err) {
          console.error("Objet erroné : ", o)
          raise(err)
        }
      })

    return true
  }
  /**
   * Pour actualiser une donnée général (métadonnée, data)
   * 
   */
  updateInfos(data){
    Object.assign(this.data.infos, data)
  }

  /**
   * Rafraichir l'affichage de l'analyse
   * 
   * Cela consiste à relever les systèmes et à les afficher
   * 
   * Méthode qui fonctionne en 2 temps : premier temps, quand +data+
   * est indéfini (premier appel) on demande au serveur de relever
   * les images des systèmes. 2e temps, on revient dans la méthode
   * avec les images dans +data+ (qui contient :analyse_path et :systems, la
   * liste des noms des images). On peut comparer avec les systèmes 
   * qu'on connait déjà.
   */
  refresh(data){
    if (undefined == data){
      WAA.send({
          class:  'ScoreAnalyse::Analyse'
        , method: 'refresh'
        , data:   {analyse_path: this.path}
      })
    } else {
      this.refreshSystems(data.systems)
    }
  }

  /**
   * Méthode qui rafraichit la liste des systèmes
   * 
   * Elle est principalement appelée lorsqu'on a créé une nouvelle
   * analyse et qu'on a mis les systèmes dans le dossier système.
   * Dans ce cas, il faut les fabriquer.
   * 
   * Mais on prévoit aussi des ajouts où des suppressions.
   * 
   * 
   * Maintenant, la donnée data_systems est plus complète, puisqu'elle
   * a été traitée par ruby côté serveur. Peut-être faut-il simplement
   * tout initialiser.
   */
  refreshSystems(data_systems){
    console.info('OPE: Rafraichissement des systèmes…')
    // console.log("Nouvelles données systèmes : ", data_systems)
    const tableNewSystems = {}
    data_systems.forEach(dsys => {
      Object.assign(tableNewSystems, {[dsys.image_name]: dsys})
    })
    const currentSystems = Systeme.getData()
    // console.log("Données systèmes actuels : ", currentSystems)
    const tableOldSystems = {}
    currentSystems.forEach(dsys => {
      Object.assign(tableOldSystems, {[dsys.image_name]: dsys})
    })

    // Dernier système et hauteur courante
    ecart = Preferences.get('distance_systemes')
    if ( Systeme.last ) {
      currentTop = Systeme.last.bottom + ecart
    } else {
      currentTop = Preferences.get('top_first_system')
    }

    /**
     * Ajout des nouveaux systèmes 
     */
    var newSystemsCount = 0
    data_systems.forEach( dsys => {
      if ( undefined == tableOldSystems[dsys.image_name] ) {
        // Un nouveau système
        const sys = new Systeme(this, dsys)
        sys.build()
        sys.top = currentTop
        currentTop = sys.full_height + ecart
        Object.assign(tableOldSystems, {[dsys.image_name]: dsys})
        newSystemsCount ++
      }
    })

    console.info("OPE: Fin de construction des nouveaux systèmes. Nouveaux systèmes construits : %i", newSystemsCount)
  }

  /**
   * @return les instances système des systèmes de l'analyse
   */
  get systems(){
    if (undefined == this._systems){
      AObjet.items || AObjet.init() // indispensable pour instanciation
      var index   = 0
      this._systems = this.data.systems.map(dsys => {
        Object.assign(dsys, {index: ++index})
        return new Systeme(this, dsys) 
      })
    }; return this._systems
  }
  set systems(v){ this._systems = v }

  /**
   * @return La liste des instances de tags
   */
  get tags(){
    const my = this
    my._lastId = 0
    if (undefined == this._tags) {
      AObjet.items || AObjet.init() // indispensable pour instanciation
      const idchecker = {}
      var erreurDoublons = false
      
      /*
       * *** Boucle sur toutes les marques ***
       */
      this._tags = this.data.analyse_tags.map(dtag => {

        /*
         * --- Contrôle des doublons d'ID ---
         */
        if ( undefined == idchecker[dtag.id] ) {
          Object.assign( idchecker, {[dtag.id]: true} )

          // Mémorisation du dernier ID (pour en affecter des 
          // nouveaux à chaque fois)
          if ( dtag.id > my._lastId ) { my._lastId = 0 + dtag.id }

        } else {
          erreurDoublons = true
          console.error("Double utilisation de l'ID %i :", dtag.id, dtag)
        }

        /*
         * --- L'instance à retourner ---
         */
        if ( dtag.type == 'img' ) {
          return new AMImage(this, dtag)
        } else {
          return new AMark(this, dtag)
        }
      })
      if ( erreurDoublons ) {
        erreur("Des doubles d'identifiants ont été trouvés. Il serait plus prudent de les corriger (en éditant le fichier analyse_tags.yaml) et de recharger l'analyse. Les IDs sont indiqués en console.")
      }
      console.info("_lastId (après chargement) = ", this._lastId)
      // console.log("Tags instanciées :", this._tags)
    }; return this._tags;
  }

  get infos(){
    return this.data.infos
  }

  get preferences(){
    return this.data.preferences
  }

  get analyse_title(){
    return this.infos.analyse_title
  }

  get id(){return this.infos.analyse_id}

  /**
   * @return le chemin d'accès à l'analyse (son dossier)
   */
  get path(){
    return this._path || (this._path = this.data.path)
  }


/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

  /**
   * Pour créer une nouvelle analyse
   * -------------------------------
   * (à partir des données de la fenêtre)
   */
  static createNew(){

    var data = this.panneau_infos.getData()
    console.info("Données pour la création de l'analyse", data)
    
    if ( this.dataAreValide(data) ) {
      this.hidePanneauInfos()
    } else {
      return
    }

    // 
    // Création de la nouvelle analyse
    // 
    WAA.send({
        class: 'ScoreAnalyse::Analyse'
      , method:'create_new_analyse'
      , data:   data
    })
    // Note : la suite se fera dans onCreate
  }

/* --- Export Methods --- */

static exportCurrentToHtml(){
  if ( not(this.current) ) {
    return erreur("Il n'y a pas d'analyse courante à exporter !")
  }
  message("Exportation de l'analyse au format HTML. Patienter…")
  const code = DGet('section#content').outerHTML
  WAA.send({
      class:  'ScoreAnalyse::Analyse'
    , method: 'exportToHTML'
    , data:   {code_html: code, path:this.current.path }
  })
}
static onExportedCurrentToHtml(data){
  if (data.ok) {
    message("L'analyse a été exportée dans " + data.path)
  } else {
    erreur("L'analyse n'a pas pu être exportée : ", data.error)
  }
}

  static exportImage(){
    if ( ! this.current ) {
      return erreur("Il faut d'abord choisir l'analyse.")
    }
    WAA.send({
      class:  'ScoreAnalyse::Analyse',
      method: 'output_image',
      data:   this.getDataForExportImage()
    })
  }
  // Retour de la méthode précédente
  static onExportedImage(data){
    if (data.ok){
      message("Les images de l'analyse ont été produites (dans le dossier 'export' de l'analyse).")
    } else {
      erreur(data.error)
    }
  }

  static getDataForExportImage(){
    return {
        path:   this.current.path
      , one_image_per_system: DGet('#export_one_image_per_system').checked
      , systems: DGet('#systems_to_export').value
      , systemsData: this.getSystemesData()
    }
  }

  /**
   * @return Les données par système (table avec l'identifiant-index
   *         du système en clé), c'est-à-dire leur position ainsi
   *          que les données utiles de tous leurs éléments associés
   * 
   * Note : ces données servent pour l'exportation de l'image (qui 
   * sera construite ave RMagick côté serveur).
   * 
   */
  static getSystemesData(){
    const systemesData = {}
    Systeme.each(sys => {
      if ( sys.height < 100 ) {
        delete sys._height
      }
      // console.log("sys.height = %i", sys.height, sys.obj.offsetHeight)
      const dsystem = {id: sys.index, real_top:sys.real_top, top: sys.top, height:sys.height, width:sys.width, full_height:sys.full_height, marks: []}
      // Tous les objets du système
      sys.objets.forEach( ao => {
        const dao = {
          content:ao.content, 
          type:ao.type, 
          top:ao.top, 
          left:ao.left, 
          width:ao.width, 
          height:ao.height,
          prolong: ao.prolong
        }
        dsystem.marks.push(dao)
      })
      Object.assign(systemesData, {[sys.index]: dsystem})
    })
    return systemesData;
  }

  /**
   * Pour produire l'image SVG (ou les images) de l'analyse
   * avec les options choisies
   * OBSOLÈTE (pas réussi à le faire fonctionner correctement)
   */
  static exportToSvg(){
    if ( this.current ) {
      message("J'exporte l'analyse en SVG…")
      /*
       * On récupère des informations sur les placements
       # (note : pour le moment, on prend tout, ça n'est pas
       *  conséquent)
       */
      const systemesData = this.getSystemesData()
      WAA.send({
        class:  'ScoreAnalyse::Analyse',
        method: 'output_svg',
        data:   this.getDataForExportImage()
      })
    } else {
      erreur("Il faut d'abord ouvrir une analyse !")
    }
  }
  static onExportedToSvg(data){
    if (data.ok){
      message("Les images SVG de l'analyse ont été produites (dans le dossier 'svg' de l'analyse).")
    } else {
      erreur(data.error)
    }
  }

  /**
   * Méthode appelée par le serveur pour le rafraichissement des
   * systèmes (quand les images des systèmes ont été modifiés)
   */
  static refreshCurrent(data){
    this.current.refresh(data)
  }

  /**
   * Méthode appelée par le serveur quand on vient de créer la
   * nouvelle application.
   */
  static onCreate(data){
    // 
    // On affiche la nouvelle analyse vide
    // 
    var analyse = new Analyse(data)
    analyse.display()

    // 
    // Message indiquant la suite de la démarche
    // 
    message(
        "J'ai ouvert le dossier de la nouvelle analyse sur le Finder.<br/><br/>Tu peux l'affiner, mettre les images des systèmes (dossier 'systems') et le déplacer à l'endroit désiré (n'oublie pas de la recharger si c'est le cas).<br/>Une fois que ce sera effectuée, clique sur “Charger l'analyse”."
      , {keep:true})
  }

  static onErrorCreate(data){
    console.info("Impossible de créer l'analyse :", data.error)
    erreur(data.error)
  }


  /**
   * @return true si les données pour l'analyse sont valides
   * Pour une création, c'est seulement une première vérification. 
   * Les données devront être confirmées côté serveur.
   */ 
  static dataAreValide(data){
    var errors = []
    if ( data.analyse_id == '' ) {
      errors.push("- Il faut renseigner l'identifiant de l'analyse.")
    }
    if ( data.analyse_id.replace(/[a-zA-Z0-9_\-]/g,'') != '' ) {
      errors.push('- L’identifiant ne doit contenir que des lettres, des chiffres, des traits d’union ou des tirets plats.')
    }
    if ( data.piece_title == '') {
      errors.push("- Il faut renseigner le titre de l'œuvre.")
    }
    if ( data.composer == '') {
      errors.push("- Il faut renseigner le compositeur de l'œuvre.")
    }
    if ( data.analyste == '') {
      errors.push('– Il faut le nom de l’analyste.')
    }
    if ( errors.length ) {
      erreur(errors.join('<br />'))
      return false
    } else {
      return true
    }
  }


  // @return l'objet DOM du panneau des informations de l'analyse
  static get panneau_infos(){
    if (undefined == this._panneau_infos) {
      this._panneau_infos = new PanneauInfos()
    } return this._panneau_infos
  }
 }
