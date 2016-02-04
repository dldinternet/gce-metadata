# -*- coding: utf-8 -*-
require 'ec2_metadata'
require 'hash_key_orderable'
require 'yaml'
require 'awesome_print'

module GCEMetadata
  module Command
    class << self
      DATA_KEY_ORDER = %w(instance project)
      META_DATA_KEY_ORDER =
        %w( attributes
            cpu-platform
            description
            disks
            hostname
            id
            image
            licenses
            machine-type
            maintenance-event
            network-interfaces
            scheduling
            service-accounts
            tags
            virtual-clock
            zone
            )

      def show(api_version = 'v1')
        timeout do
          v = (api_version || '').strip
          keys = GCEMetadata.instance.keys
          unless keys.include?(v.gsub(%r'([^/])$', '\1/'))
						puts("#{class_name}.instance.keys\n#{keys.ai}")
            raise ArgumentError, "API version must be one of #{GCEMetadata.instance.keys.inspect} but was #{api_version.inspect}"
          end
          show_yaml_path_if_loaded
          data = GCEMetadata.instance.to_hash
          data = data[v]
          data.extend(HashKeyOrderable)
          data.key_order = DATA_KEY_ORDER
          meta_data = data['instance']
          meta_data.extend(HashKeyOrderable)
          meta_data.key_order = META_DATA_KEY_ORDER
          puts YAML.dump(data)
        end
      end

      def show_api_versions
        timeout do
          show_yaml_path_if_loaded
          puts GCEMetadata.instance.keys
        end
      end

      def show_dummy_yaml
        show_yaml_path_if_loaded
        puts IO.read(File.expand_path(File.join(File.dirname(__FILE__), 'dummy.yml')))
      end

      private
      def timeout
        begin
          yield
        rescue Timeout::Error, SystemCallError => error
          puts "HTTP request timed out. You can use dummy YAML for non GCE Instance. #{Dummy.yaml_paths.inspect}"
        end
      end

      def show_yaml_path_if_loaded
        if path = GCEMetadata::Dummy.loaded_yaml_path
          puts "Actually these data is based on a DUMMY yaml file: #{path}"
        end
      end
    
    end
  end
end
