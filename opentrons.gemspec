directory = File.expand_path(File.dirname(__FILE__))
definitions_directory = File.join(directory, "..", "..", "definitions")
definitions_paths = Dir[directory + "/*.json"]

Gem::Specification.new 'opentrons', '0.0.4' do |s|
  s.name        = 'opentrons'
  s.version     = '0.0.4'
  s.date        = '2018-08-28'
  s.summary     = "Provides a variety of functionalities for writing JSON OpenTrons protocols in Ruby. This gem is not a product of OpenTrons."
  s.description = "Provides a variety of functionalities for writing JSON OpenTrons protocols in Ruby. This gem is not a product of OpenTrons."
  s.authors     = ["Nick Emery"]
  s.email       = 'emernic@bu.edu'
  s.files       = ["lib/opentrons.rb"] + definitions_paths
  s.homepage    = 'https://github.com/emernic/opentrons_gem'
  s.license     = 'LICENSE.txt'
end