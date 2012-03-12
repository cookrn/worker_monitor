exec /usr/bin/env rvm-shell "$CONFIG_APP_RUBY" -c "bundle exec 'rackup -s thin -p $PORT -E $RACK_ENV'"
