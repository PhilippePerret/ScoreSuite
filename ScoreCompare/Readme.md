# ScoreCompare

Nouveau projet de la suite Score qui permettrait de comparer deux partitions, principalement dans le but de vérifier les erreurs au niveau de l’édition.

L’application s’appuierait sur les fichier XML produits par l’application [Audiveris](/Applications/Audiveris.app), en s’appuyant sur le [langage musicXML](https://usermanuals.musicxml.com/MusicXML/MusicXML.htm#EL-MusicXML.htm%3FTocPath%3DMusicXML%2520Reference%7CScore%2520Schema%2520(XSD)%7CElements%7C_____0).

## Produire le fichier XML

* Enregistrer la partition avec une très bonne qualité (~3000px de large)
* charger le fichier dans Audiveris (premier icône image)
* jouer le bouton « Transcribe book »
* exporter le résultat « Sheet > Export sheet as… »

## Lancer l’analyse du fichier XML

{à programmer, pour réduire le fichier à quelque chose de simple, comparable}

## Développements possibles

Si ça marche bien, il serait possible de produire un fichier `.mus` à partir de l’analyse faite du fichier. En suivant cette procédure :

* Analyse du fichier original dans Audiveris
* export du fichier XML
* analyse par ScoreCompare (lui donner un autre nom ? faire un autre outil ?)
* production d’une ébauche de fichier `.mus` à afficher mais déjà bien préparée.
