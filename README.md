# Worker Monitor

This is an example, deploy-ready application to setup a password-protected Resque web server. This is used to monitor Resque deployments. It does not run any workers for you.

## Caveats

This is setup to use [RVM](https://rvm.beginrescueend.com/), [Foreman](http://ddollar.github.com/foreman/), [Bundler](http://gembundler.com/) and [Capistrano](http://capify.org/). It is also setup to have staged deployments using `capistrano-ext`. The default stage is `dev`.

RVM is setup to expect a multi-user install.

Foreman is setup to export for `upstart`, which is standard on Ubuntu-based deployments.

## Setup

* Clone it locally to your machine
* Setup your local `.env` file. This is standard for [Foreman](https://github.com/ddollar/foreman)
* Include the required keys: `CONFIG_APP_RUBY`, `CONFIG_BASIC_AUTH_USERNAME`, `CONFIG_BASIC_AUTH_PASSWORD`, `CONFIG_DEPLOY_APPLICATION`, `CONFIG_DEPLOY_REPOSITORY`, and `RACK_ENV`
* Run `bundle install`
* Run `exe/foreman start` -- you are now running the app locally

## .env Keys

* `CONFIG_APP_RUBY` -- The ruby version string that RVM will use
* `CONFIG_APPLICATION_NAME` -- The human-readable name of your application
* `CONFIG_BASIC_AUTH_USERNAME` -- The basic auth username
* `CONFIG_BASIC_AUTH_PASSWORD` -- The basic auth password
* `CONFIG_DEPLOY_APPLICATION` -- The application's name. This should be safe for use as a directory name on *nix systems.
* `CONFIG_DEPLOY_REPOSITORY` -- The SSH git URL to be deployed from
* `RACK_ENV` -- The Rack environment to be deployed

## Optional .env Keys

These keys will be set automatically based on your setup. Feel free to override them.

* `CONFIG_DEPLOY_DEFAULT_STAGE` -- The default deployment stage. This should be configured in a Ruby file. For a stage named "demo", define your stage configuration in `config/deploy/demo.rb`. This key will be set automatically if you only have one stage. If you have more than one stage and you do NOT set this key, an error will be raised.
* `CONFIG_DEPLOY_STAGES` -- A comma separated list of the available stages.
* `CONFIG_REDIS_CONNECTION_STRING` -- A redis connection host/IP and port e.g. "1.2.3.4:6379" or "host.com:6379"

## Defining Stages

This is just standard Capistrano multi-stage!

By default, all files ending in `.rb` inside of `config/deploy` (at the first level) will be used to define stages. To see how this works, look in `config/deploy/support/stages.rb`. For a stage named `demo`, this file (`config/deploy/demo.rb`) might look like this:

```ruby
set :app_env          , "demo"
set :application_port , "8000"
set :branch           , "master"
set :deploy_to        , "/var/www/#{ application }/#{ app_env }"
set :user             , "ubuntu"

ssh_options[ :keys ] = [ File.join( ENV[ "HOME" ] , ".ssh" , "sample.pem") ]

server "1.2.3.4" , :app , :web , :primary => true
```

If you wish to override this automatic behavior, set the `CONFIG_DEPLOY_STAGES` key in your `.env` file to a comma separated list of stage names e.g. `CONFIG_DEPLOY_STAGES=dev,prod`.

## Deploying

* Run `exe/cap deploy:setup` (You may need to insert the desired stage name like `exe/cap demo deploy:setup`)
* Create the environment file on the server in the shared directory named `{STAGE}.env` where `{STAGE}` is replaced with the stage's name
* Run `exe/cap deploy`

This application is meant to be run behind a reverse proxy such as `Nginx`. You will need to complete additional configuration for said reverse proxy to pass requests to your application.

## Recommendations

It is recommended that you run this application over SSL as it's only authentication mechanism is standard HTTP Basic Authentication.

## License

MIT

## Questions or Comments?

Create issues and I will respond as soon as I am able. Feel free to [email me](mailto:cookrn@gmail.com?Subject=Worker%20Monitor).
