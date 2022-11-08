# encoding: UTF-8
require_relative 'CODES_ET_RESULTATS'

class TestStats < MiniTest::Test

  ##
  # Méthode principale qui s'assure que tout code produit bien le
  # résultat attendu.
  #
  def test_tous_les_cas_communs
    
    CODES_ET_RESULTATS.each do |dcase|
      
      statcase = StatCase.new(dcase)
      statcase.run
      assert statcase.is_ok?

    end

  end

end
