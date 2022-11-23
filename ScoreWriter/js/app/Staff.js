'use strict';
/**
 * Class Staff
 * -----------
 * Pour la gestion des portées (mais seulement au niveau des options,
 * pour définir leur nom, leur clé, etc.). Ça n'intervient pas 
 * vraiment pour les données du code (sauf pour en obtenir les data
 * et ce genre de choses).
 * 
 */
class Staff {

static get DATA(){
  return {
      'piano': {keys:['G','F'], names:['','']}
    , 'quatuor': {keys:['G','G','UT3','F'], names:['Vl1','Vl2','Vla','Vlc']}
  }
}
/**
 * Retourne l'instance Staff d'identifiant +staff_id+
 * 
 */
static get(staff_id){
  if ( undefined == this.table ) this.table = {}
  if ( undefined == this.table[staff_id]) Object.assign(this.table, {[staff_id]: new Staff(staff_id)})
  return this.table[staff_id]    
}

/**
 * Méthode pour effacer les portées, hormis la première (il doit 
 * toujours rester une portée)
 */
static removeStaves(){
  var trportee
    , istaff = 1 // pour commencer à 2
  while ( true ){
    trportee = document.querySelector(`#tr_staff-${++istaff}`)
    if ( trportee ) {
      trportee.remove()
      if ( this.table) { delete this.table[istaff] }
    } else {
      break
    }
  }
}

static get firstStaff(){return this._firststaff || (this._firststaff = this.get(1))}

static reset(){
  delete this._data
  this._data = null
}

}
