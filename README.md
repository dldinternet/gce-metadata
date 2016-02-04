# gce-metadata

## Credit

Full credit and attribution to http://github.com/akm/ec2-metadata on which this gem is based 

## Install
 $ [sudo] gem install gce-metadata

## As ruby library
gce-metadata provides a way to access meta-data and user-data on GCE instance. 

 GCEMetadata[:instance_id]
 GCEMetadata['instance_id']
 GCEMetadata[:'instance-id']
 GCEMetadata['instance-id']

If you want to specify API version, you can get data like this:
 GCEMetadata['1.0'][:instance_id]

If you can also get it like this:
 GCEMetadata['1.0']['meta-data'][:instance_id]


## As a command
gce-metadata shows various meta-data and user-data
 $ gce-metadata

For more detail, type 
 $ gce-metadata -h


## Dummy YAML
If you want to access meta-data or user-data not on GCE Instance like on it,
make one of these files
 ./config/gce_metadata.yml
 ./gce_metadata.yml
 ~/gce_metadata.yml
 /etc/gce_metadata.yml

Dummy YAML file must be like output of gce-metadata on GCE instance.
You can export it on GCE instance like this:
 $ gce-medatata > gce_metadata.yml
 $ cp gce_metadata.yml /path/to/dir/for/non/gce/instance

Or if you don't have GCE instance, you can get an example by
 $ gce-metadata -d


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2015 DLD Internet, Inc. See LICENSE for details.
