


ERREURS = {
  500 => "Pas de groupes imbriqués",
}

ERREURS.each do |k, m|
  ERREURS.merge!( k => "ERREUR [#{k}] #{m}")
end
