require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'haml'
require 'yaml'
require 'models/entry'

configure do
  config = YAML::load_file('config.yml')
  MongoMapper.connection = Mongo::Connection.new(config['database']['host'])
  MongoMapper.database = config['database']['name']
  if config['database']['username']
    MongoMapper.database.authenticate(config['database']['username'], config['database']['password'])
  end
end


['/', '/entries'].each do |path|
  get path do
    @entries = Entry.all( :order => 'created_at DESC' )
    haml :index
  end
end

get '/entries/new' do
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
