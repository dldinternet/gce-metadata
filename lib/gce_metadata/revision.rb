require 'gce_metadata'

module GCEMetadata
  class Revision < Base
    def initialize(path)
      @path = path
      @default_child_key = 'v1/'
    end

    def new_child(child_key)
      logging("new_child(#{child_key.inspect})") do
        child_path = "#{path}#{child_key}"
        child_path << '/' if (is_struct?(child_key) and not child_key.match(%r'/$'))
        Base.new(child_path)
      end
    end

    def is_struct?(child_key)
      child_key =~ /\/$/
    end
    
  end
end
