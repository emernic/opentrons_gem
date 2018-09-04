Gem::Specification.new 'opentrons', '0.0.6' do |s|
  s.name        = 'opentrons'
  s.version     = '0.0.6'
  s.date        = '2018-08-28'
  s.summary     = "Provides a variety of functionalities for writing JSON OpenTrons protocols in Ruby. This gem is not a product of OpenTrons."
  s.description = "Provides a variety of functionalities for writing JSON OpenTrons protocols in Ruby. This gem is not a product of OpenTrons."
  s.authors     = ["Nick Emery"]
  s.email       = 'emernic@bu.edu'
  s.files       = ["lib/opentrons.rb", 
                  "lib/opentrons/commands.rb",
                  "lib/opentrons/instruments.rb",
                  "lib/opentrons/labware.rb",
                  "lib/opentrons/otprotocol.rb"] + Dir["definitions/*.json"]
  s.homepage    = 'https://github.com/emernic/opentrons_gem'
  s.license     = 'LICENSE.txt'
end