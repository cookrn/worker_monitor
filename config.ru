$stdout.sync      = true
ENV[ "APP_ROOT" ] = root = File.dirname File.expand_path( __FILE__ )

require "#{ root }/config/boot"

use Rack::CommonLogger
use Rack::Auth::Basic , CONFIG.application_name do | login , password |
  valid_login    = login    == CONFIG.basic_auth_username
  valid_password = password == CONFIG.basic_auth_password
  valid_login && valid_password
end

require "resque/server"
run Resque::Server
