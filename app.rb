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
  @@twitter_username = config['twitter']['username'] if config['twitter']
  @@github_username = config['github']['username'] if config['github']
  @@last_fm_username = config['last_fm']['username'] if config['last_fm']
end

helpers do
  def authorize(username, password)
    [username, password] == [@@username, @@password]
  end

  def authorization_realm
    "Protected zone"
  end

  def twitter_username
    @@twitter_username
  end

  def github_username
    @@github_username
  end

  def last_fm_username
    @@last_fm_username
  end
end

['/', '/entries'].each do |path|
  get path do
    @entries = Entry.all( :order => 'published DESC' )
    haml :index
  end
end

get '/entries/new' do
  login_required
  haml :new
end

post '/entries' do
  login_required
  params[:published] = Time.now unless params[:draft].eql? 'on'
  entry = Entry.new(params)
  entry.save!
  redirect "entries/#{entry.id}"
end

get '/entries/:id' do
  @entry = Entry.find(params[:id])
  haml :show
end

