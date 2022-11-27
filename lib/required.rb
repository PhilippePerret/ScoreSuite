# encoding: UTF-8
=begin

  Pour requérir tous les éléments communs à toutes les application
  de la suite Score.
  
=end
require_relative 'common/utils'
require_relative 'constants'

Dir["#{__dir__}/common/**/*.rb"].each do |m| 
  # puts "-> REQUIRE: #{File.basename(m)}"
  require m
end
