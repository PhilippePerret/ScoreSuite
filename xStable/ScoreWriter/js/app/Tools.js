'use strict';
/**
 * 
 * Tools est un objet de classe ToolsClass
 * Pour gérer les outils.
 * 
 */
const SNIPPETS = {
    'double_voix': "<< {  } \\\\ {  } >>"
  , 'debut_reprise': "|:"
  , 'fin_reprise': ":|"
  , 'fin_debut_reprise': ":|:"
  , 'fin': "|."
}
class ToolsClass {

writeInCurrent(key){
  if ( MesureCode.current ) {
    const content = SNIPPETS[key] || key
    MesureCode.current.addInCurrentStaff(content)
    Onglet.close()
  } else {
    error("Il faut choisir le champ (en cliquant dedans.")
  }
}

/**
 * Méthode appelée pour ajouter un triolet dans le code
 * 
 */
insertTriolet(){
  const note1 = DGet('#triolet_note-1').value
      , note2 = DGet('#triolet_note-2').value
      , note3 = DGet('#triolet_note-3').value
      , duree = DGet('#triolet_duree_note').value
  const code = `3{${note1}${duree} ${note2} ${note3}}`
  this.writeInCurrent(code)
}

/**
 * Appelée par le bouton "Forcer le rechargement de limage"
 * 
 */
forceUpdateImage(){
  $('img#score').attr('src', "score_building/code/default.svg")
  setTimeout(Score.update.bind(Score), 2000)
}

resetAll(){
  MesureCode.resetAll.call(MesureCode)
  Onglet.close('tools')
}

/**
 * Pour ouvrir la version éditable (Markdown) du manuel
 * 
 */
openManuelEditable(){
  WAA.send({class:'ScoreWriter::App',method:'open_manuel_md'})
}

/**
 * Pour exécuter le code du champ #code_a_tester (Outils) dans 
 * l'application.
 * Le résultat sort dans la console.
 * 
 */
execCodeInApp(){
  const code = document.querySelector('#code_a_tester').value.trim()
  if ( code == "" ) {
    error("Aucun code n'est à évaluer…")
  } else {
    try {
      let res = eval(code)
      console.log("Résultat en évaluant le code fourni", code, res)
    } catch(erreur) {
      console.error(erreur)
      error("Une erreur s'est produite en exécutant le code. Visez la console.")
    }
  }
}

}
const Tools = new ToolsClass()
