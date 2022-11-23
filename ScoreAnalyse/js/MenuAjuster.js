'use strict';
/**

  Class AjustMenu
  ---------------
  Gestion du menu principal "Ajuster"

  cf. la class MenusTool pour le fonction général

*/
class AdjustMenu extends MenusTool {

  static init(){
    super.init()
    this.setAllMenusAjustement(false)
  }

  static setStateBySelection(count){
    this.setAllMenusAjustement(count > 1)
  }

  static setAllMenusAjustement(state){
    const dernierMenu = this.menu.options.length - 1
    for(var i = 1; i < dernierMenu; ++i){
      this.menu.options[i].disabled = not(state)
    }
  }



  static onActivate(e, adjust, option) {
    switch(adjust){
    case 'cancel':
      this.cancelLastAjustement()
      break
    case 'V':
      this.ajusterVerticalement()
      break
    case 'H':
      this.ajusterHorizontalement()
      break
    default:
      erreur(`Je ne sais pas traiter l'ajustement '${adjust}'.`)
    }
  }


  static ajusterVerticalement(){
    this.ajuster('V')
  }
  static ajusterHorizontalement(){
    this.ajuster('H')
  }
  static ajuster(sens){
    /**
    ** Prend les boites qui sont à peu près aligner horizontalement
    ** et les met bord à bord et de même taille vertical
    **/
    const selection = AObjet.selection
    const boucle    = AObjet.eachSelection.bind(AObjet)
    const forH      = sens == 'H'
    const minProp   = forH ? 'top'    :'left'  
    const maxProp   = forH ? 'height' :'width'
    const sortProp  = forH ? 'left'   : 'top'
    const ctrProp   = forH ? 'right'  : 'bottom' // le bord contre lequel s'aligner
    
    /*
    |  Prendre la valeur minimale
    |  (le top pour l'ajustement H, le left pour l'ajustement V)
    */
    var minVal = null
    boucle(tag => {
      if ( not(minVal) || tag[minProp] < minVal ) { 
        minVal = tag[minProp] 
      }
    })
    console.debug("minVal = ", minVal)

    /*
    |  Prendre la valeur maximale
    |  (le height pour l'ajustement H, le width pour l'ajustement V)
    */
    var maxVal = 0
    boucle(tag => {
      if ( tag[maxProp] > maxVal ) maxVal = tag[maxProp]
    })
    console.debug("maxVal = ", maxVal)

    /*
    |  Classer les boites
    |  (dans l'ordre de leur left pour l'ajustement Horizontal et 
    |   dans l'ordre de leur top pour l'ajustement Verticalement)
    */
    selection.sort(function(a, b){
      return (a[sortProp] < b[sortProp]) ? -1 : 1
    })

    /*
    |  Pour conserver les boites ajustées
    */
    this.lastAdjustedTags = []

    /*
     |  Boucle pour ajuster toutes les boites sélectionnées
     */ 
    var wBorder ;
    const nombreBoites = selection.length
    for (var i = 0; i < nombreBoites; ++i) {
      const currtag = selection[i]
      /*
      |  On conserve les valeurs actuelles pour pouvoir les
      |  remettre en cas d'annulation.
      */
      // currtag.lastTop     = 0 + currtag.top
      currtag[sortProp+'Last'] = 0 + currtag[sortProp]
      // currtag.lastLeft    = 0 + currtag.left
      currtag[minProp+'Last'] = 0 + currtag[minProp]
      // currtag.lastHeight  = 0 + currtag.height
      currtag[maxProp+'Last'] = 0 + currtag[maxProp]

      if ( i > 0 ) {
        /*
        |  Si ce n'est pas la première boite, il faut la coller
        |  à la boite précédente.
        */
        const prevtag = selection[i-1]
        wBorder = this.getBordWidth(prevtag.obj, ctrProp)
        currtag[sortProp] = prevtag[ctrProp] //- wBorder
        console.debug("currtag.%s mis à prevtag.%s (%i) - wBorder (%s) = %i" , sortProp, ctrProp, prevtag[ctrProp], wBorder, currtag[sortProp])
      }
      // currtag.top     = minTop
      currtag[minProp]  = minVal
      // currtag.height  = maxHeight
      currtag[maxProp]  = maxVal
      /*
      |  On mémorise cette tag déplacée
      */
      this.lastAdjustedTags.push(currtag)
    }

    /*
    |  Vérification avec les bords explicites
    */
    for (var i = 1; i < nombreBoites; ++i){
      const currtag = selection[i]
      const prevtag = selection[i-1]
      if ( forH ) {
        const wborder = this.getBordWidth(prevtag.obj, 'right')
        if ( currtag.left != prevtag.right - wborder ) {
          console.error("currtag.left (%s) ne correspond pas à prevtag.right (%s) - wborder (%s)", currtag.left, prevtag.right, wborder)
        }
        if ( currtag.left != prevtag.left + prevtag.width) {
          console.error("Le left ne correspond pas")
        }
      } else {
        const wborder = this.getBordWidth(prevtag.obj, 'bottom')
        if ( currtag.top != prevtag.bottom - wborder) {
          console.error("currtag.top (%s) ne correspond à prevtag.bottom (%s) - wborder (%s)", currtag.top, prevtag.bottom, wborder)
        }
        currtag.top = prevtag.top + prevtag.height //- wborder
        if ( currtag.top != prevtag.top + prevtag.height - wborder) {
          console.error("Le top ne correspond pas : currtag.top (%s) != (%s) prevtag.top (%s) + prevtag.height (%s) - wborder (%s)", currtag.top, prevtag.top + prevtag.height - wborder, prevtag.top, prevtag.height, wborder)
          currtag.top = prevtag.top + prevtag.height - wborder
        }
      }
    }

  }

  static getBordWidth(obj, side){
    const wborder = getComputedStyle(obj,null).getPropertyValue(`border-${side}-width`)
    return Number(wborder.replace(/(px|pt|em|rem|cm|mm)/,'')) // normalement, toujours en px, mais plus tard ?…
  }

  // static ajusterHorizontalement(){
  //   /**
  //   ** Prend les boites qui sont à peu près aligner horizontalement
  //   ** et les met bord à bord et de même taille vertical
  //   **/
  //   const selection = AObjet.selection
  //   const boucle = AObjet.eachSelection.bind(AObjet)
  //   /*
  //   |  Prendre le plus haut top
  //   */
  //   var minTop = null
  //   boucle(tag => {
  //     if ( not(minTop) || tag.top > minTop ) {
  //       minTop = tag.top
  //     }
  //   })
  //   console.debug("minTop = %i", minTop)
  //   /*
  //   |  La plus haute boite
  //   */
  //   var maxHeight = 0
  //   boucle(tag => {
  //     if ( tag.height > maxHeight ) maxHeight = tag.height
  //   })
  //   console.debug("maxHeight = %i", maxHeight)

  //   /*
  //   |  Classer les boites dans l'ordre de leur left
  //   */
  //   selection.sort(function(a, b){
  //     return (a.left < b.left) ? -1 : 1
  //   })

  //   /*
  //   |  On boucle sur chaque boite dans l'ordre pour :
  //   |   - ajuster leur top
  //   |   - mettre le bord left de la suivante au bord right de la
  //   |     précédente
  //   |   - leur donner la même hauteur
  //   */
  //   this.lastAdjustedTags = []
  //   var rBorder ;
  //   const nombreBoites = selection.length
  //   for (var i = 0; i < nombreBoites; ++i) {
  //     const currtag = selection[i]
  //     /*
  //     |  On conserve les valeurs actuelles pour pouvoir les
  //     |  remettre en cas d'annulation.
  //     */
  //     currtag.lastLeft = 0 + currtag.left
  //     currtag.lastTop = 0 + currtag.top
  //     currtag.lastHeight = 0 + currtag.height

  //     if ( i > 0 ) {
  //       /*
  //       |  Si ce n'est pas la première boite, il faut la coller
  //       |  à la boite précédente.
  //       */
  //       const prevtag = selection[i-1]
  //       rBorder = getComputedStyle(prevtag.obj,null).getPropertyValue('border-right-width')
  //       rBorder = Number(rBorder.replace(/(px|pt|em|rem|cm|mm)/,'')) // normalement, toujours en px, mais plus tard ?…
  //       currtag.left = prevtag.right - rBorder
  //     }
  //     currtag.top     = minTop
  //     currtag.height  = maxHeight
  //     this.lastAdjustedTags.push(currtag)
  //   }
  // } // /AjusterHorizontalement


  static cancelLastAjustement(){
    /**
     ** Pour annuler le dernier ajustement
     **/
    this.lastAdjustedTags.forEach(tag => {
      [
        'left','top','right','bottom','width','height'
      ].forEach(prop => {
        if ( undefined == tag[prop + 'Last'] ) return
        tag[prop] = tag[prop + 'Last']
        delete tag[prop + 'Last']
        tag[prop + 'Last'] = undefined
      })
    })
    this.lastAdjustedTags = null
  }
}
