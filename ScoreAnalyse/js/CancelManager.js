'use strict';
/**
  
  Class CancelManager
  -------------------
  Gestion des annulations

  Dans un gestionnaire d'évènements keyboard, ajouter :

  case 'z':
    if (e.metaKey) { return Cancel.zLast(e) }

  Définir le menu (<option>) qui va afficher l'action annulable
  -------------------------------------------------------------
  Cancel.zMenu = <option>

  Pour enregistrer une opération à annuler :
  ------------------------------------------

  Cancel.z({
      name:"<nom human de l'opération>"
    , method: <methode
    à utiliser pour revenir en arriève>})


*/
class CancelManager {
  
  constructor(){
    this.items = []
  }

  zLast(e){
    /**
     ** Méthode principale appelée quand on veut annuler la 
     ** dernière opération
     **/
    if ( this.items.length == 0 ) {
      return tooltip('Aucune action n’est annulable.')
    } else {
      this.execCancel(this.items.pop())
    }
    /*
    |  S'il y a un menu d'annulation, on le renseigne
    */
    this.defineZMenu()
    return stopEvent(e)
  }

  zIndex(idx){
    /**
     ** Annule l'annulation d'index +idx+
     **/
    this.execCancel(this.items.splice(idx,1)[0])
  }

  execCancel(data){
    // console.debug("Je dois annuler : ", data)
    try {
      /*
      |  On indique que l'annulation est en cours, pour rediriger
      |  les méthodes qui enregistrent des annulations
      */
      this.ON = true
      /*
      |  On procède à l'annulation
      */
      data.method.call()
    } catch(err) {

    } finally {
      /*
      |  On indique que l'annulation n'est plus active
      */
      this.ON = false
    }
  }

  unzLast(e){
    if ( this.unzData ) {
      this.unzData = undefined
    } else {
      console.warn("Aucune annulation à annuler")
    }
    return stopEvent(e)
  }


  // @prop Le dernier item d'annulation (le premier qui le sera)
  get lastItem(){return this.items[this.items.length - 1]}

  z(data) {
    /**
     ** Enregistrer l'opération annulable définie par +data+
     **/
    if ( this.ON ) {
      this.unz(data)
    } else {    
      Object.assign(data, {time: new Date()})
      this.items.push(data)
      // console.debug("Annulation enregistrée : ", data)
      this.defineZMenu()
    }
  }
  unz(data){
    this.unzData = data
  }

  get zMenu(){return this._zmenu}
  set zMenu(v){this._zmenu = v}

  zInList(e){
    /**
     ** Méthode publique pour afficher la liste des annulations et
     ** pouvoir supprimer celles qui sont choisies (dans n'importe
     ** quel ordre, contrairement aux annulations classique)
     **/
    if ( this.items.length == 0 ) {
      erreur("Aucune action à annuler.")
    } else {
      this.zChoose()
    }
    return e && stopEvent(e)
  }

  zChoose(){
    /**
     ** Méthode pour choisir dans la liste les actions à annuler.
     **/
    if ( not(this.obj) ) this.build()
    this.showList()
  }


  build(){
    /**
     ** Construction de la liste des annulations possibles
     ** Produire this.obj
     **/
    this.obj = DCreate('DIV', {id:'historique_annulations', class:'hidden'})
    const closeBox = DCreate('SPAN', {text:'❌', class:'close-box'})
    listen(closeBox, 'click', this.hideList.bind(this))
    this.obj.appendChild(closeBox)
    for(var i = 0, len = this.items.length; i < len; ++i){
      const item = this.items[i]
      const dom  = DCreate('DIV', {text: `Changement : ${item.name}`})
      this.obj.appendChild(dom)
      listen(dom, 'click', this.onCancelInHisto.bind(this, dom, i))
    }
    document.body.appendChild(this.obj)
  }

  onCancelInHisto(dom, idx){
    this.zIndex(idx)
    dom.remove()
  }

  showList(){
    this.obj.classList.remove('hidden')
  }
  hideList(){
    this.obj.classList.add('hidden')
  }


  defineZMenu(){
    /**
     ** S'il y a un menu d'annulation dans un select, on le
     ** règle.
     **/
    if ( this.zMenu ) {
      this.zMenu.innerHTML = this.lastItem ? 
        `Annuler : ${this.lastItem.name} ⌘z` : ''
    } 
  }

}

const Cancel = new CancelManager()
