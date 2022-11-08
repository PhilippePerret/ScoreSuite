/**
 * Ce code est à copier-coller dans la console du navigateur et
 * à jouer pour lancer les tests.
 * 
 * Ce code nécessite la librairie waa_tests.js pour pouvoir 
 * fonctionner.
 * 
 * Il est possible aussi de jouer des tests depuis ruby avec
 * simplement execute_script
 */

is_not_visible('panneau_metadata')
let bNew = DGet('#btn-new-analyse')
bNew.click()
is_visible('panneau_metadata')
