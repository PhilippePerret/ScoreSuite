% 
% Fonctions pour le marquage de l'harmonisation/chiffrage
% de la pièce
%
% Usage
%
%   Pour marquer l'accord (au-dessus de la note)
%   --------------------------------------- 
%   c\chifName "C7"
%   Avec plus grand éloignement
%   c\chifName "C7" #5  % 5 fois l'interligne
%
%   Pour marquer le degré (sous la portée)
%   ---------------------------------------- 
%   chifDegree "<II – V>"
%   Avec plus grand éloignement, ajouter #x où x est
%   le nombre d'interligne de distance

#(define chord-font "PhilNote6")
#(define chord-name-offset 3)
#(define chord-degre-offset -5)

#(define up "up") 
#(define down "down")

% Pour marquer le nom de l'accord au-dessus de la note
% -------------------------------------------------- 
chifName = 
#(define-music-function (chord-text . rest) (string?)
   (let ((offset (if (null? rest) chord-name-offset (car rest))))
     #{
       ^\markup { 
         \override #`(font-name . ,chord-font) 
         \translate #`(0 . ,offset) { $chord-text } 
       }
     #}))    

% Pour marquer le degré (fonction) de l'accord sous la portée
% ----------------------------------------------------------- 
chifDeg = 
#(define-music-function (chord-text . rest) (string?)
   (let ((offset (if (null? rest) chord-degre-offset (car -rest))))
     #{
       _\markup { 
         \override #`(font-name . ,chord-font) 
         \translate #`(0.4 . ,offset) { $chord-text } 
       }
     #}))

% Pour écrire la nature d'une note quelconque
%
% Syntaxe :
%
%   <note>\chifNote "<nature>" #<position>
%
% Par exemples :
%
%    c\chifNote "brc" #up
%    c\chifNote "np" #down
%
chifNote = 
#(define-music-function (type position) (string? string?)
    (if (string=? position up)
        #{
          ^\markup {
            \override #`(font-name . ,chord-font) 
            $type
          }
        #}
        #{
          _\markup {
            \override #`(font-name . ,chord-font) 
            $type
          }
        #}))


% Pour marquer une note de passage
chifNP =
#(define-music-function (pos) (string?)
  (chifNote "np" pos)
)

