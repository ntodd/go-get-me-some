$:.unshift *Dir[File.dirname(__FILE__) + '/vendor/*/lib']
require 'rubygems'
require 'sinatra'
require 'haml'
require 'hpricot'
require 'open-uri'

get '/' do
  haml :index
end

get '/:topic' do  
  doc = open("http://images.google.com/images?um=1&hl=en&client=safari&rls=en-us&btnG=Search+Images&ei=ubeLSbSgGqTUMbzxzZAL&gbv=1&ei=lLqLSYWsFaX6NJrzyIkL&q=#{params[:topic]}") { |f| Hpricot(f) }
  @image = (doc/"table/tr/td/a/img").first
  haml :view
end
