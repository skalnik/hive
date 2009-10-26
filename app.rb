require 'rubygems'
require 'sinatra'
require 'mongomapper'
require 'haml'
require 'yaml'

configure do
  config = YAML::load_file('config.yml')
  MongoMapper.connection = XGen::Mongo::Driver::Connection.new(config['database']['host'])
  MongoMapper.database = config['database']['name']
end

get '/' do
  @entries = Entries.all( :order => 'created_at DESC' )
  haml :index
end

