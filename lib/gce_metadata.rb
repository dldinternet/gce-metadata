require 'gce_metadata/version'
require 'net/http'
Net::HTTP.version_1_2
require 'ec2_metadata'

module GCEMetadata
	DEFAULT_HOST = "metadata.google.internal".freeze
	DEFAULT_REVISION = 'v1'

	autoload :HttpClient, 'gce_metadata/http_client'
	autoload :Base, 'gce_metadata/base'
	autoload :Root, 'gce_metadata/root'
	autoload :Revision, 'gce_metadata/revision'
	autoload :Dummy, 'gce_metadata/dummy'
	autoload :Command, 'gce_metadata/command'

	# include Ec2Metadata
	extend HttpClient

	class << self
		attr_accessor :debug
		@debug = false

		def instance
			@instance ||= Root.new['computeMetadata']
		end

		def clear_instance
			@instance = nil
		end

		def [](key)
			instance[key]
		end

		def to_hash(revision = DEFAULT_REVISION)
			self[revision].to_hash
		end

		def from_hash(hash, revision = DEFAULT_REVISION)
			# hash = {revision => hash}
			# instance.from_hash(hash)
			rev_obj = instance.new_child(revision)
			instance.instance_variable_set(:@children, {revision => rev_obj})
			instance.instance_variable_set(:@child_keys, [revision])
			rev_obj.from_hash(hash)
		end

		def formalize_key(key)
			#key.to_s.gsub(/_/, '-')
			key
		end

		def logging(msg)
			@indent ||= 0
			@indent += 2
			disp = (" " * @indent) << msg
			#puts(disp) if @debug
			begin
				result = yield
				puts "#{disp} => #{result.inspect}" if @debug
				#puts "#{(" " * @indent)}  #{result.inspect}" if @debug
			ensure
				@indent -= 2
			end
			result
		end
	end

	class NotFoundError < StandardError
	end

end

unless ENV['GCE_METADATA_DUMMY_DISABLED'] =~ /yes|true|on/i
	GCEMetadata::Dummy.search_and_load_yaml
end
