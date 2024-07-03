"use strict";
/**
 * 
* @usage
*   Définir la configuration ’monOption’ dans CONFIGURATION ci-dessous
*   Appeler ’Config('monOption')’ dans le programme
* 
*/
const CONFIGURATION = {

  panneauAideDraggable: true

}

class ConfigClass {

  getValue(configId){
    return CONFIGURATION[configId]
  }
}
const Config = (new ConfigClass()).getValue
