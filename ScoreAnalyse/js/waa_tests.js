'use strict';
/**
 * Librairie pour les tests
 * 
 */
var   successCount = 0
    , failureCount = 0
    ;
function newFailure(msg){
  console.error(msg)
  failureCount ++
  return false
}
function newSuccess(msg){
  console.info(msg)
  successCount ++
  return true
}
function is_visible(domId){
  if (DGet('#'+domId).classList.contains('hidden')){
    return newFailure(`L'élément #${domId} devrait être visible`);
  } else {
    return newSuccess(`Élément #${domId} visible.`)
  } 
}
function is_not_visible(domId){
  if (DGet('#'+domId).classList.contains('hidden')){
    return newSuccess(`Élément #${domId} non visible.`)
  } else {
    return newFailure(`L'élément #${domId} ne devrait pas être visible`);
  } 
}
