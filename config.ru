$stdout.sync = true
root         = File.dirname File.expand_path( __FILE__ )

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

use Rack::CommonLogger

require "#{ root }/lib/config"
use Rack::Auth::Basic , CONFIG.application_name do | login , password |
  valid_login    = login    == CONFIG.basic_auth_username
  valid_password = password == CONFIG.basic_auth_password
  valid_login && valid_password
end

require "resque/server"
run Resque::Server
