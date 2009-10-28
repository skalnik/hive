require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'haml'
require 'yaml'
require 'sinatra/authorization'
require 'models/entry'
Dir['lib/*'].each { |lib| require lib }

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
    tweets(@@twitter_username)
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

post '/entries' do
  login_required
  entry = Entry.new(params)
  entry.save!
  redirect "entries/#{entry.id}"
end

get '/entries/:id' do
  @entry = Entry.find(params[:id])
  haml :show
end

