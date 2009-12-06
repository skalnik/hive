require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'haml'
require 'yaml'
require 'time'
require 'sinatra/authorization'
require 'models/entry'
Dir['lib/*'].each { |lib| require lib }

configure do
  config = YAML::load_file('config.yml')
  MongoMapper.connection = Mongo::Connection.new(config[:database][:host])
  MongoMapper.database = config[:database][:name]
  if config[:database][:username]
    MongoMapper.database.authenticate(config[:database][:username], config[:database][:password])
  end

  @@username, @@password = config[:site][:username], config[:site][:password]
  @@time_zone = config[:site][:time_zone]
  @@twitter_username = config[:twitter][:username] if config[:twitter]
  @@github_username = config[:github][:username] if config[:github]
  @@last_fm_username = config[:last_fm][:username] if config[:last_fm]
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

  def time_zone
    @@time_zone
  end

  def format_time(time)
    # Take GMT and add time_zone in seconds, then format & return it
    (time.getgm + (time_zone * 3600)).strftime("%a %b %d %I:%M %p")
  end
end

error do
	Exceptional.handle_sinatra(request.env['sinatra.error'], request.env['REQUEST_URI'], request, params)
end

['/', '/entries'].each do |path|
  get path do
    @entries = Entry.paginate(:per_page => 50, :page => 1, :order => 'published DESC')
    haml :index
  end
end

get '/:page' do
  @entries = Entry.paginate(:per_page => 50, :page => params[:page], :order => 'published DESC')
  haml :index
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

