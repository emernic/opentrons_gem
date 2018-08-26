module OpenTrons
	class Labware
		attr_accessor :protocol, :labware_hash, :labware_definitions

		def initialize(protocol)
			@protocol = protocol
			@labware_hash = {}

			#TODO: Better system for dealing with labware defs, including user-specified.
			@labware_definitions = []
			directory = File.expand_path(File.dirname(__FILE__))
			directory = File.join(directory, "..", "..", "definitions")
			Dir[directory + "/*.json"].each do |filename|
				labware_definitions << JSON.parse(File.read(filename))
			end
		end

		def load(model, slot, display_name="")
			generated_id = ""
			loop do
				generated_id = display_name + "-" + rand(100000...999999).to_s
				break if !(labware_hash.key?(generated_id))
			end

			labware_item = LabwareItem.new(self, model, slot, display_name)

			labware_hash[generated_id] = labware_item

			return labware_item
		end

		# Returns a pure hash of hashes.
		def to_hash
			as_hash = {}
			labware_hash.each do |key, item|
				as_hash[key] = item.to_hash
			end
			return as_hash
		end

		def to_s
			"<OpenTron::Labware:#{object_id}>"
		end

		def inspect
			s = "#{self.to_s}"
			instance_variables.each do |var_name|
				s << "#{var_name}=#{var_name.to_s} "
			end
			return s
		end

	end

	class LabwareItem
		attr_accessor :labware, :well_list, :model, :slot, :display_name, :definition

		def initialize(labware, model, slot, display_name)
			if labware.labware_hash.map {|key, item| item.slot}.include? slot
				raise ArgumentError "Cannot place #{display_name} in slot #{slot} (already occupied)."
			end

			@labware = labware
			@model = model
			@slot = slot
			@display_name = display_name
			@definition = labware.labware_definitions.find{|x| x["metadata"]["name"] == model}
			@well_list = []
			definition["ordering"].each do |column|
				well_list << column.map {|x| Well.new(self, x)}
			end

		end

		def wells(location)
			if location.is_a? String
				well_list.each do |column|
					column.each do |x|
						if x.location == location
							return x
						end
					end
				end
			elsif location.is_a? Integer
				i = location
				well_list.each do |column|
					column.each do |x|
						if i == 0
							return x
						end
						i -= 1
					end
				end
			end

			raise ArgumentError "wells must be specified as Integer or String, not #{location.class}"
		end

		def to_hash
			as_hash = {}
			as_hash["model"] = model
			as_hash["slot"] = slot
			as_hash["display-name"] = display_name
			return as_hash
		end

		def to_s
			"<OpenTron::LabwareItem:#{object_id}>"
		end

		def inspect
			s = "#{self.to_s} "
			instance_variables.each do |var_name|
				s << "#{var_name}=#{var_name.to_s} "
			end
			return s
		end
	end

	class Well
		attr_accessor :labware_item, :location, :tip

		def initialize(labware_item, location)
			@labware_item = labware_item
			@location = location
			@tip = true
		end

		def top(z)
			position = {
				"anchor" => "top",
				"offset" => {
					"z" => z
				}
			}
			return [self, position]
		end

		def bottom(z)
			position = {
				"anchor" => "bottom",
				"offset" => {
					"z" => z
				}
			}
			return [self, position]
		end

		def to_s
			"<OpenTron::Well:#{object_id}>"
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