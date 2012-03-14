root = ENV[ "APP_ROOT" ]

unless defined? Bundler
  ENV[ "BUNDLE_GEMFILE" ] ||= "#{ root }/Gemfile"
  begin
    require "bundler"
  rescue
    require "rubygems"
    require "bundler"
  ensure
    Bundler.setup
  end
end

require "#{ root }/lib/config"

require "resque"
Resque.redis = CONFIG.redis_connection_string || "localhost:6379"
