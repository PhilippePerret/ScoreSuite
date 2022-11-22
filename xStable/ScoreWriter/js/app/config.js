'use strict';
/**
  * Ce fichier permet de définir les préférences
  */

const CONFIG = {
  /**
   * Les options par défaut
   * 
   * Si une options est ajoutée, il faut définir ses données 
   * dans la constante DATA_OPTIONS de Options.js
   */
  default_options: {
      'page':             'a4'
    , 'mesure':           ''
    , 'systeme':          'piano'
    , 'proximity':        ""
    , 'barres':           true
    , 'stems':            true
    , 'tune':             'C'
    , 'time':             null
    , 'auto_update_after_change': false
    , 'note_tune_fixed':  false
    , 'staves_vspace':    null
    , 'disposition':      'up_down'
  }
}
