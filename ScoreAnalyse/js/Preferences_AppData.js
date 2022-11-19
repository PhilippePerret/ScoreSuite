'use strict';

/**
 * Préférences propres à l'application
 * 
 */

const PreferencesAppData = {
    lock_systems:           {type:'checkbox'    ,typeV:'boolean'  ,default:false    ,label:'Verrouiller les systèmes'}
  , systeme_width:          {type:'inputtext'   ,typeV:'number'   ,default:1860     ,label:"Largeur (en pixels) des systèmes", selector:'img.systeme', selector_value:"width:__VALUE__px;"}
  , top_first_system:       {type:'inputtext'   ,typeV:'number'   ,default:50       ,label:"Décalage haut du premier système (en pixels)"}
  , distance_systemes:      {type:'inputtext'   ,typeV:'number'   ,default:50       ,label:"Distance par défaut (en pixels) des système"}
  , adjust_same_mark:       {type:'checkbox'    ,typeV:'boolean'  ,default:true     ,label:"Ajuster en hauteur les marques de même type"}
  , snap_for_adjust_pos:    {type:'inputtext'   ,typeV:'number'   ,default:50       ,label:"Distance magnétisme alignement marques", precision:"Affect les marques de même type et seulement si la préférence “Ajuster en hauteur” ci-dessus est activée."}
  , marque_accords_size:    {type:'inputtext'   ,typeV:'number'   ,default:60       ,label:"Taille des marques d'accord"    ,unite:'px' ,selector:'div.aobj.acc', selector_value:'font-size:__VALUE__px;'}
  , marque_harmonie_size:   {type:'inputtext'   ,typeV:'number'   ,default:60       ,label:"Taille des marques d'harmonie"  ,unite:'px' ,selector:'div.aobj.har, div.aobj.cad', selector_value:'font-size:__VALUE__px;'}
  , marque_modulation_size: {type:'inputtext'   ,typeV:'number'   ,default:60       ,label:"Taille des marques d'harmonie"  ,unite:'px' ,selector:'div.aobj.mod, div.aobj.emp', selector_value:'font-size:__VALUE__px;'}
  , thiness_segment_line:   {type:'inputtext'   ,typeV:'number'   ,default:4        ,label:"Grosseur trait segments"        ,unite:'px' ,selector:'div.amark.seg'   ,selector_value:'border-width:__VALUE__px;'}
  , marque_pedale_size:     {type:'inputtext'   ,typeV:'number'   ,default:40       ,label:"Taille des pédales"             ,unite:'px' ,selector:'div.aobj.ped span.content', selector_value:'font-size:__VALUE__px;width:calc(__VALUE__px / 2);height:calc(__VALUE__px / 2);line-height:calc(__VALUE__px / 2);'}
  , marque_texte_size_1:    {type:'inputtext'   ,typeV:'number'   ,default:60       ,label:"Taille des gros textes"         ,unite:'px' ,selector:'div.amark.txt.size1 span.content',   selector_value:'font-size:__VALUE__px;'}
  , marque_texte_size_2:    {type:'inputtext'   ,typeV:'number'   ,default:40       ,label:"Taille des textes moyens"       ,unite:'px' ,selector:'div.amark.txt.size2 span.content', selector_value:'font-size:__VALUE__px;'}
  , marque_texte_size_3:    {type:'inputtext'   ,typeV:'number'   ,default:24       ,label:"Taille des petits textes"       ,unite:'px' ,selector:'div.amark.txt.size3 span.content', selector_value:'font-size:__VALUE__px;'}
  , marque_texte_size_4:    {type:'inputtext'   ,typeV:'number'   ,default:16       ,label:"Taille des textes très petis"   ,unite:'px' ,selector:'div.amark.txt.size4 span.content', selector_value:'font-size:__VALUE__px;'}
  , note_volume:            {type:'inputtext'   ,typeV:'float'    ,default:0.5      ,label:"Volume de départ des notes (entre 0.0 — silence – et 1.0 — volume max."}
  , vitesse_relecture:      {type:'inputtext'   ,typeV:'number'   ,default:20       ,label:"Vitesse de la relecture (de 1 à 100)", precision:"Ça détermine le temps d'affichage d'un objet en mode relecture. Avec la valeur 100, tous les objets sont à peu près ré-écrit en même temps."}
  , minimum_duree_notes:    {type:'inputtext'   ,typeV:'number'   ,default:0.5      ,label:"Durée minimum des notes jouées (secondes)", precision:"Même si une note est “piquée” sur le clavier, elle sera jouée ce temps."}
  , autosave:               {type:'checkbox'    ,typeV:'boolean'  ,default:true     ,label:'Sauvegarde automatique'}
  , animate:                {type:'checkbox'    ,typeV:'boolean'  ,default:false    ,label:'Animer l’analyse'   ,precision:'Les marques seront affichées progressivement'}
}

// Ajout de l'identifiant aux données
Object.keys(PreferencesAppData).forEach(keyPref => {
    PreferencesAppData[keyPref].id = keyPref
})
