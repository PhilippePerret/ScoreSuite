'use strict';

/**
* Dans Score-Builder, on a besoin de trois helpers :
* 1) le manuel de score-builder lui-même
* 2) le manuel de Score-image (code Mus)
* 3) le manuel de Lilypond
*/

const URL_PDFS = 'https://www.atelier-icare.net/public/Manuels/'

class Helper extends Panneau {

  static prepare(){
    this.watchMenuItems()
  }

  /**
  * Observation des menus d’aide (3 menus sont disponibles)
  */
  static watchMenuItems(){
    const menu = DGet('menu#helper')
    menu.querySelectorAll('menu-item').forEach( item => {
      listen(item,'click',this.onClickMenu.bind(this, item))
    })
  }

  /**
  * Méthode appelée quand on clique sur un des menus d’aide
  */
  static onClickMenu(item, ev) {
    this.currentManuelId = item.dataset.manuel
    const manuelPath = this.getManuelPath(item.dataset.manuel)
    this.built || this.build()
    this.open()
    // console.info("Ouvrir : ", manuelPath)
    this.loadInFrame(manuelPath)
    // Visibilité du bouton pour actualiser en fonction de
    // la nature de l’aide
    const isUpdatable = item.dataset.updatable == 'true'
    this.btnUpdateOnline.classList[isUpdatable?'remove':'add']('hidden')
    this.btnEdit.classList[isUpdatable?'remove':'add']('hidden')
  }

  static loadInFrame(url){
    this.iframe.src = url
  }

  static getManuelPath(manuel_id){
    switch(manuel_id){
    case 'code-mus': return URL_PDFS+"Manuel_code_MUS.pdf";
    case 'score-builder': return URL_PDFS+"Manuel_ScoreBuilder.pdf"
    case 'lilypond': return "https://lilypond.org/doc/v2.24/Documentation/notation/index.fr.html"
    case 'quick-help': return URL_PDFS+"ScoreBuilder_QuickHelp.pdf"
    }
  }

  static editCurrentManuel(ev) {
    stopEvent(ev)
    WAA.send({class:"ScoreBuilder::App",method:"edit_manuel",data:{manuel_id: this.currentManuelId}})
    return false
  }
  static updateManuelsOnline(ev){
    stopEvent(ev)
    WAA.send({class:"ScoreBuilder::App",method:"update_manuels_online",data:{}})
    return false
  }
  static onUpdatedPdfOnline(wdata){
    if ( wdata.ok ) {
      message("PDFs actualisés en ligne.")
    } else {
      erreur("Une erreur est survenue : " + wdata.error)
    }
  }

  static build(){
    const panneau = DCreate('DIV',{id:'help-viewer-panneau'})
    const iframe = DCreate('IFRAME')
    iframe.style = "width:100%;"
    panneau.appendChild(iframe)
    const divButtons = DCreate('DIV', {class:'buttons'})
    this.btnClose = DCreate('BUTTON',{text:'Fermer', style:"float:right;"})

    // - Bouton d’édition du manuel (if any) -
    this.btnEdit = DCreate('BUTTON', {class:'fleft', text:"Éditer…"})
    divButtons.appendChild(this.btnEdit)

    // - Bouton d’actualisation en ligne -
    this.btnUpdateOnline = DCreate('BUTTON', {class:'fleft', text:"Actualiser en ligne"})
    this.btnUpdateOnline.title = 
    `Les manuels se trouvent en ligne, sur le site Icare (dans 
     public/Manuels). Ce bouton permet de les actualiser après 
     un changement effectué dans le texte.`
    divButtons.appendChild(this.btnClose)
    divButtons.appendChild(this.btnUpdateOnline)
    panneau.appendChild(divButtons)
    document.body.appendChild(panneau)
    this.iframe   = iframe
    this.panneau  = panneau
    // Régler les hauteurs
    const hPanneau = window.innerHeight - 200
    this.panneau.style.height = px(hPanneau)
    this.iframe.style.height  = px(hPanneau - 60)
    if ( Config('panneauAideDraggable') ) {
      $(panneau).draggable()
    }
    this.built = true
    this.watch()
    // Le bouton pour actualiser en ligne
    listen(this.btnUpdateOnline, 'click', this.updateManuelsOnline.bind(this))
    listen(this.btnEdit, 'click', this.editCurrentManuel.bind(this))
  }

}
