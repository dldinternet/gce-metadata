require 'erb'
require 'yaml'

module GCEMetadata
  module Dummy
		YAML_FILENAME = 'gce_metadata.yml'.freeze
		YAML_SEARCH_DIRS = ['./config', '.', '~', '/etc'].freeze
		ENV_SPECIFIED_PATH = "GCE_METADATA_DUMMY_YAML".freeze

		class << self
			def yaml_paths
				dirs = YAML_SEARCH_DIRS.dup
				if Module.constants.include?('RAILS_ROOT')
					dirs.unshift(File.join(Module.const_get('RAILS_ROOT'), 'config'))
				end
				result = dirs.map{|d| File.join(d, YAML_FILENAME)}
				if (specified_path = ENV[ENV_SPECIFIED_PATH])
					result.unshift(specified_path)
				end
				result
			end

			def search_and_load_yaml
				paths = Dir.glob(yaml_paths.map{|path| File.expand_path(path) rescue nil}.compact)
				load_yaml(paths.first) unless paths.empty?
			end

			def load_yaml(path)
				erb = ERB.new(IO.read(path))
				erb.filename = path
				text = erb.result
				GCEMetadata.from_hash(YAML.load(text))
				@loaded_yaml_path = path
			end

			def loaded_yaml_path
				@loaded_yaml_path
			end
		end
	end
end
