#!/usr/bin/env ruby
# encoding: UTF-8

=begin

  Pour le moment, jouer ce module ne fait que lister les différents
  composants de la suite.

=end
require_relative 'ScoreWriter/lib/required' # pour CLI_String

aide = <<-TXT

  /_/_/_/_/_/_/_/
 
   SCORE-SUITE

  \\_\\_\\_\\_\\_\\_\\_\\



 Score-suite est une suite d'applications pour faciliter le travail
 avec les partitions (extrait de segments, partition totale, analyse,
 etc.).

 La suite comprend les applications suivantes :

  ScoreWriter          #{'score-writer'.jaune}

    Pour composer le pseudo-code Lilypond permettant de produire
    l'image de la partition. Et produire l'image (score-image).

  ScoreImage           #{'score-image'.jaune}

    Pour transformer le pseudo-code Lilypond en image de partition.

  ScoreCutting         #{'score-cutting'.jaune}

    Pour découper une partition en systèmes.

  ScoreExtraction      #{'score-extract'.jaune}

    Pour extraire des segments de partitions, à partir de données
    de mesure produites avec ScoreWriter.

  ScoreAnalyse        #{'score-analyse'.jaune}

    Pour faire l'analyse d'une partition sur une table virtuelle.

  ScoreStats          #{'score-stats'.jaune}

    Pour produire les statistiques d'un morceau à partir de ses 
    notes dans LilyPond (note : le programme utilise ScoreImage)

Aide
----

En utilisant la commande #{'aide|help'.jaune} on peut obtenir l'aide
de toutes ces applications. Par exemple :

  #{'score-analyse help'.jaune} ou #{'score-analyse aide'.jaune}

TXT

less(aide)
