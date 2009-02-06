require 'rubygems'
require 'sinatra'

root_dir = File.dirname(__FILE__)
 
Sinatra::Application.default_options.merge!(
  :views    => File.join(root_dir, 'views'),
  :app_file => File.join(root_dir, 'go_get_me_some.rb'),
  :run => false,
  :env => :production
)

run Sinatra.application