'use strict';

window.onresize = function(ev){
  UI.setDisposition()
  return stopEvent(ev)
}

class UIClass {

/**
 * Méthode principale qui prépare l'interface au chargement de
 * l'application.
 * 
 */
prepare(){
  /*
   | Position des messages
   */
  Message.position = 'bottom-left'
  /* 
   | Préparation de l'interface
   */ 
  Onglet.prepare()
  /* 
   | Réglage des options
   */ 
  Options.init()
  /* 
   | Observation de certains champs
   */ 
  this.observeSpecialFields()
}

/**
 * Réglage de la disposition de l'écran, qui peut mettre l'image de
 * la partition et le bloc des lignes de code à différents endroits.
 * 
 * La méthode est appelée quand on lance l'application, par la 
 * méthode Options.applique ou lorsqu'on change la disposition dans
 * le panneau des options.
 * 
 * @param dispo {String}
 *        up_down, down_up, left_right, right_left, correspondent à
 *        <position image partition>_<position lignes code>
 */
setDisposition(dispo){
  dispo = dispo || Options.getProperty('disposition')
  // console.info("Disposition : %s", dispo)
  const wWidth  = window.innerWidth - 140 // 140 = marge droite des outils
  const wHeight = window.innerHeight
  const sectionScore = document.querySelector('#score_container')
  const sectionCode  = document.querySelector('#code_container')
  const [posScore, posCode] = dispo.split('_')
  const sens = (posScore == 'down' || posScore == 'up') ? 'vertical' : 'horizontal'
  // console.info("Sens de la disposition : %s", sens)

  // 
  // Placement des éléments
  // 

  // Top de la partition
  if ( posScore == 'down' ) {
    sectionScore.style.top = px(wHeight / 2) 
  } else {
    sectionScore.style.top = 0
  }

  // Top des mesures de code
  if ( posCode == 'down' ) {
    sectionCode.style.top = px(wHeight / 2)
  } else {
    sectionCode.style.top = 0
  }

  // Les lefts
  if ( sens == 'vertical' ) {
    sectionScore.style.left   = 0
    sectionScore.style.width  = '90%'
    sectionCode .style.left   = '10%'
    sectionCode .style.width  = '80%'
    sectionScore.style.height = '48%'
    sectionCode .style.height = '48%'
    if ( posScore == 'up' ) {
      sectionScore.style.top = 0
      sectionCode .style.top = '50%'
    } else /* Image en bas */ {
      sectionScore.style.top = '50%'
      sectionCode .style.top = 0
    }
  } else /* sens horizontal */ {
    sectionScore.style.height = '98%'
    sectionCode .style.height = '98%'
    if ( posScore == 'left' ) {
      sectionScore.style.left = 0
    } else /* image à droite */ {
      sectionCode .style.left = 0
    }

    if ( wWidth > 2000 ) {
      sectionScore.style.width = px(1000)
      sectionCode .style.width = px(wWidth - 1000 - 50)
      if ( posScore == 'left' ) {
        sectionCode .style.left = px(1000 + 25)
      } else /* Score à droite */ {
        sectionScore.style.left = px(wWidth - 1000)
      }
    } else /* fenêtre inférieure à 2000px de large */ {
      sectionScore.style.width = '48%'
      sectionCode .style.width = '48%'
      if ( posScore == 'left' ) {
        sectionCode .style.left = '50%'
      } else /* Score à droite */ {
        sectionScore.style.left = '50%'
      }
    }
  }
}

/**
 * Observation de certains champs spéciaux (comme par exemple le
 * champs qui donne la première mesure)
 * 
 */
observeSpecialFields(){
  this.firstMesureField.addEventListener('change', MesureCode.onChangeFirstMesureNumber.bind(MesureCode))
}

/**
 * Retourne le numéro de première mesure, qu'il soit défini ou non
 * 
 */
getFirstNumber(){
  let num = this.firstMesureField.value
  if ( num == '' ){ num = 1 }
  else { num = parseInt(num, 10) }
  return num
}

get firstMesureField(){
  return this._firstmes || (this._firstmes = document.querySelector('#mesure'))
}

  showBoutonsConfirmation(){
    UI.showButtonConfirmer()
    UI.showButtonRenoncer()    
  }
  hideBoutonsConfirmation(){
    UI.hideButtonConfirmer()
    UI.hideButtonRenoncer()
  }

  showButtonConfirmer(){this.btnConfirmer.classList.remove('invisible')}
  hideButtonConfirmer(){this.btnConfirmer.classList.add('invisible')}
  showButtonRenoncer(){this.btnRenoncer.classList.remove('invisible')}
  hideButtonRenoncer(){this.btnRenoncer.classList.add('invisible')}


  // Retourne le numéro du premier système voulu
  getNumberOfFirstSystem(){
    return Number(this.firstNumberField.value || 1)

  }

  get score(){return this._score || (this._score = document.querySelector('img#score'))}

}
const UI = new UIClass()
