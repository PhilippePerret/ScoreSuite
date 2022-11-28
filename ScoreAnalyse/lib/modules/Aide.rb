# encoding: UTF-8

AIDE = <<-TEXT

  /_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
 
   SCORE-SUITE : SCORE ANALYSE

  \\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\_\\


  Application permettant de procéder à l'analyse d'un partition 
  quelconque en la "taguant".



  Ouverture d'une analyse
  =======================

    En ligne de commande
    --------------------

      * Ouvrir un Terminal au dossier contenant le dossier de 
        l'analyse,
      * jouer la commande #{'score-analyse <ID-analyse>'.jaune},
      => l'analyse se charge.

    Par le panneau information
    --------------------------

      * Lancer l'application,
      * ouvrir le panneau des informations sur l'analyse,
      * entrer le chemin d'accès absolu,
      * cliquer sur le bouton "Ouvrir" en regard,
      => L'analyse se charge.



  Création d'une analyse
  ======================

    Solution par assistant
    ----------------------

    * ouvrir un Terminal dans un dossier (par exemple le dossier qui
      concerne déjà la pièce à analyser)
    * jouer la commande #{'score-analyse <id_analyse>'.jaune}
      (cet identifiant ne doit contenir que des lettres, des chiffres
       le trait  d'union ou le trait plat)
    * confirmer que c'est bien une création qu'il faut faire,
    * suivre l'assistant jusqu'à la création complète.

    Solution "manuelle"
    -------------------

      * Créer un dossier portant l'ID de l'analyse,
      * créer dedans un dossier 'systems' (sans 'e'),
      * créer un fichier 'infos.yaml' contenant les informations
        qu'on peut trouver dans une des analyses modèles dans le
        dossier 'analyses' de l'application,
      * optionnellement, créer un fichier 'preferences.yaml' en
        s'inspirant du même fichier.
      * ouvrir un Terminal à ce dossier,
      * jouer la commande #{'score-analyse <ID-analyse>'.jaune}


    Solution par le panneau
    -----------------------
    
      * Lancer l'application (#{'score-analyse'.jaune}),
      * ouvrir le panneau des infos de l'analyse,
      * remplir tous les champs,
      * cliquer le bouton 'Créer nouvelle analyse',
      => L'application est créée.



  Destruction d'une analyse
  =========================

    Il suffit de détruire son dossier et l'analyse est définitivement
    détruite.


TEXT
