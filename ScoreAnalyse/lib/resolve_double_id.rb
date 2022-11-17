=begin
  
  Module/script pour résoudre le problème d'identifiant identique
  dans un fichier d'analyse

=end
require 'clir'
require 'fileutils'
require 'yaml'

path = File.join(__dir__,'analyse_tags.yaml')

data = YAML.load_file(path, aliases:true, symbolize_names: true)

def check_doublons_in(liste)
  ids = {}
  $max_id = 0
  $has_doublon = false
  liste.each do |tag|
    tag_id = tag[:id].to_i
    if ids.key?(tag_id)
      puts "L'ID ##{tag_id} est déjà utilisé"
      $has_doublon = true
    else
      ids.merge!(tag_id => true)
      $max_id = tag_id if $max_id < tag_id
    end
  end

  return not($has_doublon)
end

check_doublons_in(data)


puts "Max ID : #{$max_id.inspect}"

if $has_doublon
  if Q.yes?("Dois-je corriger les données ?")
    ids = {}
    data.each do |tag|
      tag_id = tag[:id].to_i
      if ids.key?(tag_id)
        puts "L'ID ##{tag_id} est déjà utilisé"
        tag.merge!(id: $max_id += 1 )
      else
        ids.merge!(tag_id => true)
      end
    end

    # Vérification 
    if check_doublons_in(data)
      if Q.yes?("Puis enregistrer les nouvelles données ?".jaune)
        puts "Je dois apprendre à enregistrer les nouvelles données.".jaune
        FileUtils.cp(path, "#{path}.backup")
        File.write(path, data.to_yaml)
      end
    end
  end
else
  puts "Le fichier de tags est parfaitement correct.".vert
end
