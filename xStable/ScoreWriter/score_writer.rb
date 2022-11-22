#!/usr/bin/env ruby
# encoding: UTF-8
=begin

  Script maitre de l'application ScoreWriter

=end

begin
  require_relative 'lib/required'
  Dir.chdir(CURRENT_FOLDER) do
    WAA.goto File.join(__dir__,'main.html')
    WAA.run
  end
rescue Exception => e
  puts e.message + "\n" + e.backtrace.join("\n")
ensure
  WAA.driver.quit
end
