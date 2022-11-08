module ScoreCutting
  class CommandLine
    def self.show_help
      clear
      less ScoreCutting::AIDE_SCORE_CUTTING
    end
  end #/class CommandLine

AIDE_SCORE_CUTTING = <<-TEXT
Aide ScoreCutting
=================

Cette app permet de découper une partition en systèmes à partir
d'une partition au format image (JPEG, PNG, TIFF).

Utilisation
-----------

* Préparer les images de la partition (si PDF) (cf. ci-dessous),
* ouvrir une fenêtre de Terminal au dossier contenant la partition
  originale.
* jouer la commande #{'score-cutting <image name>'.jaune}
> La partition s'ouvre dans le navigateur
* choisir les lignes de découpes en double-cliquant aux endroits
  voulus
* cliquer sur le bouton "Découper" et confirmer.
> La partition est découpée et les systèmes sont placés dans un
  dossier 'systems' au même niveau que la partition.

Préparation des images de la partition
--------------------------------------

On ne peut pas fournir à Score-cutting des PDF. Il faut donc souvent
les transformer en images ('convert' ne le fait pas assez bien pour 
le moment). Pour se faire :

* ouvrir le PDF dans Aperçu,
* sélectionner la première page,
* demander Fichier > Exporter…
* choisir JPEG, la meilleure qualité et 300ppp
* mettre un indice au nom (p.e. '-01')
* exporter,
> L'image est créée dans le dossier.
* recommencer l'opération pour chaque page.

Si la partition contient plusieurs pages, il faut utiliser la 
procédure ci-dessous.

À partir de plusieurs partitions
--------------------------------

Lorsqu'il y a plusieurs PDF pour la partition, régler le numéro du
premier système pour qu'il reparte au bon numéro : par exemple, si
le dernier système produit par la partition précédente était le 
système 7 alors commencer au 8e système pour la nouvelle partition.

TEXT

end #/module ScoreCutting
