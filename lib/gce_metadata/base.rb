require 'gce_metadata'

module GCEMetadata
  class Base

    attr_reader :path
    attr_reader :default_child_key
    
    def initialize(path, default_child_key = nil)
      @path = path
      @default_child_key = default_child_key
		end

		def class_name
			self.class.name.gsub(/^GCEMetadata/, '').gsub(/^:+/,'')
		end

    def children
      @children ||= {}
    end
    
    def child_keys
      unless defined?(@child_keys)
        lines = GCEMetadata.get("#{path}").split(/$/).map(&:strip).select{|l| not (l.nil? or l.empty?)} # .map{|l| l.gsub!(%r'/$','')}
				leaves = lines.select{|line| line =~ %r'[^/]$'}
				@child_keys = lines
        if leaves.size > 0
          @child_names = {}
          leaves.each do |key|
						name = get(key)
						name = name.match(/^\[.*?\]$/) ? (eval name rescue name) : name
            @child_names[key] = name
          end
        end
      end
      @child_keys
    end
    alias_method :keys, :child_keys

    def get(child_key)
      logging("#{class_name}.get(#{child_key.inspect})") do
        child_key = GCEMetadata.formalize_key(child_key)
        if children.has_key?(child_key)
          result = children[child_key]
        else
          if is_child_key?(child_key)
            result = is_struct?(child_key) ?
              new_child(child_key) :
              GCEMetadata.get("#{path}#{child_key}")
						unless result
							if is_child_key?("#{child_key}/")
								child_key = "#{child_key}/"
								result = is_struct?(child_key) ?
										new_child(child_key) :
										GCEMetadata.get("#{path}#{child_key}")
							end
						end
          else
            raise NotFoundError, "#{path}#{child_key} not found as default key" if @getting_default_child
            raise NotFoundError, "#{path}#{child_key} not found" unless default_child
            result = default_child.get(child_key)
          end
          children[child_key] = result
        end
        result
      end
    end
    alias_method :[], :get

    def is_child_key?(key)
      exp = /^#{key.gsub(%r'([^/])$', '\1/')}?$/
      child_keys.any?{|child_key| child_key =~ exp}
    end

    def is_struct?(child_key)
      k = GCEMetadata.formalize_key(child_key)
      #k << '/' unless k.match(%r'/$')
      k.match(%r'/$') || (defined?(@child_names) && @child_names.keys.include?(child_key))
    end

    def new_child(child_key)
      if defined?(@child_names) && (name = @child_names[child_key])
        grandchild = Base.new("#{path}#{child_key}/")
        child = Base.new("#{path}#{child_key}/")
        child.instance_variable_set(:@children, {name => grandchild})
        child.instance_variable_set(:@child_keys, [name])
        child
      else
        Base.new("#{path}#{child_key}")
      end
    end

    def default_child
      return @default_child if @default_child
      logging("default_child") do
        if default_child_key
          @getting_default_child = true
          begin
            @default_child = get(default_child_key) 
          ensure
            @getting_default_child = false
          end
        end
      end
    end

    def to_hash
      keys.inject({}) do |dest, key|
        value = get(key)
        key = key.sub(/\/$/, '')
        dest[key] = value.respond_to?(:to_hash) ? value.to_hash : value
        dest
      end
    end

    def from_hash(hash)
      hash = hash.inject({}){|d, (k, v)| d[GCEMetadata.formalize_key(k)] = v; d}
      @child_keys = hash.keys
      @children = {}
      hash.each do |key, value|
        if value.is_a?(Array)
          idx = 0
          value = value.inject({}){|d, v| d[idx] = v; idx += 1; d}
        end
        if value.is_a?(Hash)
          child = new_child(key)
          @children[key] = child
          child.from_hash(value)
        else
          @children[key] = value
        end
      end
    end


    private
    def logging(msg, &block)
      GCEMetadata.logging(msg, &block)
    end

  end
end
