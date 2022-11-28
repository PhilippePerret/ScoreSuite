'use strict';

function not(v){ return ! v }


function isNil(v){
  /**
   ** Permet de tester une valeur null/undefined mais qui peut
   ** être égale à 0
   **/
  return not(v) && not(v === 0)
}
