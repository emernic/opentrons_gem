# OpenTrons Gem

This Ruby gem provides basic functionality for creating and manipulating OpenTron JSON protocols. This gem is not a product of OpenTrons. The API is designed to mirror the official OpenTrons Python API for ease of use.

## Examples
Create a protocol:
```
p = OTProtocol.new
```
Create a labware item: 
```
block = p.labware.load('96-deep-well', '2', 'culture_block')
```
Create a tiprack: 
```
tip_rack_1 = p.labware.load('tiprack-10ul', '3', 'tiprack-10ul')
```
Create a pipette: 
```
p10 = p.instruments.P10_Single(mount='left', tip_racks=[tip_rack_1])
```
Create a pipette and generate tip_racks of model "tiprack-10ul" as needed:
```
# This is a new feature! Racks will be generated in the highest-numbered available slot.
p10 = p.instruments.P10_Single(mount='left', tip_model="tiprack-10ul")
```
Pick up a tip: 
```
p10.pick_up_tip()
```
Add an aspirate command: 
```
p10.aspirate(10, block.wells(0))
```
Add a dispense command: 
```
p10.dispense(10, block.wells(1).top(2))
```
Discard tip:
```
p10.drop_tip()
```
	
## Examples, saving protocols
Generate a hash of the protocol:
```
p.to_hash
```
Generate a JSON string of the protocol:
```
p.to_json
```
Save a protocol as a JSON file:
```
File.open("protocol.json", 'w') {|f| f.write(p.to_json)}
```
## Limitations of current version
- Built for OT protocol JSON schema 1.0 (which is not the final version).
    https://github.com/Opentrons/opentrons/blob/391dcebe52411c432bb6f680d8aa5952a11fe90f/shared-data/protocol-json-schema/protocol-schema.json
- Custom containers not yet supported
- Modules (heat and magnetic) not yet supported
- Complex liquid handling shortcuts not yet supported
- Loading and editing existing protocols from JSON not supported.
- Error checking not very robust
- And more...

### Installation
This gem requires Ruby.
The gem can be installed via:
```sh
gem install opentrons
```
At the time of writing, support for JSON protocols in the OT2 app is still under development. If you would like to try out or contribute to this gem before JSON protocol support is added to the app, you may find these json-to-python protocol converters useful. https://github.com/emernic/OT2_json_workarounds

### Contributing
If you would like to contribute, submit issues on github, submit a pull request, or email emernic at bu dot edu. You can also feel free to fork it and make your own version. The gem is distributed under the MIT license and is free to use.