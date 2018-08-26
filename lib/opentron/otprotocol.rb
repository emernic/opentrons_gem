module OpenTron
	# This gem is not a product of OpenTrons.
	# 
	# This version of the gem provides some basic functionality for creating and editing OpenTrons JSON-format 
	# protocols in Ruby. The organization of the methods should be familiar to anyone who has used
	# the official OpenTrons Python API. To serialize the protocol to json, simply run my_protocol.to_json 
	# or my_protocol.to_hash.to_json.
	# 
	# Examples:
	#     Create a protocol: p = OTProtocol.new
	#     Create a labware item: block = p.labware.load('96-deep-well', '2', 'culture_block')
	#     Create a tiprack: tiprack_1 = p.labware.load('tiprack-10ul', '3', 'tiprack-10ul')
	#     Create a pipette: p10 = p.instruments.P10_Single(mount: 'left', tip_racks: [tip_rack_1])
	#     Pick up a tip: p10.pick_up_tip()
	#     Add an aspirate command: p10.aspirate(10, block.wells(0))
	#     Add a dispense command: p10.dispense(10, block.wells(1).top(2))
	#     Discard tip: p10.drop_tip()
	# 
	# Examples for saving protocols:
	#     Generate a hash of the protocol: p.to_hash
	#     Generate a JSON string of the protocol: p.to_json
	#     Save a protocol as a JSON file: File.open("protocol.json", 'w') {|f| f.write(p.to_json)}
	# 
	# Limitations of current version:
	#     -Built for OT protocol JSON schema 1.0 (which is not the final version).
	#         https://github.com/Opentrons/opentrons/blob/391dcebe52411c432bb6f680d8aa5952a11fe90f/shared-data/protocol-json-schema/protocol-schema.json
	#     -Custom container creation within protocols not supported (must load onto robot beforehand)
	#     -Modules (heat and magnetic) not yet supported
	#     -Complex liquid handling shortcuts not yet supported
	#     -Error checking not very robust
	#     -No tests yet
	#     -And more...
	class OTProtocol
		attr_accessor :protocol_schema, :robot, :designer_application, :metadata, :labware, :instruments, :commands, :trash
		
		def initialize(params={})
			@protocol_schema = params.fetch(:protocol_schema, "1.0.0")
			@robot = params.fetch(:robot, {"model" => "OT-2 Standard"})
			@designer_application = params.fetch(:designer_application, {})
			@metadata = params.fetch(:metadata, {})

			@labware = params.fetch(:labware, Labware.new(self))
			@trash = labware.load('fixed-trash', '12', 'Trash')

			@instruments = params.fetch(:instruments, Instruments.new(self))

			@commands = params.fetch(:commands, Commands.new(self))
		end

		def to_hash(check_validity=true)
			# Returns entire protocol as an OT-protocol-format hash (which can then be converted to json).
			protocol_hash = {}

			protocol_hash["protocol-schema"] = protocol_schema
			protocol_hash["robot"] = robot
			protocol_hash["designer_application"] = designer_application
			protocol_hash["metadata"] = metadata

			protocol_hash["labware"] = labware.to_hash

			protocol_hash["pipettes"] = instruments.to_hash

			protocol_hash["procedure"] = [{"subprocedure" => commands.to_list}]

			return protocol_hash
		end

		def to_json(check_validity=true)
			#converts protocol to a JSON-formatted string
			return self.to_hash.to_json
		end

		def to_s
			"<OpenTron::OTProtocol:#{object_id}>"
		end

		def inspect
			s = "#{self.to_s} "
			instance_variables.each do |var_name|
				s << "#{var_name}=#{var_name.to_s} "
			end
			return s
		end
	end
end