# GET ME SOME SOURCE CODE!
# 
# Code by Nate Todd and Jonathan Crossman
# Built because... YES WE CAN!
# 2/6/09 is a day not unlike any other day

$:.unshift *Dir[File.dirname(__FILE__) + '/vendor/*/lib']
require 'rubygems'
require 'sinatra'
require 'haml'
require 'hpricot'
require 'open-uri'
require 'activerecord'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'db/go_get_me_some.db'
)

class Topic < ActiveRecord::Base
  named_scope :recent, lambda { |limit| { :order => 'timestamp DESC', :limit => limit} }
  named_scope :top, lambda { |limit| { :group => 'topic', :order => 'topic ASC', :limit => limit} }
end

helpers do
  def to_pretty(topic_time)
    a = (Time.now-topic_time).to_i

    case a
      when 0 then return "just now"
      when 1 then return "a second ago"
      when 2..59 then return a.to_s+' seconds ago' 
      when 60..119 then return 'a minute ago' #120 = 2 minutes
      when 120..3540 then return (a/60).to_i.to_s+' minutes ago'
      when 3541..7100 then return 'an hour ago' # 3600 = 1 hour
      when 7101..82800 then return ((a+99)/3600).to_i.to_s+' hours ago' 
      when 82801..172000 then return 'a day ago' # 86400 = 1 day
      when 172001..518400 then return ((a+800)/(60*60*24)).to_i.to_s+' days ago'
      when 518400..1036800 then return 'a week ago'
    end
    return ((a+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
  end
end

before do 
  # kill trailing slashes for all requests except '/'
  request.env['PATH_INFO'].gsub!(/\/$/, '') if request.env['PATH_INFO'] != '/'
end

set :public, File.dirname(__FILE__) + '/public'

get '/' do
  @recent_topics = Topic.recent(10)
  # @top_10 = Topic.top(10)
  haml :index
end

get '/list_topics' do
  @topics = Topic.find(:all, :group => 'topic', :order => 'lower(topic) ASC')
  response.headers['Cache-Control'] = 'public, max-age=100000'
  haml :topics
end

get '/topic_count' do
  "#{Topic.count}"
end

get '/:topic' do
  fetch_and_display(params[:topic], 1)
end

get '/:topic/:img_number' do
  fetch_and_display(params[:topic], params[:img_number])
end

private
def fetch_and_display(topic_url, img_number)
  
  # can't use CGI.escape() on deployment server, so using a gsub to catch spaces in the url
  topic = topic_url.gsub(/\s+/, '%20')
  doc = open("http://images.google.com/images?um=1&hl=en&client=safari&rls=en-us&btnG=Search+Images&ei=ubeLSbSgGqTUMbzxzZAL&gbv=1&ei=lLqLSYWsFaX6NJrzyIkL&q=#{topic}") { |f| Hpricot(f) }

  # fetch hotlinking image source
  anchor = (doc/'table[@align="center"]/tr/td/a[@href*="imgurl"]')[img_number.to_i - 1]
  @thumbnail = (anchor/'img').first['src'] unless anchor.nil?
  
  @remote_image_src = anchor['href'].match(/imgurl=(http:\/\/[^&]+(?:jpe?g|gif|png)?)/)[1] unless anchor.nil?
      
  # Create the entry
  Topic.new( :topic => topic, :timestamp => Time.now ).save unless anchor.nil?
  
  # Find a random entry
  @random_topic = Topic.first(:order => "random()", :select => "DISTINCT(topic)")
  
  haml :view
end