'use strict';
/**
* Gestion d'un aide
* -----------------
* 
* @usage
*   
*   * définir HELP_TEXT dans l'application
*       - soit le texte lui-même, soit le path au fichier d'aide
*   * appeler QuickHelp.display(<params>) pour afficher l'aide
*     ou QuickHelp.toggle() pour l'afficher/la masquer
* 
* @notes
*   - contrairement à Help.js, qui est un peu une usine à gaz, ce
*     module prend simplement un texte Markdown et l'affiche dans un
*     panneau. La seule opération qu'il produit est de faire une
*     table des matières à partir des titres et des ances définies.
*   - QuickHelp ne met dans la table des matières que les titres qui
*     possède une ancre.
*   - QuickHelp est plutôt pensée pour être une aide rapide, mais on
*     peut tout à fait y mettre l'intégralité de l'aide.
* 
* @requis
*   - ce module system/QuickHelp.js
*     le module system/QuickHelp.css de mise en forme
*     le module system/QuickHelp.rb (côté serveur)
*   - Panel.js (gestion des panneaux)
*   - Panel.css 
*   - marked.min.js (parse du code markdown)
*   - définition de HELP_TEXT par l'application (texte ou chemin).
* 
* @contenu HELP_TEXT
* 
*   HELP_TEXT est une constante qui doit définir le code de l'aide
*   entière, au format Markdown.
*/
class QuickHelp {

  /**
  * Masquer/Afficher l'aide
  */
  static toggle(){
    if ( this.isBuilt ) {
      this.panel.toggle()
    } else {
      this.build_and_show()
    }
  }

  /**
  * Appelée pour afficher l'aide
  * 
  * @param [Hash] params Paramètres
  * @option params anchor [String] L'ancre à rejoindre dans l'aide
  * @option params extract [Boolean] Si true, en conjugaison avec +anchor+, n'affiche que cette partie
  * 
  */  
  static display(params){
    if ( this.isBuilt ) {
      this.panel.show()  
    } else {
      this.build_and_show()
    }
  }

  /*
  |  --- Building Methods ---
  */

  /* Juste pour la sémantique */
  static build_and_show(){
    this.build()
  }
  /**
  * Construction de l'aide
  */
  static build(code_help){
    if ( undefined == code_help ) {
      this.getCode()  
    } else {
      this.buildTdm(code_help)
      this.buildPanel(code_help)
      this.isBuilt = true
      this.panel.show()
    }
  }
  static getCode(){
    if ( HELP_TEXT.search(/[ \n]/) > -1 ) {
      /* - Texte donné explicitement - */
      this.build(HELP_TEXT)
    } else {
      /* - Texte donné par chemin d'accès - */
      WAA.send({class:'WaaApp::QuickHelp',method:'get_help_text', data:{path:HELP_TEXT}})
    }
  }
  static onGetCode(retour){
    console.log("retour : ", retour)
    if (retour.ok) {
      this.build(retour.help_text)
    } else { 
      erreur(retour.msg) 
    }
  }

  static buildPanel(code_help){
    this._panel = new Panel(this.dataPanel)
    this._panel.setContent(this.TOC + marked.parse(code_help))
  }

  static get panel(){ return this._panel }


  /**
  * Construction de la table des matières.
  * @produit
  *   this.toc   [String] Le texte de la table des matières
  */
  static buildTdm(code){
    var nextIsTitre = false
    let toc_items = []
    const REG_ANCRE = /^<a name="(.+?)"><\/a>$/;
    var titre, level ;
    code.split("\n").forEach(line => {
      if ( line.trim() == '' ) return ;
      if ( nextIsTitre ) {
        titre = line.split(' ')
        level = titre.shift().length
        titre = titre.join(' ')
        toc_items[toc_items.length - 1].titre = titre
        toc_items[toc_items.length - 1].level = level
        nextIsTitre = false
      } else if ( line.search(REG_ANCRE) > -1 ) {
        toc_items.push({ancre: line.match(REG_ANCRE)[1], titre: null, level: null})
        nextIsTitre = true
      }
    })
    /*
    |  On peut construire la table des matières
    */
    const TOCLINE = '`<div class="tdm level${level}"><a href="#${ancre}">${titre}</a></div>`';
    this.TOC = toc_items.map(ditem => {
      const level = ditem.level
      const ancre = ditem.ancre
      const titre = ditem.titre
      return eval(TOCLINE)
    }).join('')
    this.TOC = '<div class="tdm-container">' + this.TOC + '</div>'
  }

  static get dataPanel(){
    return {
        id: 'quickhelp'
      , mainTitle: "Aide de " + App.NAME
      , options: { movable: true }
    }
  }

}
