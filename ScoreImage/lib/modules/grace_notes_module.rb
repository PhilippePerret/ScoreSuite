# Module pour gérer les petites notes, utilisé aussi bien par le
# module Lilypond.rb que par les statistiques
module GraceNotesModule

  def grace_type_of(inner)
    if inner.end_with?('/-')
      :acciaccatura
    elsif inner.end_with?('/')
      :slashed
    elsif inner.end_with?('-')
      :appoggiatura
    else
      :grace_note
    end
  end

  def no_appoggiatura?
    :TRUE == @noappog ||= true_or_false(no_grace_note_type?('a'))
  end

  def no_acciaccatura?
    :TRUE == @noacciac ||= true_or_false(no_grace_note_type?('c'))
  end

  def no_slashedgrace?
    :TRUE == @noslashedgr ||= true_or_false(no_grace_note_type?('s'))
  end

  def no_grace_notes?
    :TRUE == @nogr ||= true_or_false(no_grace_note_type?('g'))
  end

  def no_grace_in_parenthesis?
    :TRUE == @nogrinparent ||= true_or_false(no_grace_note_type?('p'))
  end

  def gr_out_of_parenthesis?
    :TRUE == @groutofparenth ||= true_or_false(not(no_grace_in_parenthesis?))
  end

  def no_grace?
    :TRUE == @nogracenotes ||= true_or_false(options[:no_grace]||CLI.option(:no_grace))
  end

  def no_grace_note_type?(type)
    no_graces && no_graces.match?(/#{type}/)
  end

  # Attention : pas la méthode predicate, mais la valeur pour 
  # distinguer les petites notes précisément à supprimer
  def no_graces
    @no_graces ||= (options[:no_graces] || CLI.option(:no_graces)).freeze
  end

  # À chaque nouvelle image
  def reset_graces_options
    @no_graces = nil
    @noappog = nil
    @noacciac = nil
    @nogr = nil
    @noslashedgr = nil
    @nogrinparent = nil
    @nogracenotes = nil
    @groutofparenth = nil
  end

end
