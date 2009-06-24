require 'rubygems'
require 'sinatra'
require 'rack/cache'

Sinatra::Application.default_options.merge!(
  :run => false,
  :environment => ENV['RACK_ENV']
)

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'file:/home/ntodd/public_html/go-get-me-some/tmp/cache/meta',
  :entitystore => 'file:/home/ntodd/public_html/go-get-me-some/tmp/cache/body'

require 'go_get_me_some'
run Sinatra::Application