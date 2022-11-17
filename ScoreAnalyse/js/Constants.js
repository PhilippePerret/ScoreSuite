'use strict';

/**
 * Les types de marques (modulation, emprunt, pédale, etc.)
 * Ils déterminent la propriété 'type' de la marque.
 * 
 * Les champs qui n'ont pas de valeur 'default', ne possède pas de
 * propriété :content.
 * 
 */
const AMARQUES_TYPES = {
    'acc': {name:'Accord'       , shortcut:'a', ajustX:12,  ajustY:8,     value:'acc', default:'c', message:"Nom de l'accord"}
  , 'har': {name:'Harmonie'     , shortcut:'h', ajustX:16,  ajustY:8,     value:'har', default:'I', message:"Chiffrage"}
  , 'mod': {name:'Modulation'   , shortcut:'m', ajustX:24,  ajustY:-80,   value:'mod', default:'c', message:"Nouvelle tonalité"}
  , 'emp': {name:'Emprunt'      , shortcut:'e', ajustX:4,   ajustY:-60,   value:'emp', default:'c', message:"Tonalité de l'emprunt"}
  , 'cad': {name:'Cadence…'     , shortcut:'c', ajustX:-70, ajustY:14,    value:'cad', subtype:true, autocontent:true}
  , 'ped': {name:'Pédale'       , shortcut:'p', ajustX:20,  ajustY:10,    value:'ped', default:'1', message:"Degré de la pédale"}
  , 'not': {name:'Type de note…', shortcut:'n', value:'not', subtype:true, autocontent:true}
  , 'deg': {name:'Degré note'   , shortcut:'d', ajustX:26,  ajustY:24,  value:'deg', default:'1', message:'Degré de la note'}
  , 'prt': {name:'Partie'       , shortcut:'z', ajustX: 0   ,ajustY:0       ,value:'prt' ,default:'EXPO', message:'Nom de la partie'}
  , 'txt': {name:'Texte'        , shortcut:'t', ajustX:0,   ajustY:23       ,value:'txt', subtype:true, default:'',  message:"Texte à afficher"}
  , 'seg': {name:'Segment'      , shortcut:'s', value:'seg', subtype:true   ,default:'membre 1', message:"Légende (vide si aucune)"}
  , 'cir': {name:'Cercle'       , shortcut:'r', value:'cir'}
  , 'box': {name:'Cadre'        , shortcut:'b', value:'box'}
}


const TYPES_AJUSTABLES = {
   'acc':['acc']
 , 'har':['har','cad']
 , 'mod':['mod','emp']
 , 'emp':['emp','mod']
 , 'cad':['cad','har']
}


/**
 * Les TYPES DE CADENCES
 * 
 */
const CADENCES = {
    'par': {name:'Cadence parfaite',   value:'par', autocontent:'I',  shortcut:'p'}
  , 'imp': {name:'Cadence imparfaite', value:'imp', autocontent:'I',  shortcut:'n'}
  , 'dem': {name:'Demi-cadence',       value:'dem', autocontent:'V',  shortcut:'d'}
  , 'ita': {name:'Cadence italienne',  value:'ita', autocontent:'I',  shortcut:'i'}
  , 'rom': {name:'Cadence rompue',     value:'rom', autocontent:'VI', shortcut:'r'}
  , 'pla': {name:'Cadence plagale',    value:'pla', autocontent:'I',  shortcut:'g'}
  , 'fau': {name:'Cadence fauréenne',  value:'fau', autocontent:'I',  shortcut:'f'}
}

const TYPES_NOTES = {
    'np': {name:'Note de passage',  value:'np', autocontent:'NP'  , shortcut:'p'}
  , 'ap': {name:'Appoggiature',     value:'ap', autocontent:'AP'  , shortcut:'a'}
  , 'ac': {name:'Appog.chromatique',value:'ac', autocontent:'AC'  , shortcut:'c'}
  , 're': {name:'Retard',           value:'re', autocontent:'R'   , shortcut:'r'}
  , 'br': {name:'Broderie',         value:'br', autocontent:'BR'  , shortcut:'b'}
  , 'db': {name:'Double-broderie',  value:'db', autocontent:'DB'  , shortcut:'d'}
  , 'in': {name:'Note naturelle',   value:'in', autocontent:'NN'  , shortcut:'n'}
  , 'an': {name:'Anacrouse',        value:'an', autocontent:'AN'  , shortcut:'s'}
}

// Liste des types (ci-dessus) qui doivent utiliser la 
// fonte PhilNote (PhilNote2 maintenant)
const TYPES_PHILHARMONIEFONT = ['acc','har','mod','emp','cad','ped']
