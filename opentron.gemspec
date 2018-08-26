directory = File.expand_path(File.dirname(__FILE__))
definitions_directory = File.join(directory, "..", "..", "definitions")
definitions_paths = Dir[directory + "/*.json"]

Gem::Specification.new 'opentron', '0.0.3' do |s|
  s.name        = 'opentron'
  s.version     = '0.0.3'
  s.date        = '2018-08-26'
  s.summary     = "Provides a variety of functionalities for writing JSON OpenTron protocols in Ruby. This gem is not a product of OpenTrons."
  s.description = "Provides a variety of functionalities for writing JSON OpenTron protocols in Ruby. This gem is not a product of OpenTrons."
  s.authors     = ["Nick Emery"]
  s.email       = 'emernic@bu.edu'
  s.files       = ["lib/opentron.rb"] + definitions_paths
  s.homepage    = 'https://github.com/emernic/opentron_gem'
  s.license     = 'LICENSE.txt'
end