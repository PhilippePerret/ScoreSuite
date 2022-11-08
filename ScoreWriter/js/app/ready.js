'use strict';
$(document).ready(e => {
  try{
    UI.prepare()
    /**
     * On remonte le code éventuel (il peut être défini par la 
     * dernière partition ouverte, ou par le premier argument de
     * la ligne de commande pour lancer l'application)
     */
    WAA.send({class:'ScoreWriter::App',method:'get_code',data:{default:null, config:null}})
  } catch(err){
    console.log("Erreur au cours du chargement", err)
  }

})
