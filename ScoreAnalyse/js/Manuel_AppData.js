'use strict';
/**
 * Module fonctionnant de paire avec Manuels.js, propre à 
 * l'application, qui définit l'aide
 * 
 */

const Ouvrir_preferences = "Ouvrir le panneau des préférences (⇧P)"

const ManuelData = [
  {
      operation: "Travailler une nouvelle partition"
    , procedure:[
            'Ouvrir une fenêtre de Terminal dans le dossier dans lequel doit être créée la nouvelle analyse et lancer la commande <code>score-analyse &lt;id-analyse&gt;</code>.',
            'On peut ensuite produire la partition avec <code>score-writer</code>, la découper avec <code>score-cutting</code> et placer les systèmes obtenus dans le dossier <code>./systems</code> de la nouvelle application.',
            'Puis demander à rafraichir l’application : «Outils» > «Rafraichir».'
            ]
    , precision:'Pour la recharger plus tard, il suffit de relancer la commande <code>score-analyse</code> seule dans son dossier.'
  }
, {
      operation: 'Informations sur l’analyse (la pièce analysée)'
    , procedure: [
            '<ul><li>Cliquer sur le bouton «Analyse» pour ouvrir le panneau des informations de l’analyse,</li><li>régler les informations,</li><li>enregistrer l’analyse à l’aide du bouton «Sauver».</li></ul>',
            ]
    , precision: 'Pour le moment, ces informations ne servent à rien. Mais à l’avenir on pourra imaginer qu’elles permettent de produire une première page de titre.'

  }
, {
      operation: 'Sélection multiple'
    , procedure: 'On peut très simplement faire des sélections multiples de marques simplement en tenant la touche Majuscule appuyée et en glissant la souris (SANS CLIQUER) sur la marque.'
    , precision: 'Si la marque est déjà sélectionnée, elle est déselectionnée.'
  }
, {
      operation: 'Déplacement des systèmes'
    , procedure: ['Si le blocage des systèmes est déverrouillé, on peut déplacer un système à la souris.', 'Mais il est aussi tout à fait possible de répartir tous les systèmes d’un coup de l’écart défini en préférences ou d’un écart déterminé.','Pour ce faire, jouer le bouton «Outils», définissez l’écart et cliquer sur «Répartir les systèmes».']
    , precision: 'Par défaut, tous les objets du système ainsi que tous les objets sous le système sont aussi déplacés. Pour ne déplacer que le système, maintenir la touche ALT à la fin du déplacement.'
  }
, {
      operation: 'Déplacement de toutes les marques supérieures (astuce)'
    , procedure: [
            'Au lieu de déplacer toutes les marques une à une, déplacer seulement le système en maintenant la touche ALT (ce qui empêche de déplacer en même temps tous ses objets et les marques en dessous).'
            ]
  }
, {
      operation: "Réglage des tailles et volumes"
    , procedure: [Ouvrir_preferences, "régler la taille de l'élément voulu."]
    , precision: "On peut pratiquement régler les tailles de tous les éléments, à savoir :<ul><li>la largeur des systèmes,</li><li>la marge haute du premier système,</li><li>l'espacement entre les systèmes,</li><li>la taille des accords,</li><li>la taille des marques d'harmonie</li><li>le volume des notes</li><li>etc.</li></ul>"
  }
, {
      operation: 'Alignement des éléments'
    , procedure: "On peut aligner très précisément des éléments en utilisant la « grille magnétique ». Elle s'active depuis le menu 'Options' »."
    , precision: "Les éléments sont alignés aussi en longueur et en hauteur.<br />Idéal pour construire par exemple un plan de l'œuvre."
  }
, { 
      operation: "Ouvrir le panneau des préférences"
    , procedure: ["Jouer le raccourci clavier ⇧P"]
    , precision: "(“P” comme “Préférences”)"
  }
, {
      operation: "Déplacer un système"
    , procedure: ["Déverrouiller les systèmes s'ils sont verrouillés (“l” ou bouton pied de page),", "cliquer sur le système (relâcher la souris)", "déplacer la souris pour positionner le système", "recliquer sur le système pour le fixer."]
    , precision: "Tous les objets sous le système seront déplacés d'autant de pixels (mais pas les objets au-dessus)."
  }
, {
      operation: "Définir les valeurs par défaut"
    , procedure: ["Activer l'application", "jouer le raccourci ⇧P", "régler les propriétés dans le panneau de préférence qui s'ouvre."]
  }
, {
      operation: "Créer une nouvelle marque d'analyse"
    , procedure: ["Double-cliquer à l'endroit voulu", "régler la nouvelle marque en indiquant la marque (cf. ci-dessous"]
    , precision: `<pre><code>Prolongation   : terminer le nom par '--' ('cm--')</code></pre>`
  }
, {
      operation: 'Créer un texte dans un cadre'
    , procedure: ["Double-cliquer à l'endroit voulu","Taper 'b' ou choisir 'Cadre'","Taper 't' ou choisir 'Texte dans cadre'."]
  }
, {
      operation: "Les types de marque d'analyse"
    , procedure: `<pre><code>
Accord      : marque d'accord au dessus de la portée
Harmonie    : marque en chiffre romain sous la portée indiquant le degré de l'accord
Modulation  : marque de modulation
Emprunt     : marque d'emprunt à un tonalité passagère
Cadence     : marque de cadence
Pédale      : une pédale (souvent le degré ou la note)
Types de notes :
    Note de passage
    Appoggiature
    Appoggiature chromatique
    Retard
    Broderie
    Double-broderie
    Échappée
    Note naturelle
    Anacrouse
Degré de la note : son degré absolu (tonalité) ou relatif (accord)
Cadre (types de cadres) - b comme "border"
    Une partie    : marque de partie/section dans la pièce
    Fin de partie : marque de fin de partie 
    Cellule       : une cellule (cadre avec nom au-dessus)
    Un texte dans un cadre : b + t
Texte       : 
    Un texte quelconque, de 4 tailles différentes
    Un texte dans un cadre : b + t
Segment     : pour délimiter un segment, horizontalement ou verti-
              calement.
Cercle      : un cercle autour d'une note par exemple
</code></pre>`
      
  }
, {
      operation: 'Créer une marque avec ligne de prolongation'
    , procedure: [
            'Certaines marques, comme les accords, les harmonies ou les cadences peuvent avoir une ligne de propagation.',
            'Pour les cadences, elle est gérée dans la marque même.',
            'Pour les autres, il faut ajouter "--" (deux tirets) à la fin du texte de la marque. Cela crée automatiquement une prolongation.'
      ]
    , precision: 'Il suffit ensuite de tirer sur la poignée à droite de la marque pour l’allonger ou la raccourcir.'
  }
, {
      operation:"Dupliquer une marque d'analyse"
    , procedure: ["Créer l'originale si nécessaire", "presser la touche ALT", "avec la touche ALT pressée, déplacer la marque d'analyse à dupliquer à l'endroit voulu."]
  }
, {
      operation:'Formatage des textes'
    , procedure: ["C'est du pseudo-markdown.","**gras**","*italique*","_souligné_","^exposant","¡plus petit¡"] 
    , precision: "Normalement, les notes sont automatiquement détectées."
  }
, {
      operation: "Allonger/raccourcir la ligne de prolongation"
    , procedure: ["Sélectionner la marque d'analyse", "activer la poignée de la ligne", "déplacer la poignée pour définir la longueur", "cliquer à nouveau sur la poignée pour finir."]
  }
, {
      operation: "Se déplacer rapidement de partie en partie de la partition"
    , procedure: ['Numéroter les mesures (au moins les premières des systèmes),', 'créer les parties de la pièce (ou utiliser la forme pour définir des repères),', 'bien régler les numéros de mesures de ces parties,', 'cliquer sur le bouton ⎆ pour rejoindre aussitôt ces parties/repères.']
  }
, {
      operation: "Changer le type de la marque"
    , procedure: [
            'Il n’existe pas de moyen de changer le type d’une marque (pour le moment, mais c’est dans les tuyaux).',
            "Le seul moyen est de détruire la marque actuelle et d'en créer une nouvelle du type voulu."
            ]
  }
, {
      operation: "Définir la forme"
    , procedure: ["Cliquer sur le bouton 'Forme…'","Ajouter autant d'éléments que voulus","Cliquer sur les boutons ⍗ pour construire l'élément sur la table d'analyse (se mettre en grille magnétique pour assembler correctement les éléments)", "Cliquer sur les boutons ⎆ pour rejoindre les mesures de la partie"]
  }
, {
      operation: 'Enregistrement de l’analyse'
    , shortcut: '⌘ s'
    , procedure: [
            'Pour enregistrer l’analyse, cliquer sur le bouton «Sauver».',
            'Cela enregistre les marques d’analyse (les «tags»), la position des systèmes, les informations sur l’analyse ainsi que les préférences.'
            ]
  }
]


const ManuelShortcutsData = [
  {
      operation:'Enregistrer l’analyse'
    , shortcut: '⌘ s'
  }
, {
      operation: 'Déplacement des objets sélectionnés avec les flèches'
    , shortcut: '↑ ↓ ← →'
    , precision: 'En tenant ⇧, on augmente le pas, en tenant ⌥, on affine le pas'
  }
, {
      operation:'Verrouiller/déverrouiller les portées'
    , shortcut: 'l ("L" min.) [ne semble pas fonctionner]'
    , precision: "On peut aussi utiliser le bouton de pied de page."
  }
]
