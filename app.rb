require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'haml'
require 'yaml'
require 'sinatra/authorization'
require 'twitter'
require 'models/entry'

configure do
  config = YAML::load_file('config.yml')
  MongoMapper.connection = Mongo::Connection.new(config['database']['host'])
  MongoMapper.database = config['database']['name']
  if config['database']['username']
    MongoMapper.database.authenticate(config['database']['username'], config['database']['password'])
  end

  @@username, @@password = config['site']['username'], config['site']['password']
  @@twitter_username = config['twitter']['username']
end

helpers do
  def authorize(username, password)
    [username, password] == [@@username, @@password]
  end

  def authorization_realm
    "Protected zone"
  end

  def fetch_tweets
    client = Twitter::Client.new
    status = client.timeline_for(:user, :id => @@twitter_username)
    tweets = []
    status.each do |tweet|
      twt = {:content => tweet.text, :source => 'Twitter',
             :link => "http://twitter.com/#{@@twitter_username}/status/#{tweet.id}"}
      tweets << twt
    end
    return tweets
  end
end

['/', '/entries'].each do |path|
  get path do
    @entries = Entry.all( :order => 'created_at DESC' )
    haml :index
  end
end

get '/entries/new' do
  login_required
  haml :new
end

get '/entries/:id' do
  @entry = Entry.find(params[:id])
  haml :show
end

post '/entries' do
  entry = Entry.new(params)
  entry.save!
  redirect "entries/#{entry.id}"
end

get '/fetch_tweets' do
  tweets = fetch_tweets
  puts tweets.inspect
  tweets.each do |tweet|
    unless Entry.count(tweet) > 0
      entry = Entry.new(tweet)
      entry.save!
    end
  end
  redirect '/'
end
