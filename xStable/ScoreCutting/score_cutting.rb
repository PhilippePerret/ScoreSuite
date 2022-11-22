#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'lib/required'

begin
  WAA.goto File.join(__dir__,'main.html')
  WAA.run
  
  # 
  # On passe ici quand on en a fini
  # 
  puts "On en a fini (j'attends une minutes)"
  sleep 60
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit
end

