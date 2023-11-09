'use strict'

const ERRORS = {
    
    mustBeMot: '%s doit être défini et être un {Mot}.'
  , fragmentRequired: 'Le fragment courant doit être défini (dans TextFragment.current)'

  , proximity: {
      apresMustBeApres: 'Le mot d’après doit être vraiment après le mot avant…'
    }
}

const MESSAGES = {
    helpForGoTo:    "Pour se rendre à un endroit du film avec la commande g (minuscule), il faut soit placer le curseur sur une horloge de temps, soit définir un marqueur avec CMD-M (au temps voulu). Sinon, utiliser G majuscule pour rejoindre le premier temps trouvé dans le texte en remontant."
  , confirmMarker:  "Marqueur de temps placé à %s. Jouer ⌘-m pour le rejoindre."
}
