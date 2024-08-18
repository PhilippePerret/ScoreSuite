# Manuel du<br> langage `music-score`<br>(`.mus`)



[TOC]



## Introduction

### Note pour produire des images pour ce manuel

Pour produire facilement des images pour ce manuel :

* ouvrir un Terminal au dossier des images du manuel,

* jouer la commande :

  ~~~
  score-i[TAB] << CODE
  # ici le code mus
  # dont :
  
  -> nom-a-donner-a-image
  # code mus
  CODE
  ~~~

* récupérer l’image dans le dossier `scores` du dossier images du manuel,

* la glisser à l’endroit voulu dans ce manuel.

### Le langage music-score (`mus`)

Le langage `music-score` (maintenant la commande **`score-image`** ) est un langage de programmation qui permet de produire très facilement des images de partitions simples (simple portée ou portée piano — pour le moment) en utilisant dans son moteur le langage [LiliPond](http://www.lilypond.org).

Une page en `music-score` (langage **mus**) peut ressembler à :


~~~music-score
# Dans ma-musique.mus
--barres
--time
--piano

mes12==
a'8 b cis d cis4 cis
<a, cis e>1

mes13==
b'8 cis d cis b4 a
<b, d fis>1

mes14==
cis8 d cis b a4 g 
<cis, e gis>1

mes15==
d8 e fis g fis4 fis
<d, fis a>1

-> partition-12a15
--mesure 12
--proximity 7
mes12<->15
mes12<->15

~~~

<img src="./images/partition-12a15.svg" alt="partition-12a15" style="zoom:120%;" />

#### Production de l'image

Pour produire l’image issue de ce code, on a utilisé la commande **`score-image`** en ligne de commande avec un *heredoc*. Comme ceci :

~~~
> score-image << MUS
--barres
--time
--piano

mes12==
a'8 b cis d cis4 cis
<a, cis e>1

mes13==
b'8 cis d cis b4 a
<b, d fis>1

mes14==
cis8 d cis b a4 g 
<cis, e gis>1

mes15==
d8 e fis g fis4 fis
<d, fis a>1

-> partition-12a15
--mesure 12
--proximity 7
mes12<->15
mes12<->15
MUS
~~~

> Noter que pour taper **`score-image`** il suffit de taper `score-i` puis la touche tabulation. C’est valable pour toutes les applications de la suite Score (*Score-Builder*, *Score-Numbering*, etc.).



#### Détail du code



~~~music-score

# Options préliminaires
# ---------------------
# Option pour ouvrir le fichier après fabrication
--open
# Option pour afficher les barres de mesure
--barres
# Option pour afficher la métrique
--time
# ou (pour ne pas le mettre)
--time OFF 
# ou (pour la préciser)
--time 3/4
# Option indiquant qu'il s'agit d'une partition de piano
--piano

# Définition des mesures
# -----------------------
# Définition de la mesure 12
# La première ligne contient la main droite
# La seconde ligne définit la main gauche
mes12=
a'8 b cis d cis4 cis
<a, cis e>1

mes13=
etc.

# Définition des images (systèmes)
# --------------------------------
# Le nom de l'image SVG (affixe)
-> partition-12a15
# Le numéro de mesure à indiquer au début
--mesure 12
# L'éloignement horizontal entre les notes
--proximity 7
# Indique de la mesure 12 à la mesure 15, à la
# main gauche et à la main droite
mes12<->15

~~~

#### Code par paragraphe

Il est important de comprendre que ce code fonctionne **par paragraphe**, ce qui signifie que les éléments sont considérés comme « entier » lorsqu’ils ne sont séparés par aucune ligne vierge. 

Cela permet entre autres choses d’avoir des partitions multipistes. Par exemple, un trio sera indiqué par :

~~~
# trio
-> trio
a b c d
a2.   a'
d8 d d d d d
~~~

… qui produira :

<img src="./images/trio-sans-staves-keys.svg" alt="trio" style="zoom:120%;" />

> Tous les exemples de code donnés dans ce manuel font l’objet d’un test « checksum ». Pour lancer tous ces tests, il suffit de jouer en ligne de commande : **`score-image tests -dir=manuel`**.

Cela comporte quelques inconvénients :

Parmi les inconvénients, il faut faire attention à bien séparer les définitions. Par exemple :

~~~
mesure1=
a b c d
mesure2=
e f g f
~~~

… ne produira pas les deux variables `mesure1` et `mesure2`, mais seulement la variable `mesure1` avec une erreur de `mesure2` inconnue.

Seule tolérance, pour la définition des noms d’image, reconnaissable à **`->`** en début de ligne :

~~~
mesure1=
a b c d
-> image_tolerable
mesure1
~~~

Le code ci-dessus sera considéré comme :

~~~
mesure1=
a b c d

-> image_tolerable
mesure1
~~~



### Rognage automatique de l'image

Après la production du code, l’image est automatiquement rognée par **Inskape** pour ne laisser aucun air autour.

---

### Images produites

Un unique fichier `.mus` peut définir une ou plusieurs images. Par exemple, un fichier contenant le code suivant :

~~~
# in durees.mus

-> image1
c d e f

-> image2
c2 d e f

-> image3
c1 d e f
~~~

… produira 3 images contenant leur code respectif, `durees/image1.svg`, `durees/image2.svg` et `durees/image3.svg`.

---

###  Dossier et nom des images produites

Par défaut (car il est possible de le déterminer explicitement), le nom des images et le dossier de leur destination sont définis par le nom du fichier `.mus` contenant le code music-score.

Soit le nom de fichier **`partition.mus`** contenant le code *music-score*.

Un dossier **`partition`** sera créé au même niveau que ce fichier, et contiendra les images produites. Chaque ligne contenant du code *mus* produira une image.

Les images porteront le nom **`partition-1.svg`**, **`partition-2.svg`**… **`partition-N.svg`** et seront placées dans le dossier `partition` ci-dessus.

---

<a name="include"></a>

## Inclusions

Dans les fichiers `.mus`, on peut inclure d’autres fichiers `.mus` à l’aide de la commande :

~~~
INCLUDE path/to/musFile
~~~

Le chemin `path/to/musFile` peut être relatif au fichier maitre ou relatif au dossier `libmus` de l’application ***Score-Image*** qui définit des librairies standards.

La première librairie à avoir été créée est la librairie **`piano/Alberti.mus`** qui définit toutes les basses d’Alberti dans des variables.

Un fichier inclus peut définir n’importe quoi, pourvu que ce soit du code `.mus` à commencer par :

* des options,
* des variables,
* des partitions.

Pour la gestion des variables, voir [Gestion dynamique des variables](#dynamic-variable).

---

## Statistiques

Le programme permet aussi de faire des **statistiques sur les notes** (nombre et durée). Il suffit :

* d’ajouter l’option `-s`/`--stats` à la ligne de commande (ou de mettre l’option `--stats` dans le fichier mus,
* de definir l’option `-t`/`--tempo=<val>[T]` en ligne de commande ou dans le code mus, pour calculer les durées réelles.

L’option  et le tempo peut s’ajouter aussi directement dans le fichier **`.mus`** avec l’option : 

~~~
--stats
--tempo 60T
~~~

Pour le tempo, voir [ici](#tempo).

Ces options produisent un dossier **`stats`**  contentant 4 fichiers avec toutes les notes classées 1) par ordre alphabétiques, 2) pour nombre, 3) par durée, 4) en fichier CSV pour travail avec excel.

> Note : cette option peut s’utiliser aussi avec l’application `score-extract` (**ScoreExtraction**) avec les mêmes options.

### Remarques sur les statistiques

Les statistiques relèvent donc la fréquence d’utilisation de chaque note de la partition, ainsi que leur durée d’utilisation. Elles sortent le nombre de notes utilisées ainsi que la durée totale de chaque note mise bout-à-bout.

Certains partis-pris ont été adoptés :

* toutes **les répétitions** sont prises en compte (à l’avenir, si c’est nécessaire, on pourra imaginer une option qui permette de ne pas les prendre en compte)
* pour **les ornements**, on ne compte que la note elle-même (sauf pour les « grace notes » — cf. ci-dessous). En effet, comment considérer une trille par exemple ? Elle devrait comporter deux notes (les deux notes utilisées pour triller) et un certain nombre d’itérations indéfinissable de façon stricte avec des durées tout aussi indéfinissables. On pourrait se retrouver aussi avec des statistiques faussées qui amplifieraient l’utilisation d’une note simplement parce qu’elle est produite par la trille (on pourrait objecter que cette note n’est pas « amplifiée » puisqu’elle est, de fait, jouée dans la musique…).
* on fait une exception pour **les *grace notes*** (les ***petites notes***), donc, c’est-à-dire les notes explicitement écrites, avec une durée définie, qui sont prises en compte. Conformément à la tradition de jeu, pour l’appogiature « barrée » (petites notes barrées), on définit sa durée au quart de la note qui la suit, en retirant cette durée à la note suivante.

<a name="tempo"></a>

### Le Tempo

Le tempo (qui sert aussi pour jouer le fichier MIDI) doit toujours se mettre **en valeur de noire** (même si le tempo n’est pas à la noire). Si le tempo est écrit dans une autre valeur (blanche, croche…), alors faire la transposition (diviser par deux si c’est en croche, multiplier par deux si c’est en blanche).

On ajoute “**T**” au tempo lorsque c’est un rythtme ternaire (on met alors en tempo la valeur de la **noire pointée**).

Par exemple, pour une 6/8 où la noire pointée (le temps) devra être joué à 100, on indiquera :

~~~
--tempo 100T
~~~

Pour une mesure à 3/8 où les temps (donc la croche) doit être jouée à 100, on indiquera :

~~~
--tempo 33T
~~~

Puisqu’une noire pointée, ici durera trois fois plus de temps qu’une croche.

---

<a id="options"></a>

## Options principales

Toutes les options dont nous allons parler peuvent être utilisées au début du code ou à n’importe quel endroit du fichier pour être modifiées à la volée. Par exemple, si on veut que les premières images soient produites sans barres de mesures, on ajoutera en haut du fichier l’option **`--barres OFF`** et si à partir d’une image on en veut, on pourra poser `--barres` et remettre plus loin `--barres OFF` pour spécifier qu’il faut à nouveau ne plus utiliser les barres de mesure.



> Pour désactiver une option (après l'avoir activée ou pas), il faut utiliser :
> `--<option> OFF`
>
> Par exemple :
>
> **`--barres OFF`**
>
> … pour ne plus afficher les barres de mesure pour toutes les images suivantes dans le fichier mus.

| <span style="display:inline-block;width:200px;">Effet recherché</span> | <span style="white-space:nowrap;display:inline-block;width:240px;">Option</span> | <span style="display:inline-block;width:120px;">Notes</span> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Suppression de la gravure des barres                         | **`--barres OFF`**                                           |                                                              |
| Ré-affichage des barres de mesure                            | **`--barres`**                                               | S’emploie forcément après un `--barres OFF`, puisque par défaut les barres sont toujours gravées. |
| Afficher (ou non) la métrique                                | **`--time`**<br />**`--time OFF`**<br />**`--time 3/4`**     |                                                              |
| Ne traiter que les images inexistantes                       | **`--only_new`**                                             | Dans le cas contraire, toutes les images seront toujours traitées, qu’elles existent ou non, ce qui peut être très consommateur en énergie. |
| Ne pas afficher les hampes des notes                         | **`--no_stem`**                                              |                                                              |
| Transposition du fragment                                    | **`--transpose <from> <to>`**                                | Par exemple, `--transpose bes c'` va transposer le fragment, qui est en SI bémol, en do, en prenant les notes les plus proches. |
| Taille de la page                                            | **`--page <format>`**                                        | Par défaut, la partition s’affiche sur une page A0 en format paysage, ce qui permet d’avoir une très longue portée.<br />`<format>` peut avoir des valeurs comme `a4`, `b2` etc. |
| Espace vertical entre les portées                            | **`--staves_vspace <x>`**                                    | Pour avoir l’’espace normal, mettre 9. Au-delà (11, 12 etc.) on obtient un écart plus grand que la normale.<br />“Staves vspaces” signifie (espace vertical entre les portées) |
| Espace vertical entre les systèmes                           | **`--systems_vspace`**                                       |                                                              |
| Produire le fichier MIDI                                     | **`--midi`**                                                 | Régler la valeur de tempo ci-dessous pour avoir le tempo.    |
| Ouvrir le fichier image après production                     | **`--open`**                                                 | Ouvre tout de suite le fichier dans Affinity Designer, ce qui permet de l’améliorer si nécessaire. |
| Conserver le fichier LilyPond (`.ly`)                        | **`--keep`**                                                 | Cela permet de tester du code ou de voir où se situe un problème compliqué. |
| Détail des erreurs                                           | **`--verbose`**                                              | Permet de donner les messages d’erreur dans leur intégralité et notamment avec leur backtrace. |
| Portées multiples (cf. ci-dessous)                           | **`--staves_keys G,A,…`**<br />**`--staves_names 1re,2e…`**  | Permet de produire des portées empilées avec les clés et les noms voulus. |
| Nommage de la portée                                         | **`--staves_names <nom>`**                                   | Permet, notamment pour le piano, de préciser qu’il faut indiquer le nom (simplement en indiquant `--staves_names Piano`) |
| Taille de la portée                                          | **`--staff_size <x>`**                                       | Définit la taille de la portée (et de tous ses éléments). La valeur par défaut est **20**. |
| Affichage des numéros de page                                | **`--page_numbers <v>`**                                     | `<v>` peut-être `OFF` (pas de numéro de page), `arabic` (chiffres arabes, `roman-ij-lower` (romain minuscules avec ligature), `roman-ij-upper` (romain majuscule avec ligature), `roman-lower` (romain minuscule sans ligature), `roman-upper` (romain majuscule sans ligature) |
| Statistiques                                                 | **`--stats`**                                                | Produit toujours les statistiques en même temps que la partition, dans un dossier `stats`. |
| Tempo pour statistques et le fichier MIDI                    | **`--tempo <valeur>`**                                       | Ne sert que pour les statistiques et le fichier MIDI. Si on doit ajouter l’indication « noire = valeur » au-dessus de la première portée, il ne faut pas le faire avec *ScoreImage*. |
|                                                              |                                                              |                                                              |

---

## Détail des options

### Numérotation des pages

On règle la numérotation des pages avec l’option **`page_numbers`**

~~~
--page_numbers OFF 							# pas de numérotation
--page_numbers arabic 					# chiffres arabes (défaut)
--page_numbers roman-lower			# Romains minuscules
--page_numbers roman-upper			# Romains majuscules
--page_numbers roman-ij-lower		# Romains minuscules avec ligatures
--page_numbers roman-ij-upper		# Romains majuscules avec ligatures
~~~



<a id="options_portees"></a>

### Portées multiples

On définit les portées multiples à l’aide de  **`--staves_keys`** (pour les clés) et **`--staves_names`** (pour les noms — voir aussi [Nommage des portées](#nommage-staff)).

On doit les définir **de bas en haut**. C’est-à-dire que si on veut un violon au-dessus d’un piano, on doit définir :

~~~
--staves 3
--staves_keys F,G,G
--staves_names Piano,Piano,Violon
~~~

Le simple fait qu’on trouve deux fois de suite le mot « piano » indique à ScoreImage de relier les deux portées.

> Les noms des instruments doivent être mis en capitales si on veut qu’ils soient en capitales sur la partition.

En fait, ci-dessus, la marque « Piano,Piano » (qui pourrait être aussi « PIANO,PIANO » indique à ImageScore qu’on a une portée de piano. Il produit alors deux portées reliées dans un système propre au piano, avec une accolade, et une portée de violon. On l’appelle une « sonate avec piano » (sonate with piano).

<a name="systems-vspace"></a>

#### Espacement entre les systèmes

L’espace vertical entre les systèmes se définit à l’aide de l’option **`systems_vspace`**.

Par exemple :

~~~
--systems_vpace 30
~~~

Pour l’espacement vertical entre les portées d’un système, cf. ci-dessous.

<a name="staves-vspace"></a>

#### Espacement entre les portées

L’espace vertical entre les portées se définit à l’aide de l’option **`staves_vspace`**. 

Par exemple :

~~~
--staves_vspace 40
~~~

Pour l’espacement vertical entre les systèmes, cf. [Espacement entre les systèmes](#systems-vspace).

---

#### Taille des portées

La taille des portées se règle à l’aide de l’option **`--staff_size`** suivie de la valeur à lui donner. La valeur par défaut est 20.

~~~
--staff_size 22.5
~~~

<a name="measure-number"></a>

#### Numérotation des mesures

Par défaut, LilyPond et donc *ScoreImage* numérote les mesures, au début de chaque système.

Pour supprimer toute numération, utiliser l’option :

~~~
--mesure OFF
~~~

Pour partir d’une autre mesure que 1, utiliser :

~~~
-> mon_image
--mesure 12
c d e f
~~~

La numérotation pour le code ci-dessus commencera à partir de la mesure 12.

Pour que les numéros se fassent **de 5 en 5** ajouter :

~~~
--number_per_5
~~~

Par défaut, les numéros de mesure se mettent au-dessus de la portée. Pour les mettre en dessous, utiliser l’option :

~~~
--measure_number_under_staff
~~~



<a name="nommage-staff"></a>

#### Nommage des portées

On peut nommer les portées à l’aide de l’option **`--staves_names`** (cf. [Portées multiples](#options_portees)).

On peut ajouter un vrai dièse ou un vrai bémol dans le nom en utilisant **`_b_`** pour le bémol et **`_d_`** ou **`_#_`** pour le dièse. Ils seront remplacés par de vrais signes bémols et dièse, pour un affichage parfait.

#### Groupement des portées

Il existe plusieurs façons de relier les portées et les barres de mesure. On trouve les valeurs suivantes :

* Portées
  * non reliées
  * reliées par un trait simple (type neutre)
  * reliées par un trait + crochet oblique (type quatuor, chœur)
  * reliées par un trait + accolade (type piano)
* Barres de mesure
  * reliées entre elles
  * non reliées entre elles

Par défaut, on utilise : **portées reliées par un trait simple avec les barres de mesure non reliées**.

<img src="./images/main-group.svg" alt="score" style="zoom:120%;" />

Quand on veut un **crochet oblique**, on utilise « **`[...]`** ». Par exemple :

~~~
--staves_names [Cb., Alto, Vl.]
--staves_keys  F, UT3, G
~~~

… produira :

<img src="./images/main-group-crochet.svg" alt="main-group-crochets" style="zoom:120%;" />



Quand on veut une accolade, on utilise « **`{...}`** ». Par exemple :

~~~
--staves_names {Cb. Alto., Vl.}
--staves_keys  F, UT3, G
~~~

… produira :

<img src="./images/main-group-accolade.svg" alt="main-group-accolade" style="zoom:120%;" />

Comme on peut le voir, par défaut, les barres de mesure sont reliées entre elles. Pour utiliser **les barres de mesure non reliées**, on ajoute un « **`-`** » après l’accolade ou le crochet.

Par exemple : 

~~~
--staves_names [-Cb., Alto, Vl.]
--staves_keys  F, UT3, G
~~~

… produira :

<img src="./images/main-group-crochet-unlinked.svg" alt="score" style="zoom:120%;" />

Tandis que :

~~~
--staves_names {-Cb. Alto., Vl.}
--staves_keys  F, UT3, G
~~~

… produira la même chose que les accolades seules, puisqu’**un groupement de ce type relie toujours ses barres de mesure**.

Si tous les instruments du groupe portent le même nom, il est utilisé comme **nom du groupe** et les portées ne sont plus nommées individuellement.

Comme dans :

~~~
--staves_names {Bois, Bois, Bois}
--staves_keys F, G, G
~~~

… qui produira :

<img src="/Users/philippeperret/Programmes/ScoreSuite/ScoreImage/Manuel/images/same-name-for-main-group.svg" alt="score" style="zoom:120%;" />

##### Groupes à l'intérieur d'un même système

On peut utiliser de la même manière les regroupements de portées à l'intérieur même d'un groupe, avec les accolades et les crochets, en indiquant par un « moins » l’absence de barres de mesure reliées.

Par exemple :

~~~
--staves_names Cb. {Piano, Piano}, Vl.
--staves_keys  F, F, G, G
~~~

… produira :



#### Cas spécial du PIANO

Le cas du piano est spécial car il possède sa propre option :

~~~mus
--piano
~~~

C’est une écriture simplifiée pour :

~~~mus
--staves_names {Piano, Piano}
--staves_keys F, G
~~~

Mais plus encore, ça simplifie l’écriture quand il y a des variables, puisque dans la définition de la partition on n’est pas contraint de préciser les deux mains :

~~~mus
--barres
--piano


mesure1=
c'4 d e f
c,1

mesure2=
g a b c
g1

-> score
mesure1 mesure2
~~~

On pourra cependant utiliser l’écriture normale :

~~~mus
--barres
--piano


mesure1=
c'4 d e f
c,1

mesure2=
g a b c
g1

-> score
mesure1 mesure2
mesure1 mesure2
~~~

… notamment dans le cas d’une utilisation d’autres variables. Par exemple :

~~~mus
--barres
--piano

mesure1=
c'4 d e f
c,1

mesure2=
g a b c
g1

mesure3=
r1
c,2 c'

-> score
mesure1 mesure2 mesure1
mesure1 mesure2 mesure3
~~~

… qui produira :

<img src="./images/piano-mesures-croized.svg" alt="score" style="zoom:120%;" />

> Noter ci-dessus que c’est seulement la main gauche de la mesure 3 qui a été utilisé, alors que la main droit a été empruntée à la mesure 1, conformément à la définition de la partition.



### Fichier de sortie MIDI

Grâce à l’option **`--midi`** dans le code mus on peut produire un fichier MIDI à écouter (dans VLC par exemple).

Cette option marche de paire avec l’option **`--tempo`** qui détermine le tempo de l’écoute.

Par exemple : 

~~~mus
# ./score.mus

--midi
--tempo 120

c d e f
~~~

… produira un fichier `./score/score.midi` qu’on pourra écouter dans VLC et qui jouera les notes au rythme de 120 à la noire.

À voir aussi : [le tempo](#tempo).

**Pour produire le fichier MIDI seul** l’option `--midi` dans le code MUS ne suffit pas. Il faut l’utiliser dans la ligne de commande. Par exemple :

~~~
score-image moncode.mus -midi
~~~

> Bien noter que la commande ci-dessus ne produira QUE le fichier midi (à partir du code du fichier « moncode.mus »).



---

<a id="options_musicales"></a>

### Options musicales

| <span style="display:inline-block;width:240px;">Effet recherché</span> | <span style="white-space:nowrap;display:inline-block;width:160px;">Option</span> | <span style="white-space:nowrap;display:inline-block;width:50%; ">Notes</span> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Définir la tonalité (armure du morceau)                      | **`--tune`** ou **`--key`** suivi de `A-G#b`                 | La lettre doit obligatoirement être en majuscule. Contrairement à Lilypond, qui permet d’indiquer les tonalités mineures (pour le chiffrage des chorus par exemple), ici, on met vraiment l’armure de la portée. |
| Numérotation des mesures                                     |                                                              | Cf. [Numérotation des mesures](#measure-number)              |
| Espacement horizontal entre les notes                        | **`--proximity XXX`**                                        | `XXX` peut avoir une valeur de 1 à 50.<br />Cf. les [exemples de proximités ci-dessous](#exemple_proximity) |



<a id="exemple_proximity"></a>

#### Exemples de proximités de notes (rendu)

| <span style="display:inline-block;width: 150px">Valeur de `proximity`</span> | Rendu                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Non définie                                                  | <img src="images/exemples/sans-proximity.svg" style=" width:400px;" /><br />*(correspond ici à la proximité 5)*|
| **`--proximity 1`**                                          | <img src="images/exemples/proximity-prox1.svg" style=" width:300px;" /> |
| **`--proximity 5`**                                          | <img src="images/exemples/proximity-prox5.svg" style=" width:400px;" /> |
| **`--proximity 10`**                                         | <img src="images/exemples/proximity-prox10.svg" style=" width:500px;" /> |
| **`--proximity 20`**                                         | <img src="images/exemples/proximity-prox20.svg" style=" width:650px;" /> |
| **`--proximity 50`**                                         | <img src="images/exemples/proximity-prox50.svg" style=" width:800px;" /> |
|                                                              |                                                              |



Espacement horizontal automatique entre les notes--proximity xxx

(pour un espacement ponctuel, cf. la suite)

Note : c'est une option "ponctuelle", qui est abandonnée dès la
première utilisation.

Grâce à l'option --proximity, qui peut avoir les valeurs :
1 Le plus proche
4 Proche de la valeur naturelle, à voir
10Un peu éloigné
50Le plus éloigné
… on peut jouer sur le traitement de l'espacement entre les notes.
C'est très utile lorsque l'on veut par exemple mettre quatre mesu-
res sur la même ligne mais qu'elles passent à la ligne.

~~~
-> partition-tres-serree
--page a3
--proximity 10
mesures1<->4
# => Entrainera un resserrement maximal entre les portées
~~~

Pour produire plusieurs images avec des espacements différents
(pour choisir le meilleur par rapport à l'affichage), on utilise
la formule : --proximity 1-10
Cela produira toutes les proximités de 1 à 10

Espacement entre les notes--<..>hspace

Parfois, on peut avoir besoin d'augmenter l'espacement entre les
notes individuelles. On peut le faire, de façon de plus en plus
importante avec les options :
--mini_hspace
--hspace
--big_hspace
--biggest_hspace
On les désactive pour la suite en ajoutant OFF comme pour toutes
les options.
--hspace OFF

---

## Commandes

Le code `MUS` répond à quelques commandes permettant de jouer sur la compilation.

Ces commandes sont reconnaissables au fait qu’elles sont toujours en capitales.

### Commande de déclenchement de la compilation (START/STOP)

Lorsqu’un fichier est volumineux et contient de nombreuses images, on peut vouloir se concentrer parfois seulement sur quelques unes d’entre elles, sans avoir à les produire toutes à chaque fois, ou sans avoir à détruire celles qu’on veut revenir quand on utilise l’[option `only_new`](#option-only_new).

On utilise alors la commande **`START`** pour indiquer le début du travail et la commande **`STOP`** pour indiquer où le fichier.

Par exemple, le fichier :

~~~
# in durees.mus

-> image1
c8 d e f

START

var=
c4 d e f

-> image2
var

STOP

-> image3
c2 d e f
~~~

… ne produira que l'image « `durees/image2.svg` » .

> Noter que la commande se trouve sur une lignes « isolée », conformément au principe des paragraphes.
>
> Noter qu’il faut inclure la définition des variables dans le bloc « START ... STOP ». Dans le cas contraire, une erreur de variable inconnue sera produite.



---




#### Nom du fichier de l'image (définition explicite)

Si une ligne commençant par **`-> `** est placée avant l'expression musicale, elle contiendra le nom du fichier de sortie. 

Par exemple :

~~~
-> monfichier
c d e f
~~~

… placera dans le fichier /<dossier>/monfichier.svg la partition 
résultant de l'expression `c d e f`.

---

## LANGAGE MUSIC-SCORE (mus)

La partie ci-dessous présente les termes propres au langage « music-score ».

---

### Handy code

#### Répétition d’une note avec `<note>*N`

De la même manière qu’on peut faire `r8*4` en pur Lilypond, on peut répéter n’importe quelle note avec durée à l’aide de l’astérisque. Par exemple :

~~~
cis16.*3
~~~

… produira le code

~~~
cis16. cis16. cis16.
~~~

> Noter que pour éviter toute confusion, cette possibilité se limite strictement à des notes avec ou sans altérations et pouvant définir leur durée. Tout autre groupe — par exemple présentant le doigté ou l’articulation — sera ignoré. Il faut alors utiliser d’autres moyens de répétitions (cf. ci-dessous).

#### Répétition d’un code avec `% ... %N`

On peut utiliser le gabarit  :

~~~
% ... %N
~~~

… pour répéter un nombre illimité de fois un motif.

Par exemple, pour répéter 8 fois la séquence **`c8 d e`**, il suffit de faire :

~~~
% c8 d e %8
~~~

Si le segment répété doit se trouver à une octave particulière, on peut enrouler le code dans un **`relative`** :

~~~
\relative c,, { % c8 d e %8 }
~~~

Mais on peut le faire plus simplement avec :

~~~
\cle F % c,,8 d e %4
~~~

… car l’octave de départ sera supprimée pour donner le code :

~~~
\cle F c,,8 d e c d e c d e c d e
~~~

… qui produira :

<img src="./images/repetition-same-octave.svg" alt="repetition-same-octave" style="zoom:120%;" />

Il est important, néanmoins, de surveiller l’octave à la fin de la chaine, car si on fait :

~~~
\cle F % c,,8 e g %3
~~~

… on produira le code :

~~~
\cle F c,,8 e g c e g c e g
~~~

… qui verra monter sans redescendre l’arpège de Do majeur, car le deuxième Do repartira à l’octave du Sol précédent, etc. :

<img src="./images/montee-octaves.svg" alt="montee-octaves" style="zoom:120%;" />

Dans ce cas, on peut préférer utiliser avec plus de sécurité le code normal de Lilypond :

~~~
\cle F \repeat unfold 3 { c,,8 e g }
~~~

… qui produira : 

<img src="./images/repeat-unfold.svg" alt="repeat-unfold" style="zoom:120%;" />




---

### Notation LilyPond simplifiée

Cette section présente les notations de l'expression pseudo-lilypond qui  diffèrent du langage original (toujours pour simplifier).

#### Barres de reprise


| <span style="display:inline-block;width:200px;">Objet</span> | Code      | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | --------- | ------------------------------------------------------------ |
| Début de reprise                                             | **`|:`**  |                                                              |
| Fin de reprise                                               | **`:|`**  |                                                              |
| Fin et début de reprise                                      | **`:|:`** |                                                              |
| (*Code Lilypond pour les autres barres*)                     |           |                                                              |
| Fin de pièce                                                 | **`|.`**  |                                                              |
| Séparation de partie                                         | \|\|      |                                                              |

#### 1re, 2e, etc. fois dans les reprises

Les premières, deuxième, etc. fois se gèrent à l’aide **`|<X>`** où `<x>` est le numéro de l’alternative : 

~~~
|:  .... |1 ... |2 ... |3,4 ... :|5 ... |6,7 || suite 
~~~

> Note 1 :
>
> ​	La barre « **`||`** » délimitant la dernière fois peut être aussi une autre reprise « **`|:`** » ou une barre de fin « **`|.`** ».
>
> Note 2 :
>
> ​	Il peut ne pas y avoir de barre de reprise de début, lorsqu’on revient au début pour faire la reprise.

---

#### Clé de l'expression

On peut utiliser les marques normale de LilyPond mais il peut être
plus pratique d'utiliser :

| <span style="display:inline-block;width:200px;">Objet</span> | Code         | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ------------ | ------------------------------------------------------------ |
| <img src="images/exemples/cle-de-sol-2e.svg" style="  width:150px;" />                 |      **`\cle G`**        |      Clé de SOL 2<sup>e</sup> ligne                                                          |
| <img src="images/exemples/cle-de-fa-4e.svg" style="  width:150px;" /> | **`\cle F`** | Clé de FA 4<sup>e</sup> ligne                                    |
| <img src="images/exemples/cle-de-sol-1ere.svg" style="  width:150px;" />                 |      **`\cle G1`**        |      Clé de SOL 1<sup>ère</sup> ligne                                                          |
| <img src="images/exemples/cle-de-fa-3e.svg" style="  width:150px;" />                 |      **`\cle F3`**        |      Clé de FA 3<sup>e</sup> ligne                                                          |
| <img src="images/exemples/cle-ut-1ere.svg" style="  width:150px;" />                 |      **`\cle UT1`**        |      Clé d'UT 1<sup>ère</sup> ligne                                                          |
| <img src="images/exemples/cle-ut-2e.svg" style="  width:150px;" />                 |      **`\cle UT2`**        |      Clé d'UT 2<sup>e</sup> ligne                                                          |
| <img src="images/exemples/cle-ut-3e.svg" style="  width:150px;" />                 |      **`\cle UT3`**        |      Clé d'UT 3<sup>e</sup> ligne                                                          |
| <img src="images/exemples/cle-ut-4e.svg" style="  width:150px;" />                 |      **`\cle UT4`**        |      Clé d'UT 4<sup>e</sup> ligne                                                          |
| <img src="images/exemples/cle-ut-5e.svg" style="  width:150px;" />                 |      **`\cle UT5`**        |      Clé d'UT 5<sup>e</sup> ligne                                                          |

#### Tonalité de l’expression (armure)

Cf. [les options musicales](#options_musicales).

#### Instruments transpositeurs

Le traitement des instruments transpositeurs est extrêmement simple avec *music-score* : il suffit d’indiquer **`\trans`** suivi de la note de transposition (telle quelle) pour produire les bonnes notes avec la bonne armure.

Par exemple, pour une clarinette en La (A), il suffit d’indiquer **`\trans a`** :

~~~
-> score
\trans a { c d e f }
~~~

Exemple avec un saxophone en Eb, un cor anglais (qui est en F), une clarinette en Sib, une flûte :

~~~
--barres
--staves_names Sax Eb, Cor A., Cl.(Bb), Fl.
--staves_keys  G, G

fl=
e’1

cl=
c4 d e f

cor_anglais=
c4 e g c

sax=
g’4 f e d

-> score
fl
\trans bes { cl }
\trans f { cor_anglais }
\trans ees { sax }

~~~

… produira la partition :



<center>
<img src="./images/instruments-transpositeurs.svg" >
<span>  qui sonnera  </span>
<img src="./images/no-transposition.svg" >
</center>



#### Numéro de mesure

Cf. [les options musicales](#options_musicales).


#### Triolet, quintolet et septolet

On les notes  `3{note<duree> note note}`

| <span style="display:inline-block;width:200px;">Objet</span> | Code                           | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ------------------------------ | ------------------------------------------------------------ |
| <img src="images/exemples/triolets.svg" style="  width:200px;" /> | **`3{note<duree> note note}`** | TODO : il faudra traiter les quintuplet et autres sextolets de la même façon. |



#### Ornements et signes d’interprétation

| Objet | Code           | Description                                                  |
| ----- | -------------- | ------------------------------------------------------------ |
|       | c\mordent      | Mordant inférieur (au-dessus de la note)                     |
|       | c_\mordent     | Mordant inférieur sous la note                               |
|       | c\mordentb     | Mordant inférieur avec note bémolisée (au-dessus de la note)<br />Le bémol est le « b » après « mordent » |
|       | c\mordent#     | Mordant inférieur avec note diésée (au-dessus de la note)<br />Le dièse est le « # » après « mordent » |
|       | c\mordentn     | Mordant inférieur avec note bécarisée (au-dessus de la note)<br />Le bécarre est le « n » après « mordent » (« n » pour « natural ») |
|       | c\prall        | Mordant supérieur (au-dessus)                                |
|       |                | Tout comment pour `\mordent` on peut utiliser, pour altérer les notes à jouer :<br />`c\prallb`, `c\prall#`, `c\pralln` et pour la note en dessous : `c\prall/b` `c\prall/#` et `c\prall/n`.<br />Pour le moment, on ne peut pas altérer les deux notes, mais plus tard, on pourra faire :<br />`c\prall#/#` |
|       | c\prall#       | Mordant supérieur diésé                                      |
|       | c\pralln       | Mordant supérieur bécarisé                                   |
|       | c_\prall       | Mordant supérieur (sous la note)                             |
|       | c\turn         | Gruppeto (sur la note)                                       |
|       |                | Tout comment pour `\mordent` on peut utiliser, pour altérer les notes à jouer :<br />`c\turnb`, `c\turn#`, `c\turnn`. |
|       | c_\turn        | Gruppeto (sous la note)                                      |
|       | c\reverseturn  | Gruppeto inversé                                             |
|       | c_\reverseturn | Gruppeto inversé (sous la note)                              |
|       | c\fermata      | Point d’orgue                                                |
|       | c_\fermata     | Point d’orgue en dessous                                     |

Pour d’autres ornements, voir [https://lilypond.org/doc/v2.21/Documentation/notation/list-of-articulations](https://lilypond.org/doc/v2.21/Documentation/notation/list-of-articulations).

Voir aussi [Marques d’expression](https://lilypond.org/doc/v2.24/Documentation/notation/expressive-marks-attached-to-notes).

#### Trilles


| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:300px;">Code</span> | <span style="display:inline-block;width:200px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
| <img src="images/exemples/trille.svg" style="  width:120px;" /> | **`\tr(c') `**                                              | Noter la note trillée entre parenthèses.                     |
| <img src="./images/trille_au_dessous.svg" alt="trille_au_dessous" style="width:120px;" /> | **`\_tr(c1')`**                                             | Pour forcer la trille en dessous                             |
| <img src="./images/trille_au_dessus.svg" alt="trille_au_dessus" style="width:120px;" /> | **`<< d'2 // \^tr(a) >>`**                                  | Pour forcer la trille au-dessus. Bien sûr, c’est juste pour forcer la trille à s’afficher par défaut en dessous (et donc voir l’effet du circonflexe) que l’exemple ci-contre a été donné. Il n’est pas utilisable dans la réalité, puisqu’on penserait que c’est le Ré qui est trillé. |
| <img src="images/trille-lied.svg" style="  width:140px;" />  | **`\tr(aes8.) ( g32 aes)`**                                 | Noter la parenthèse qui commence la liaison sur la note triée qui est “détachée” de la trille. Sinon la trille serait mal interprétée |
| <img src="images/exemples/trille_note_precise.svg" style="  width:120px;" /> | **`\tr(cis' dis) `**                                        | Pour triller avec une autre note que la note naturelle.      |
| <img src="images/exemples/trille_longue.svg" style="  width:100%;" /> | **`\tr(c'1)- c a\-tr`**                                     | Noter le “tr-” pour commencer et le “-tr” pour finir         |
| <img src="./images/trille_longue_en_dessous.svg" style="width:100%;" /> | **`\_tr(c'1)- c a\-tr`**                                    | La même chose en forçant la trille en dessous.               |
| <img src="images/exemples/trille_notes_fins.svg" style="  width:240px;" /> | **`\tr(cis'1)- (b16 cis)\-tr d1`**                          | Noter ici la tournure différente à la fin, avec les deux grâce-note entre parenthèses. Note quand même la logique générale. |
| <img src="images/exemples/trille_non_naturelle_et_notes_fins.svg" style="  width:240px;" /> | **`\tr(cis'1 dis)- (b16 cis)\-tr d1`**                      | On ajoute une note trillée avec une note étrangère           |



#### Petites notes (grace notes)


| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:140px;">Code</span> | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
| **Non liées non barrées**                                    | **`\gr(notes) note`**                                       |                                                              |
| Exemple simple                                               | `\gr(b'16) a8 gis16 fais`                                   | <img src="images/exemples/grace_simple.svg" style=" width:170px;" /> |
| Exemple multiple                                             | `\gr(b'16 gis) a4`                                          | <img src="images/exemples/grace_multiple.svg" style=" width:110px;" /> |
| **Non liées barrées**                                        | **`\gr(note/)`**                                            | Remarquer la barre finale qui symbolise la note barrée       |
| Exemple                                                      | `\gr(b'8/) a4`                                              | <img  src="images/exemples/grace_slashed.svg" style=" width:100px;" /> |
| Exemple multiple                                             | `\gr(b'16 gis/) a4`                                         | <img  src="images/exemples/grace_slashed_multiple.svg" style=" width:100px;" />(noter : non barré) |
| **Appoggiature**                                             | **`\gr(note-)`**                                            |                                                              |
| Exemple                                                      | `\gr(b'8-) a gis16 fis e4`                                  | <img src="images/exemples/grace_appoggiature.svg" style=" width:170px;" /> |
| Exemple multiple                                             | `\gr(b'8 gis-) a4`                                          | <img src="images/exemples/grace_appoggiature_multiple.svg" style=" width:100px;" /> |
| **Acciaccature**                                             | **`\gr(note/-) note`**                                      |                                                              |
| Exemple                                                      | `\gr(ais'16/-) b4`                                          | <img src="images/exemples/acciaccatura.svg" style=" width:90px;" /> |
| **Quand plusieurs notes**                                    | **`\grace note[ note note note]`**<br />                    |                                                              |

#### Notes « mergées »

« Merger » des notes signifie utiliser une seule tête pour deux notes. Ce merge permet de transformer :

<img src="images/note_merge_off.svg" alt="note_merge_off" style="zoom:120%;" />

… en :



<img src="images/note_merge_on.svg" alt="note_merge_on" style="zoom:120%;" />

On obtient ce merge en ajouant **`\mergeNotes`** avant les notes. Ce merge sera effectif jusqu’à la prochaine parenthèse de délimitation de groupe de note (donc c’est variable en fonction de la façon d’écrire la musique avec LilyPond).

> Ce **`\mergeNotes`** provoque dans le moteur l’écriture de **`\mergeDifferentlyHeadedOn \mergeDifferentlyDottedOn`**. On pourra préférer utiliser ces deux marques, ou seulement l’une d’entre elles, dans le détail, pour un résultat différent attendu.

<a name="change-staff"></a>

#### Changement de portée

Pour inscrire provisoirement les notes sur la portée au-dessus ou en dessous, utiliser `\up` et `\down`. Par exemple :

~~~lilypond
--piano
r1
c, e g \up c e c \down g e c
~~~

… produira :

![changement_portee](./images/exemples/changement_portee.svg)

On peut indiquer explicitement le lien entre deux notes qui changent de portée (par un trait) en ajoutant l’indication **`\showStaffSwitch`**

~~~
--piano

r1 r1
c e g \showStaffSwitch \up c e c \showStaffSwitch \down g e c4 r r2
~~~

Produira :

![change-staff-with-trait](./images/change-staff-with-trait.svg)



#### Marques d’octave

Pour inscrire la marque d’octave, on peut utiliser `\8ve` (descendra les notes d’une octave et ajoutera la marque), `\15ve` (descendra les notes de deux octaves et ajoutera la double marque).

On fait l’inverse avec `\-8ve` (pour remonter les notes d’une octave) et `\-15ve` (pour remonter les notes de deux octaves).

On terminera toutes les marques précédentes avec `\0ve`.

---

<a name="arpege-par-arp"></a>

#### Arpèges

On peut simplifier la marque `\arpeggio` par la marque **`\arp`**.

~~~
<c e g c>2\arpeggio <c e g c>2\arp
~~~

… produira :

<img src="./images/arpege-par-arp.svg" alt="arpege-par-arp" style="zoom:120%;" />

---

<a name="ruby"></a>

### Fonctions ruby (mode expert)

En mode expert, on peut produire du code de toute pièce avec des fonctions ruby. On peut penser par exemple au premier prélude de Bach dans le premier clavier tempéré. Presque d'un bout à l'autre on retrouve le même motif qu'il serait laborieux de répéter. Il se présente dans la première mesure de cette manière, écrit de toutes notes :

~~~
-> score
r8 g'16 c e g, c e r8 g'16 c e g, c e
<< r16 e8.~ e4 // c2 >> << r16 e8.~ e4 // c2 >>
~~~

Voilà la méthode qu’il est possible de créer dans un fichier qu’on appellera par exemple **`module_image.rb`** (peu importe son nom, c’est son extension qui fait qu’il sera chargé par ScoreImage.

~~~ruby
module ScoreImage # ce nom est impératif

  def motif(basse, contrebasse, notes_sup)
    ns = notes_sup.split(' ')
    <<~TEXT
    % #{ns[0]}'16 #{ns[1]} #{ns[2]} #{ns[0]}, #{ns[1]} #{ns[2]} %2
    % << r16 #{contrebasse}8.~ #{contrebasse}4 // #{basse}2 >> %2
    TEXT
  end

end
~~~

Il nous suffit maintenant d’appeler la méthode `#motif` dans le code `.mus` à l’aide du préfix **`fn_`** (« fn » comme « fonction »).

~~~mus
-> score
fn_motif("c", "e", "g c e")
~~~

> Noter que contrairement à du pur ruby, il faut obligatoirement utiliser les parenthèses pour délimiter les arguments <u>**même lorsqu’il n’y en a pas**</u>.

#### Constantes notes

On peut utiliser les constantes au lieu de guillemets pour simplifier l’écriture :

~~~
-> score
fn_motif(c, e, g)
~~~



#### Parenthèses dans les arguments

Si les arguments contiennent des parenthèses, pour éviter toute confusion, on utilise des double-parenthèses pour délimiter les arguments de la fonction :

~~~
fn_motif(( "a( b c d)" ))
~~~



---

<a id="syntaxe_lilypond"></a>

## Langage LilyPond (aide mémoire)

Ci-dessous la syntaxe propre à Lilypond, pour mémoire.

#### Altérations

| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:140px;">Code</span> | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
| `#`                                                          | **`is`**                                                    | Par exemple `fis` pour fa dièse                              |
| `b`                                                          | **`es`**                                                    | Par exemple `ees` pour mi bémol                              |
| `x`                                                          | **`isis`**                                                  | Par exemple `gisis` pour sol double-dièses                   |
| `bb`                                                         | **`eses`**                                                  | Par exemple `aeses` pour la double bémols                    |
|                                                              | **`!`**                                                     | Altération de prudence. Par exemple `a!` pour forcer la marque du bécarre lorsque le La a été diésé dans la mesure précédente. |
|                                                              | **`?`**                                                     | Altération entre parenthèse. Par exemple **`a?`** pour mettre un bécarre avant le La entre parenthèses pour bien indiquer qu’il est bécarre. |


#### Accords

| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:140px;">Code</span> | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
|                                                              | **`< notes >duree`**                                        | Bien noter que la durée est à l'extérieur de l'accord. Noter aussi que c'est la hauteur de la première note qui détermine la hauteur de référence pour la note suivante |
| Exemple                                                      | **<c e g c>2.**                                             | <img src="images/exemples/accord.svg" style=" width:100px;" /> |
| Arpège                                                       | **`<c e g>\arpeggio`**                                      | Il suffit d’ajouter la marque `\arpegio` après l’accord (et la durée) pour obtenir un arpège.<br /><img src="./images/arpege.svg" alt="arpege" style="zoom:120%;" /><br /><img src="./images/arpege-par-arp" alt="arpege" style="zoom:120%;" /> |
|                                                              |                                                             |                                                              |
| Snippet :                                                    | **`<`**                                                     |                                                              |

#### Liaisons

| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:140px;">Code</span> | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
| **Liaisons de jeu**                                          | **`note1( autres notes)`**                                  |                                                              |
| exemple                                                      | **`a'( b c d)`**                                            | <img src="images/exemples/liaison-de-jeu.svg" style=" width:150px;" /> |
| forcer en dessous                                            | **`a'_( b c d)`**                                           |                                                              |
| forcer au-dessus                                             | **`a'^( b c d)`**                                           |                                                              |
| Forcer en haut                                               | **`\slurUp`**                                               | Pour revenir au comportement par défaut : **`\slurNeutral`** |
| Forcer en bas                                                | **`\slurDown`**                                             | Pour revenir au comportement par défaut : **`\slurNeutral`** |
| **Liaison de durée**                                         | **`note~ note`**                                            |                                                              |
| Exemple simple                                               | **`c1~ c2`**                                                | <img src="images/exemples/liaison-de-duree.svg" style=" width:150px;" /> |
| Exemple avec des accords                                     | **`<c c'>1~ <c c'>4 <c~ g'~>2. <c e g>2`**                  | <img src="images/exemples/liaison-accords.svg" style=" width:200px;" /> |
| Forcer la liaison en haut                                    | **`\tieUp`**                                                | ![tie_down](images/tie_up.svg)                               |
| Forcer la liaison en bas                                     | **`\tieDown`**                                              | ![tie_down](images/tie_down.svg)                             |
| Pour revenir au comportement par défaut : **`\tieNeutral`**  | **`\tieNeutral`**                                           | ![tie_down](images/tie_neutral.svg)<br />Dans l’exemple ci-dessus, le `\tieNeutral` est inséré entre les deux notes. |
|                                                              |                                                             |                                                              |



#### Attache des hampes des notes


| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:300px;">Code</span>  | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Forcer l'attache                                             | **`note[ notes]`**                                           |                                                              |
| Exemple                                                      | `a'16[ a a a a a a a]`                                       | <img src="images/exemples/hampes-accroched.svg" style=" width:200px;" /> |
| Forcer l'attache vers le haut                                | **`note^[ notes]`**                                          |                                                              |
| Exemple                                                      | **`e'16^[ e e e] e`**                                        | <img src="images/exemples/hampes-forced-haut.svg" style=" width:140px;" /> |
| Forcer l'attache vers le bas                                 | **`note_[ notes]`**                                          |                                                              |
| Exemple                                                      | **`a'16_[ a a a] a`**                                        | <img src="images/exemples/hampes-forced-bas.svg" style=" width:140px;" /> |
| Forcer une hampe seule en haut                               | **`\stemUp e'4 \stemNeutral`**<br />**`e'4^[]`**             | <img src="images/exemples/hampes_vers_le_haut.svg" style=" width:80px;" /> |
| Forcer les hampes de plusieurs notes non attachées (noires et blanches) | **`\stemUp e'4 f g f \stemNeutral`**<br />**`e'4^[] f^[] g^[] f^[]`** | N1 : Noter que si plusieurs notes (plusieurs noires par exemple) doivent être traitées ensemble et que ce ne sont pas les mêmes hauteurs, il ne faut pas utiliser `e'4^[ f g f]` car dans ce cas tous les hauts de hampes s’aligneraient à la même hauteur. Il est impératif d’utiliser le code ci-contre. Cf. ci-dessous. |
|                                                              | **`e'4^[ f g b, d f]`**                                      | <img src="images/exemples/hampes_plusieurs_vers_haut.svg" style=" width:160px;" /> |
|                                                              | **`e'4^[] f^[] g^[] b,^[] d^[] f^[]`**                       | <img src="images/exemples/hampes_plusieurs_vers_haut_separees.svg" style=" width:160px;" /> |
| Forcer une hampe seule en bas                                | **`g4_[]`**                                                  | <img src="images/exemples/hampes_vers_le_bas.svg" style=" width:80px;" /> |
|                                                              |                                                              | Pour plusieurs noires ou plusieurs blanches, cf. la note N1 ci-dessus. |

Voir la page suivante pour la gestion des deux en même temps :
https://lilypond.org/doc/v2.19/Documentation/notation/beams.fr.html

Il semble qu'il faille utiliser :
`\override Beam.auto-knee-gap = #<INTEGER>`

#### Anacrouse

Démarrage en levée de la mélodie, sans utiliser de silences invisibles avant (`r`) :

**`\partial <durée de l'anacrouse>`**

#### Changement de positions des éléments

~~~
\slurUp    \slurDown    \slurNeutral		Lignes de liaison
\stemUp    \stemDown    \stemNeutral		Hampes de notes
~~~



---

#### Voix simultanées

| <span style="display:inline-block;width:100px;">Objet</span> | <span style="display:inline-block;width:440px;">Code</span> | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
|                                                              | **`<< { note note note } \\ { note note note } >>`**        | Le plus clair et le plus simple est d'utiliser des [variables](#definitions) à la place des notes. La hauteur de la première note du second membre est calculée à partir de la première note du premier membre |
| Version simplifiée                                           | **`<< note note // note note >>`**                          | C’est la version simplifiée de la précédente.                |
| Exemple                                                      | **`<< { e'2 f e f } \\ { c,4 g' d g a e' d c } >>`**        | <img src="images/exemples/voix-simultanees.svg" style=" width:250px;" /> |
| Snippet                                                      | **`2v`**                                                    |                                                              |

Dans cette formule, les deux voix auront leur propre 'voice'.
Mais il existe d'autres possibilités (cf. le mode d'emploi)

#### Petites notes (grace notes)

| <span style="display:inline-block;width:200px;">Objet</span> | <span style="display:inline-block;width:140px;">Code</span> | <span style="display:inline-block;width:300px;">Description</span> |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------ |
| **Non liées non barrées**                                    | **`\grace note note`**<br />**`\gr(note) note`**            |                                                              |
| Exemple                                                      | `\grace ais'16  b4`<br />`\gr(ais'16) b4`                   | <img src="images/exemples/grace-note.svg" style=" width:90px;" /> |
| **Non liées barrées**                                        | **`\slashedGrace note note`**<br />**`\gr(note/)`**         |                                                              |
| Exemple                                                      | `\slashedGrace ais'16  b4`<br />`\gr(ais'16/)`              | <img src="images/exemples/slashed-grace-note.svg" style=" width:90px;" /> |
| **Liées non barrées**                                        | **`\appoggiatura note note`**<br />**`\gr(note-)`**         |                                                              |
| Exemple                                                      | `\appoggiatura ais'16  b4`<br />`\gr(ais'16-)`              | <img src="images/exemples/appoggiatura.svg" style=" width:90px;" /> |
| **Liées barrées**                                            | **`\acciaccatura note note`**<br />**`\gr(note/-) note`**   |                                                              |
| Exemple                                                      | `\acciaccatura ais'16  b4`<br />`\gr(ais'16/-) b4`          | <img src="images/exemples/acciaccatura.svg" style=" width:90px;" /> |
| **Quand plusieurs notes**                                    | **`\grace note[ note note note]`**<br />                    |                                                              |







## Variable (aka « Definitions » )

On peut créer des « définitions » qui pourront être ensuite utilisées dans l'expression LilyPond fournie. Ceci permet d'écrire de façon plus modulaire et de pouvoir composer des segments différents très facilement.

Typiquement, on peut faire une définition pour chaque mesure. Dans une partition pour piano du premier mouvement de la Sonate facile de Mozart, on pourrait avoir par exemple :

~~~music-score
--piano
--barres
--times

# La définition de la première mesure
# <nom de la variable-définition>
# <notes de main droite>
# <notes de main gauche>
mes1=
c'2 e4 g
c8 g' e g c, g' e g

mes2=
b'4.( c16 d) c4 r
d8 g f g d g f g

# Un segment comprenant ces deux mesures se définirait par :
-> mesures-1-a-2
mes1 mes2
mes1 mes2
~~~



#### Déclaration de la variable-définition

Sur une seule ligne, un nom ne contenant que des lettres majuscules ou minuscules et des chiffres, terminé par un ou deux signes « égal ».

* Avec **un seul signe égal**, c’est une **variable locale** (elle sera supprimée tout de suite après la réalisation de la première image).
* Avec **deux signes « égal »**, c’est une **variable globale** qui restera utilisable jusqu’à la fin du fichier.

La définition, qui peut tenir sur plusieurs lignes (une — monodie — ou deux — piano — pour le moment) et contenir des options, se termine à la première ligne vide rencontrée.

Par exemple :

~~~

mesure1=
c d e f g a b c
c b a g f e d c

# La ligne vide ci-dessus met fin à la définition
~~~



<a name="dynamic-variable"></a>

### Variable dynamique

Depuis 2024, les variables sont « dynamique », c’est-à-dire qu’elles peuvent varier en fonction de paramètres. À commencer par leur hauteur. 

#### Hauteur de la variable

Par exemple, soit la variable `maVar` définie par :

~~~
maVar=
c d e f g
~~~

Alors si on utilise dans le code :

~~~
-> partition
maVar' maVar maVar,
~~~

Cela produira les notes :

~~~
\relative c' { c' d e f g } \relative c' { c d e f g } \relative c' { c, d e f g }
~~~

C’est-à-dire que les marques « `’` »  et « `,` » , comme pour les notes, permettent de définir la hauteur où sera jouer la variable.

#### Répétition de la variable

De la même manière, on peut définir le nombre de fois où la variable doit être répétée avec `*N`. Par exemple :

~~~
-> partition
maVar*4
~~~

Produira :

~~~~
\relative c' { c d e f g c d e f g c d e f g c d e f g }
~~~~




#### Utilisation d’un rang de variables

L’utilisation des variables-définitions prend tout son intérêt avec la **définition de l’expression par rang de variables**.

Très simplement, cela signifie que si on déclare ces variables-définitions :

~~~music-score
mes1==
... notes ...

mes2==
... notes ...

mes3==
... notes ...

mes4==
... notes ...
~~~

… on peut déclarer facilement un segment (une image, donc) avec :

~~~music-score
mes1<->4
~~~

Cela signifie que le segment sera constitué des mesures 1 à 4.



>  Noter que pour le moment, on ne peut pas utiliser en même temps, en  mode --piano, des définitions d'une seule main et des définitions  des deux mains. Si on adopte un mode, il doit être utilisé pour tout l'extrait.
>   Mais deux extraits différents peuvent utiliser deux modes qui diffèrent, par exemple :

~~~
# Un extrait avec définition d'une seule main

--piano

mg1=
c1 e g

md1=
g8( a b c) c2

-> essai_par_mains
mg1
md1

mgd1=
c1 e g
g8( a b c) c2

-> essai_deux_mains
mgd1

~~~

#### NOTA BENE

Noter un point très important : lors de l'utilisation de variables à plusieurs voix, l'expression lilypond ne peut qu'être exclusivement constituée de variables (sur une ligne, donc, puisque ce sont les définitions qui contiennent les différentes voix)

~~~music-score

md1=
c2 e4 g

mg1=
g8( a b c) c2

md2=
b4. c8 c4 r

mg2=
d g f g c, g' e g

# Définitions à voix multiples
tout=
md1 md2
mg1 mg2

-> fichier
tout

~~~



## Annexe



#### Le fichier « build » dans Sublime Text

> Note : je n’ai pas réussi à le faire remarcher, même en modifiant le première commande fautive qui appelle la version ruby 2.7.1.

C’est le fichier qui permet de jouer `Cmd B` avec le fichier music-score (`.mus`) actif et de produire les images qu’il définit.

Ce fichier est à mettre dans `/Library/Applications Support/Sublime Text 3/Packages/User/music-score.sublime-build`.

~~~{
	// "shell_cmd": "make"
"cmd": [
	"/Users/philippeperret/.rbenv/versions/2.7.1/bin/ruby", 
	"/Users/philippeperret/Documents/ICARE_EDITIONS/Musique/xDev/scripts/music-score/music-score.rb", 
	"$file"
],
"selector": "source.music",
"file_patterns": ["*.mus"],
"target": "ansi_color_build",
"syntax": "Packages/ANSIescape/ANSI.sublime-syntax"
}
~~~

> Depuis le crash de 2021, ce fichier fait partie des backups universels.

#### Le fichier de coloration syntaxique pour Sublime Text

Ce code est à placer dans `/Library/Applications Support/Sublime Text 3/Packages/User/music-score.sublime-syntax`

> Note : depuis le crash de 2021, ce fichier fait partie des backups universels.
>
> Mais il ne fonctionne plus bien non plus

~~~
%YAML 1.2
---
# See http://www.sublimetext.com/docs/3/syntax.html
file_extensions:
  - mus
scope: source.music

contexts:
  # The prototype context is prepended to all contexts but those setting
  # meta_include_prototype: false.
  prototype:
    - include: comments

  main:
    # The main context is the initial starting point of our syntax.
    # Include other contexts from here (or specify them directly).
    - include: numbers
    - include: notes

  numbers:
    - match: '[^,a-g][0-9]+(\-[0-9]+)?\b'
      scope: constant.numeric.example-c

  notes:
    # Les notes
    - match: "\\b[a-gr](es|is)?(es|is)?[',](16|32|64|128|1|2|4|8)?"
      scope: music.note
    - match: "\\b[a-gr](es|is)?(es|is)?\\b?[',]?(16|32|64|128|1|2|4|8)?\\b"
      scope: music.note
    # Les accords
    - match: '<.+?>(16|32|64|128|1|2|4|8)?'
      scope: music.note.chord
    # Les liaisons
    - match: '\( .+?\)'
      scope: music.note
    # Les options qu'on peut trouver
    - match: '\-\-(verbose|keep|barres|time|piano|only_new|stop|start|open|big-|mini-|biggest)(hspace)?( (OFF|ON))?\b'
      scope: music.option
    # Numéro de mesure et proximité
    - match: '\-\-(mesure|proximity) [0-9]+\b'
      scope: music.mesure.numero
    # Tonalité
    - match: '\-\-(tune|key) [a-zA-Z][#b]?'
    # Format de page
    - match: '\-\-page [a-zA-Z0-8]+'
      scope: music.mesure.numero
    # Définition (variable)
    - match: '[a-zA-Z0-9_]+\=\=?'
      scope: music.mesure.numero
    # Nom de fichier
    - match: '^\-> (.+)$'
      scope: music.output.name
    # Les clés
    - match: '\\clef? ("(treble|bass|ut)"|G1|G|F3|F|UT1|UT2|UT3|UT4|UT5)'
      scope: music.clef
    # Les barres de mesure
    - match: ':?\|:?'
      scope: music.mesure.barre
    # Special words
    - match: '\\(trill|slashedGrace|grace|appoggiatura|acciaccatura|break) ?'
      scope: music.clef

  inside_string:
    - meta_include_prototype: false
    - meta_scope: string.quoted.double.example-c
    - match: '\.'
      scope: constant.character.escape.example-c
    - match: '"'
      scope: punctuation.definition.string.end.example-c
      pop: true

  comments:
    # Comments begin with a '# ' and finish at the end of the line.
    - match: '# '
      scope: punctuation.definition.comment.example-c
      push:
        # This is an anonymous context push for brevity.
        - meta_scope: comment.line.double-slash.example-c
        - match: $\n?
          pop: true

~~~

---

### Tests

***Score-Image*** est testée par des comparaisons entre les images attendues et les images produites, pour être sûr d’un résultat optimum. Cf. le dossier `tests/checksums_tests` qui contient tous les fichiers.

Pour lancer tous les tests :

~~~
score-image tests _
~~~

Pour filtrer les tests à jouer :

~~~
score-image tests /<filtre régulier>/
~~~

Pour ne lancer que les tests d’un dossier :

~~~
score-image tests _ -dir=dossier
~~~

Et en les filtrant :

~~~
score-image /ceuxla/ -dir=mon/dossier
~~~



En plus de l’image produite, les tests s’assurent aussi que toutes les statistiques soient correctes, ce qui permet un tour d’horizon parfait.

Pour de plus amples informations, lire le fichier `tests/_ReadMe_.md`
