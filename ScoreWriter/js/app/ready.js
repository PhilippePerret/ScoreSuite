'use strict';
$(document).ready(e => {
  try{
    UI.prepare()
    App.getCode()
  } catch(err){
    console.log("Erreur au cours du chargement", err)
  }
})
