module ScoreCutting

  ERRORS = {
    image_not_defined: <<~ERR.strip,
      Il faut définir le nom de l’image à découper en premier argu-
      ument ou se placer dans un dossier qui contient des scores.
      ERR
    unfound_file: "L'image de la partition est introuvable\n(in %s)",
    not_a_pdf: "La partition doit être une image, pas un fichier PDF\nConsulter l'aide (#{'score-cutting -h'.jaune}) pour voir comment le faire.",
    not_a_image: "Le fichier '%s' n'est pas une image…",
  }
end
