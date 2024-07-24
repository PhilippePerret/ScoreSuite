#
# Module pour gérer les groupement de portées.
# 
# On trouve les classes :
# 
# Lilypon::Group
# 
#     Gestion d’un groupe de portées, que ce soit le groupe principal
#     ou un sous-groupe.
# 
# Lilypond::System < Lilypond::Group
# 
#     Gestion du "système", c’est-à-dire de l’ensemble des portée.
#     C’est la valeur options[:system] qui sera utilisée pour sortir
#     les marques de regroupement et autres noms de groupes ou de
#     portée.
# 
#     Il hérite naturellement de la classe Lilypond::Group puisque
#     c’est lui-même un groupe, avec une marque de début et une 
#     marque de fin, etc.
# 
# Lilypond::Staff
# 
#     C’est une portée, en tant que portée qui peut être nommée et
#     élément d’un groupe ou d’un système.
# 
# 
class MusicScore
class Lilypond

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#
#                          LILYPOND::GROUP
#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

class Group

  # [Array<<Lilypond::Staff>] Liste des portées
  attr_reader :staves

  def initialize
    # Pour mettre toutes les portées [Lilypond::Staff]
    @staves = []
  end

  def inspect(indent = '')
    <<~TEXT.split("\n").join("\n#{indent}")

    LILYPOND::GROUP ID #{object_id}
    Name: #{name.inspect}
    start_mark: #{start_mark}

    TEXT
  end

  # [String] Le nom du groupe
  # Il n’existe que si toutes les portées qu’il contient possède
  # le même nom (insensible à la casse)
  def name
    @name ||= get_group_name
  end

  # @return true si le groupe est nommé
  # Il est "nommé" si toutes ses portées portent le même nom. Dans ce
  # cas, le groupe porte ce nom et le nom des portées n’est pas affi-
  # ché.
  def named?
    not(name.nil?)
  end

  # @api
  # 
  # @return [String] La marque pour le début du group/système
  # 
  # @note : peut-être redéfini explicitement dans le cas du système,
  # lorsqu’il est d’un groupe spécial
  def start_mark
    @start_mark ||= begin
      if group_character.nil? # system sans définition
        '<<'.freeze
      else
        '\new %s %s<<'.freeze % [group_type, name_mark]
      end.freeze
    end
  end

  # @api
  # 
  # @return [String] La marque pour la fin du group/système
  # (le plus souvent, c’est "{")
  # @note : peut-être redéfini explicitement dans le cas du système,
  # lorsqu’il est d’un groupe spécial
  def end_mark
    return '>>' # apparemment c’est toujours ça
    @end_mark ||= begin
      if group_character.nil? # system sans définition
        '>>'
      else
        '>>'
      end.freeze
    end
  end

  # @api
  # 
  # Ajoute une portée au groupe (ou au système)
  # @note : la portée est toujours ajoutée au début
  # 
  def add_staff(staff)
    @staves.unshift(staff)
  end

  def staves_count
    @staves_count ||= staves.count
  end

  # @return [String] Le type du groupe en fonction du character
  # de groupe et de la volonté de lier les barres de portées
  def group_type
    case group_character
    when '{'  # pas de barres déliées dans ce cas
      'GrandStaff'
    when '['
      bars_linked? ? 'StaffGroup' : 'ChoirStaff'
    end.freeze
  end

  # @return [String] La marque pour le nom du groupe s’il a un nom
  # 
  def name_mark
    if named?
      '\with { instrumentName = "%s" } '.freeze % self.name
    else "" end
  end

  # [String] Soit "[", soit ’{’, soit rien (système principal sans 
  # précision de nature)
  def group_character
    @group_character
  end
  def group_character=(value)
    @group_character = value
  end

  def bars_linked?
    not(@bars_are_linked === false)
  end
  def bars_linked=(value)
    @bars_are_linked = value
  end

  private 

    # Retourne le nom du groupe s’il peut en avoir un
    def get_group_name
      nf  = staves[0].name
      nft = nf.downcase.freeze
      staves.each do |staff|
        # <= Un nom différent
        # => Pas de nom de groupe
        return nil if staff.name.downcase != nft
      end

      return nf
    end

end #/class Group


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#
#                          LILYPOND::SYSTEM
#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

class System < Group

  # =========== CLASSE LILYPOND::SYSTEM =========== #
  class << self

    # @api
    # 
    # = main =
    # 
    # Méthode principale qui parse la données ’--staves_names’ pour
    # en tirer les groupements de portées à faire.
    # 
    # @return [MusicScore::Lilypond::System] Le système avec tous ses
    # groupes et ses portées.
    # 
    def parse(staff_names, staff_keys)

      staff_names ||= ""
      staff_keys  ||= ""
      sys = System.new

      # Les clés dispatchées (noter qu’elles peuvent ne pas être 
      # définies — dans ce cas, elles valent G)
      staff_keys  = staff_keys.split(',').map {|k| k.strip}
      staff_names = staff_names.split(',')

      nb_names = staff_names.count
      nb_keys  = staff_keys.count

      if staff_keys.count != staff_names.count
        # Nombre de noms de portées et de nombre de clés différents
        if nb_names > 0 && nb_keys > 0
          # Si les noms de portées sont définis, mais pas en nombre
          # suffisant, c’est vraiment une erreur (sinon, il s’agit
          # simplement du fait de la définition de clé sans noms de
          # portées particulières)
          raise ERREUR[200] % [staff_names.count, staff_keys.count]
        elsif nb_names == 0
          staff_names = Array.new(nb_keys, '')
        elsif nb_keys == 0
          staff_keys  = Array.new(nb_names, 'G')
        end
      end

      current_group = nil

      staff_names.each_with_index do |staff_name, idx|

        # On instancie une nouvelle portée
        staff = Staff.new

        sname = staff_name.strip
        staff.key= staff_keys[idx]

        # La portée est-elle le début ou la fin d’un groupe ?
        if (with_acco = sname.start_with?('{')) || (with_croc = sname.start_with?('['))
          # Marque de début => Fin d’un groupe qui n’existe pas 
          # encore (car rappel : les noms sont inversés, donc la 
          # marque ’{instrumen’, qui dans le fichier mus désigne un
          # début de groupe, correspond en réalité à ’intrument}’, 
          # une fin de groupe.

          # Si un groupe est déjà en cours, on lève une exception, 
          # car on n’a pas le droit d’imbriquer des groupes (pour le
          # moment en tout cas, et même si Lilypond le permet)
          if not(current_group.nil?)
            raise ERREUR[500]
          end

          # On crée le groupe (en incrémentant le nombre de groupes
          # du système — ne sert pas, pour le moment)
          current_group = Group.new
          sys.groups_count += 1

          current_group.group_character= sname[0]
          # Le nom de la portée
          sname = sname[1..-1].strip
          # On empêche tout de suite d’avoir des groupes imbriqués
          if sname.match?(/^[\[\{]/)
            raise ERREUR[500]
          end

          current_group.bars_linked= (sname[0] != '-')
          sname = sname[1..-1].strip unless current_group.bars_linked?
          staff.name= sname
          staff.is_last
          staff.group= current_group

        elsif (with_acco = sname.end_with?('}')) || (with_croc = sname.end_with?(']'))
          # Marque de fin => Début d’un groupe qui existe déjà
          sname = sname[0..-2].strip
          staff.is_first
          staff.group= current_group # ne peut pas être nil
          # C’est la fin du groupe
          current_group = nil

        else
          # Ni le début ni la fin d’un groupe
          staff.group= current_group # peut-être nil
        end

        # Dans tous les cas, on règle le nom de la portée (qui ici 
        # est toujours épuré)
        staff.name= sname.nil_if_empty
        # Et on ajoute cette portée au système
        sys.add_staff(staff)
      
      end

      # Tous les groupes doivent avoir été fermés
      raise ERREUR[501] if not(current_group.nil?)

      sys.check_if_system_in_special_group

      return sys
    end
    #/ parse

  end #/<< self 
  # =========== /CLASSE LILYPOND::SYSTEM =========== #


  # ============ INSTANCE LILYPOND::SYSTEM =============== #

  # @return [Integer] Nombre de groupes que possède le
  # système (je ne sais pas si ça sert à quelque chose…)
  attr_accessor :groups_count

  def initialize
    super
    @groups_count = 0
  end

  # Pour débugger (isys.inspect)
  # 
  def inspect
    <<~TEXT

    LILYPOND::SYSTEM ID #{object_id}
    -------------------------
    Détail des portées (#{staves_count}) :
    ------------------
    #{staves.map { |st| st.inspect('  ') }.join("\n")}

    Détail des groupes (#{groups.count}) :
    ------------------
    #{groups.map {|gr| gr.inspect('  ')}.join("\n")}
    TEXT
  end

  def groups
    @groups ||= begin
      staves.map do |st|
        st.group
      end.compact.uniq
    end
  end

  # Si la première et la dernière portée appartiennent au même
  # groupe, c’est en fait le système
  def check_if_system_in_special_group
    return if groups_count == 0
    return if staves_count < 2
    return if staves[0].group.nil? || staves[-1].group.nil?
    if staves[0].group == staves[-1].group
      # <= La 1re et la dernière portée sont dans le même groupe
      # =>
      @start_mark = staves[0].group.start_mark
      @end_mark   = staves[0].group.end_mark
      # On sort toutes les portées du group principal et on en 
      # profite pour voir si toutes les portées portent le même nom
      grp_name = staves[0].name
      staves.each do |st| 
        st.group = nil
        grp_name = nil if st.name != grp_name
      end
      unless grp_name.nil?
        @name = grp_name
        staves.each { |st| st.name = nil }
      end
    end
  end

end #/class System

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#
#                          LILYPOND::STAFF
#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
class Staff

  attr_accessor :name
  attr_accessor :key

  # [Lilypond::Group] Instance du groupe auquel appartient la portée
  # (if any)
  attr_reader :group

  def initialize
    @group    = nil
    @is_last  = false
    @is_first = false
  end

  # @return [String] Le nom final affiché pour la portée
  # Voir aussi :
  # https://lilypond.org/doc/v2.25/Documentation/notation/instrument-names.fr.html
  # 
  def final_name
    if (in_group? && group.named?)
      return nil
    else
      return name && formated_name
    end
  end

  def formated_name
    @formated_name ||= begin
      n = self.name
      if n && n.match?(REG_ALTE_IN_NAME)
        n.gsub(REG_ALTE_IN_NAME) do
          letter = $1.freeze
          with_bemol = letter == 'b'
          alte   = with_bemol ? 'flat' : 'sharp'
          vspace = with_bemol ? "0.2" : "0.3"
          fsize  = with_bemol ? 'small' : 'teeny'
          before_alte, after_alte = n.split("_#{letter}_")
          '\markup { \concat { \column { "%s" } \column { \vspace #-%s { \%s \%s } } \column { "%s" } } }'.freeze % [before_alte, vspace, fsize, alte, after_alte]
        end
      else
        '"%s"'.freeze % n
      end
    end
  end

  REG_ALTE_IN_NAME = /^.*_([bd#])_.*$/.freeze

  def inspect(indent = '')
    <<~TEXT.split("\n").join("\n#{indent}")

    LILYPOND::STAFF ID: #{object_id}
    Name: #{name.inspect}
    Group: #{in_group? ? group.object_id : '- aucun - '}#{"\nDernière du groupe (depuis le haut)" if last_staff?}#{"\nPremière du groupe (depuis le haut)" if first_staff?}
    TEXT
  end

  # - Predicate Methods -

  def in_group?
    not(group.nil?)  
  end

  def last_staff?
    @is_last === true
  end

  def first_staff?
    @is_first === true
  end

  # - Méthodes de définition des valeurs -

  # Définit le groupe de la portée et l’ajoute à ce groupe
  # 
  # @param igroup [Lilypond::Group]
  def group=(igroup)
    @group = igroup
    igroup.add_staff(self) unless igroup.nil?
  end

  def is_last
    @is_last = true
  end
  def is_first
    @is_first = true
  end

end #/class Staff
end #/class Lilypond
end #/class MusicScore
