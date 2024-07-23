# Tests de score-image

On teste l’application **`Score-Image`** à l’aide de tests d’intégration qui doivent produire des images conformes aux attentes sur toutes les fonctionnalités de l’application.

Le synopsis de test ressemble schématiquement à :

* l’application produit l’image à partir d’un fichier `.mus` contenu dans un dossier test,
* elle s’assure que le fichier SVG est bien produit
* elle fait son checksum et s’assure qu’il correspond au checksum enregistré dans le dossier du test.

Pour les tests négatifs (i.e. qui doivent produire une erreur) :

* l’application tente de produire l’image à partir du fichier `.mus`
* elle produit une erreur avec un code d’erreur
* ce code d’erreur (et éventuellement des messages précis) doit être trouvé dans un fichier **`FAILURE`** dans le dossier du test.



## Création d’un test

Quel que soit le test :

* Faire un sous-sous-dossier dans le dossier **`checksums_tests`**, dans sa catégorie la plus naturelle (*créer cette catégorie si nécessaire*)

* Créer un fichier **`.mus`** (par exemple **`main.mus`** avec le code mus à tester. Par exemple :

  ~~~
  --barres
  
  -> score
  c8 d e f
  ~~~

* Lancer ce test grâce à la commande **`score-image tests _`**

  > Ou, pour jouer spécifiquement ce test, jouer **`score-image tests /<bout-du-nom-propre>/`**

### … un test positif

* La première fois, le test produit un fichier **`CHECKSUM`** qui contient le checksum de l’image produite (pour un test positif).

* Si l’image SVG produite est conforme aux attentes, alors il n’y a rien à faire, on peut relancer le test, qui se comportera alors comme un test.

* Si l’image SVG n’est pas conforme aux attentes :

  * on détruit le fichier CHECKSUM
  * on corrige le texte de l’application pour que l’image soit conforme
  * on relance le test et on reprend.

### … un test négatif

* en cas d’erreur (ce qui est ok) :
  * relever le code de l’erreur dans le message donné en console
  * le placer dans un fichier **`FAILURE`** à la racine du test
  * relancer le test (qui doit alors passer)
* en cas de succès (donc d’erreur…)
  * modifier le code de l’application jusqu’à ce qu’il produise l’erreur attendue,
  * poursuivre avec la procédure ci-dessus.

## Statistiques

En plus de l’image produite, les tests s’assurent aussi que les statistiques sur les musiques (nombre de notes employées et durées totales) soient valides. 

Les résultats sont placés dans le dossier `stats` de chaque test. Le fichier **`GOOD-STATS.csv`** contient les informations attendues, qui ont été validées (et *doivent être* validées) manuellement pour chaque test.

La première fois qu’on lance le test, le fichier `stats/GOOD-STATS.csv` est produit et il faut vérifier s’il correspond à la réalité de la partition, en tenant compte de tous les cas possibles.

Contrairement aux images, lancer les tests avec l’option **`-d`** ne va pas détruire ce fichier, car cela détruirait toutes les vérifications qui ont été faites.
