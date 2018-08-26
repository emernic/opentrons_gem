module OpenTrons
	PIPETTE_NAMES = {
		P10_Single: "p10_single_v1",
		P10_Multi: "p10_multi_v1",
		P50_Single: "p50_single_v1",
		P50_Multi: "p50_multi_v1",
		P300_Single: "p300_single_v1",
		P300_Multi: "p300_multi_v1",
		P1000_Single: "p1000_single_v1",
		P1000_Multi: "p1000_multi_v1"
	}

	class Instruments
		attr_accessor :protocol, :instrument_hash

		def initialize(protocol)
			@protocol = protocol
			@instrument_hash = {}
		end

		# Individual methods to maintain similarities w/ Python API.
		PIPETTE_NAMES.each do |method_name, pipette_name|
			define_method(method_name) do |**kwargs|
  				return add_pipette(pipette_name, **kwargs)
			end
		end

		def add_pipette(model, **kwargs)
			instrument_hash.each do |key, item| 
				if item.mount == kwargs[:mount]
					raise ArgumentError "Cannot place #{kwargs[:model]} on mount #{kwargs[:model]} (already occupied)."
				end
			end

			generated_id = ""
			loop do
				generated_id = model + "-" + rand(100000...999999).to_s
				break if !(instrument_hash.key? generated_id)
			end

			if model.include? "multi"
				pipette = MultiPipette.new(protocol, self, model, **kwargs)
			else
				pipette = Pipette.new(protocol, self, model, **kwargs)
			end

			instrument_hash[generated_id] = pipette

			return pipette
		end

		def to_hash
			as_hash = {}
			instrument_hash.each do |key, item|
				as_hash[key] = item.to_hash
			end
			return as_hash
		end

		def to_s
			"<OpenTron::Instruments:#{object_id}>"
		end

		def inspect
			s = "#{self.to_s} "
			instance_variables.each do |var_name|
				s << "#{var_name}=#{var_name.to_s} "
			end
			return s
		end
	end

	class Pipette
		attr_accessor :protocol, :instruments, :mount, :model, :tip_racks

		def initialize(protocol, instruments, model, **kwargs)
			@protocol = protocol
			@instruments = instruments
			@model = model
			@mount = kwargs[:mount]
			@tip_racks = kwargs[:tip_racks] if kwargs.key? :tip_racks
		end

		def to_hash
			as_hash = {}
			as_hash["mount"] = mount
			as_hash["model"] = model
			return as_hash
		end

		def to_s
			"<OpenTron::Pipette:#{object_id}>"
		end

		def inspect
			s = "#{self.to_s} "
			instance_variables.each do |var_name|
				s << "#{var_name}=#{var_name.to_s} "
			end
			return s
		end

		def aspirate(volume, location)
			command = Aspirate.new(self, volume, location)
			protocol.commands.command_list << command
			return command
		end

		def dispense(volume, location)
			command = Dispense.new(self, volume, location)
			protocol.commands.command_list << command
			return command
		end

		# For whatever reason, air gap has no location in Python API but has a location in the JSON schema.
		# Not implemented for now.
		# def air_gap(volume, location)
		# 	command = Aspirate.new(self, volume, location)
		# 	self.protocol.commands << command
		# 	return command
		# end

		def pick_up_tip(location=false)
			if !location
				catch :tip_found do
					tip_racks.each do |tip_rack|
						tip_rack.well_list.each do |column|
							column.each do |x|
								if x.tip
									location = x
									throw :tip_found
								end
							end
						end
					end
					raise ArgumentError "pick_up_tip called without location and pipette is out of tips."
				end
			end
			
			if location.is_a? Array
				well = location[0]
			else
				well = location
			end

			if !(well.tip)
				puts "Warning: Already picked up tip at #{location}."
			else
				well.tip = false
			end

			command = PickUpTip.new(self, location)
			protocol.commands.command_list << command
			return command
		end

		def drop_tip(location=false)
			location = protocol.trash.wells(0) if !location
			command = DropTip.new(self, location)
			protocol.commands.command_list << command
			return command
		end

		def touch_tip(location)
			command = TouchTip.new(self, location)
			protocol.commands.command_list << command
			return command
		end

		def blowout(location)
			command = Blowout.new(self, location)
			protocol.commands.command_list << command
			return command
		end

		def delay(wait, message="")
			command = Delay.new(wait, message)
			protocol.commands.command_list << command
			return command
		end
	end

	class MultiPipette < Pipette
		def initialize(protocol, instruments, model, **kwargs)
			super(protocol, instruments, model, **kwargs)
		end

		def pick_up_tip(location=false)
			if !location
				catch :tip_found do
					tip_racks.each do |tip_rack|
						tip_rack.well_list.each do |column|
							if column.all? {|x| x.tip}
								location = column[0]
								throw :tip_found
							end
						end
					end
					raise ArgumentError "pick_up_tip called without location and pipette is out of tips."
				end
			end

			if location.is_a? Array
				well = location[0]
			else
				well = location
			end

			column = well.labware_item.well_list.find do |column|
				column.include? well
			end

			column.each {|x| x.tip = false}
			
			command = PickUpTip.new(self, location)
			protocol.commands.command_list << command
			return command
		end
	end
end