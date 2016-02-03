require 'ec2_metadata'

module GCEMetadata
  class Root < Base
    def initialize(path = '/')
      @path = path
      @default_child_key = 'v1'
    end

    def new_child(child_key)
      logging("new_child(#{child_key.inspect})") do
        Revision.new("#{path}#{child_key}/")
      end
    end

    def is_struct?(child_key)
      true
    end
    
  end
end
