require 'rubygems'
require 'sinatra'
require 'rack/cache'

Sinatra::Application.default_options.merge!(
  :run => false,
  :environment => ENV['RACK_ENV']
)

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'file:/var/cache/rack/meta',
  :entitystore => 'file:/var/cache/rack/body'

require 'go_get_me_some'
run Sinatra::Application