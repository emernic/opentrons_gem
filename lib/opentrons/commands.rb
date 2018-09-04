module OpenTrons
	class Commands
		attr_accessor :protocol, :command_list

		def initialize(protocol)
			@protocol = protocol
			@command_list = []
		end

		# return a pure list of hashes
		def to_list
			return command_list.map {|command| command.to_hash}
		end

		def to_s
			"<OpenTrons::Commands:0x#{self.__id__.to_s(16)}>"
		end

		def inspect
			to_s
		end
	end

	class Command
		attr_accessor :command, :params

		#parent class for all the comands
		def initialize(command, params)
			@command = command
			@params = params
		end

		def to_hash
			as_hash = {}
			as_hash["command"] = command
			as_hash["params"] = params
			return as_hash
		end

		def to_s
			"<OpenTrons::Command:0x#{self.__id__.to_s(16)}>"
		end

		def inspect
			to_s
		end
	end

	class PipetteCommand < Command
		attr_accessor :pipette, :location

		def initialize(command, pipette, location)
			super(command, {})

			pipette_id = pipette.instruments.instrument_hash.key pipette
			params["pipette"] = pipette_id

			if location.is_a? Array
				labware_item = location[0].labware_item
				params["labware"] = labware_item.labware.labware_hash.key labware_item
				params["well"] = location[0].location
				params["position"] = location[1]
			else
				labware_item = location.labware_item
				params["labware"] = labware_item.labware.labware_hash.key labware_item
				params["well"] = location.location
			end
		end
	end

	class VolumeCommand < PipetteCommand
		attr_accessor :volume

		def initialize(command, pipette, volume, location)
			super(command, pipette, location)
			params["volume"] = volume
		end
	end

	class Delay < Command
		def initialize(wait, message)
			super("delay", {"wait" => wait, "message" => message})
		end
	end

	class Aspirate < VolumeCommand
		def initialize(pipette, volume, location)
			super("aspirate", pipette, volume, location)
		end
	end

	class Dispense < VolumeCommand
		def initialize(pipette, volume, location)
			super("dispense", pipette, volume, location)
		end
	end

	class AirGap < VolumeCommand
		def initialize(pipette, volume, location)
			super("air-gap", pipette, volume, location)
		end
	end

	class PickUpTip < PipetteCommand
		def initialize(pipette, location)
			super("pick-up-tip", pipette, location)
		end
	end

	class DropTip < PipetteCommand
		def initialize(pipette, location)
			super("drop-tip", pipette, location)
		end
	end

	class TouchTip < PipetteCommand
		def initialize(pipette, location)
			super("touch-tip", pipette, location)
		end
	end

	class BlowOut < PipetteCommand
		def initialize(pipette, location)
			super("blowout", pipette, location)
		end
	end
end