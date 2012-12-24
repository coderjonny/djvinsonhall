require "zurb-foundation"
require 'sinatra'
require 'haml'
require 'instagram'

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

set :haml, {:format  => :html5}
set :root, File.dirname(__FILE__)
set :views, 'views'

configure do
  set :haml, {:format => :html5, :escape_html => true}
  set :scss, {:style => :compact, :debug_info => false}
end

Instagram.configure do |config|
    config.client_id = "21c01464fcf54617992fae0b92c9c09a"
    config.client_secret = "f40167c551c146dc90b923631f51607d"
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}" )
end

get '/' do
  client = Instagram.client(:access_token => session[:access_token])
  @user = client.user.profile_picture
  @recent = []
  for media_item in client.user_recent_media(245080958)
    @recent << media_item.images.thumbnail.url
  end

  haml :index
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/feed"
end

get "/feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  html = "<h1>#{user}'s recent photos</h1>"
  for media_item in client.user_recent_media(245080958)
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get '/vinny' do
  vinny = Instagram.user_search("vinson_hall")
  html = ""
  html << "<p> #{vinny} </p>"
  html
end
