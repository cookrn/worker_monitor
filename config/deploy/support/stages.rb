if CONFIG.deploy_stages
  stages = CONFIG.deploy_stages.split ","
else
  stage_files = Dir[ "#{ File.expand_path File.join( File.dirname( __FILE__ ) , ".." ) }/*.rb" ]
  stages = stage_files.map { | f | File.basename( f ).split( ".rb" )[ 0 ] }
end

set :stages , stages
