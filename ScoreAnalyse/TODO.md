# TODO VERSION 2

* Faire un style de texte qui fonctionne comme les parties, avec un texte dans un cadre (ou sur une ligne simplement) et un trait vertical qui descend sur la partition. Par exemple pour marquer l'entrée d'un sujet sur une fugue (contenu : "Entrée du Sujet 1")
* [bug] Les largeurs de parties (nom) ne doivent avoir une limite de largeur que si définie dans les préférences


## FONCTIONNALITÉS

  * [Au besoin] Pouvoir forcer l'association d'un tag à un autre système que son système "naturel" mais seulement lorsqu'il a un certain type.
  Mais attention, il faudrait une autre propriété que data.objets, qui est utilisée pour les associations volatiles, à chaque fois calculées au chargement de l'analyse.

  * Pour des cercles, des segments, etc., faire pareil que l'édition, mais ne mettre que :
    'seg' ou 'cir' ou 'text:Le texte à afficher' (pas PhilHarmonieFont, donc — maintenant, c'est Philutura ou quelque chose comme ça)
    -> préférences pour les tailles (ou utiliser resizeable de jQuery, qui serait pratique, ici)


# BUGS CORRIGÉS

* Première mise en place de l'export SVG
* "Désactivation" du clic quand on ouvre un panneau
* Replacement correcte de la cadence
* Hauteur du chiffre de la pédale ajutstée (line-height)
* Style à la volée corrigés
* Enregistrement et reconstruction de la ligne de prolongation
* Allongement de la poignée d'édition de la prolongation.
* Bon réglage de l'espace sous le système au chargement de la partition
* Quand on déplace un groupe de marque, celle qu'on a déplacé se déplace mal.
* Mauvais réglage du bouton pour verrouiller/déverrouiller le bloquage des systèmes.
