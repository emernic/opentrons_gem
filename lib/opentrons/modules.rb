module OpenTrons
	class Modules
		attr_accessor :protocol, :module_hash

		def initialize(protocol)
			@protocol = protocol
			@module_hash = {}
		end
		
		def load(model, slot)
			generated_id = ""
			loop do
				generated_id = model + "-" + rand(100000...999999).to_s
				break if !(module_hash.key?(generated_id))
			end

			if model == 'tempdeck'
				module_item = TempDeck.new(self, model, slot)
			else
				raise ArgumentError.new "Only tempdeck module currently supported."
			end

			module_hash[generated_id] = module_item

			return module_item
		end

		# Returns a pure hash of hashes.
		def to_hash
			as_hash = {}
			module_hash.each do |key, item|
				as_hash[key] = item.to_hash
			end
			return as_hash
		end

		def to_s
			"<OpenTrons::Modules:#{object_id}>"
		end

		def inspect
			to_s
		end
	end

	class ModuleItem
		attr_accessor :modules, :model, :slot

		def initialize(modules, model, slot)
			@modules = modules
			@model = model
			@slot = slot
		end

		def to_hash
			as_hash = {}
			as_hash["model"] = model
			as_hash["slot"] = slot
			return as_hash
		end

		def to_s
			"<OpenTrons::ModuleItem:0x#{self.__id__.to_s(16)}>"
		end

		def inspect
			to_s
		end
	end

	class TempDeck < ModuleItem
		def set_temperature(temp)
			command = SetTemp.new(self, temp)
			protocol.commands.command_list << command
			return command
		end

		def wait_for_temp
			command = WaitTemp.new(self)
			protocol.commands.command_list << command
			return command
		end
	end
end