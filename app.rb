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
  MongoMapper.database.authenticate(config['database']['username'], config['database']['password'])
end


['/', '/entries'].each do |path|
  get path do
    @entries = Entry.all( :order => 'created_at DESC' )
    haml :index
  end
end

get '/entries/:id' do
  @entry = Entry.first(params[:id])
  haml :show
end

get '/entries/new' do
  haml :new
end

post '/entries' do
  @entry = Entry.new(params)
  redirect_to "entries/#{params[:id]}"
end
