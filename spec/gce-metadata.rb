require 'gce_metadata'
require 'awesome_print'

GCEMetadata.debug = true
start = Time.now
data = GCEMetadata[GCEMetadata::DEFAULT_REVISION]['instance'].to_hash
stop  = Time.now
puts "#{(stop-start)}s\n#{data.ai}\n"
