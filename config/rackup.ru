require 'rubygems'
require 'sinatra'
 
set :environment, :production

require app_file = File.dirname(__FILE__) + "/../go_get_me_some"

set :app_file, app_file
set :views, File.dirname(__FILE__) + '/../views'
set :public, File.dirname(__FILE__) + '/../public'

run Sinatra::Application
