'use strict';
/**
* Définition des constantes propres à l'application
*/

/* Utilisé pour l'attribut 'title' des balises (qui s'affiche lorsque
l'on glisse la souris sur l'élément) à mettre avant le texte pour 
qu'il n'apparaisse pas sous la souris */
const MGTIT = "        "

const RET = "\r\n"


const REG_TIME_MARK = new RegExp("^[0-9]:[0-9]{1,2}:[0-9]{1,2}(\.[0-9]{1,3})?$")

/**
* Taille des sections de texte pour l'enregistrement et le
* chargement.
*/
const TEXTE_SECTION_LENGTH = 8000 ; // mettre 32000
