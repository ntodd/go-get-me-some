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
  
  # can't use CGI.escape() on deployment server, so using a gsub to catch spaces in the url
  topic = params[:topic].gsub(/\s+/, '%20')
  doc = open("http://images.google.com/images?um=1&hl=en&client=safari&rls=en-us&btnG=Search+Images&ei=ubeLSbSgGqTUMbzxzZAL&gbv=1&ei=lLqLSYWsFaX6NJrzyIkL&q=#{topic}") { |f| Hpricot(f) }

  #grab full google img element for backup display if hotlinking fails
  @google_image = (doc/"table/tr/td/a/img").first  

  # fetch hotlinking image source
  anchor = (doc/"div#ImgCont/p/table/tr/td/a").first
  @remote_image_src = anchor.to_s.match(/imgurl=(http:\/\/[^&]+)/)[1] unless anchor.nil?

  haml :view
end
