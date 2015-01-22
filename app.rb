require 'bundler'


ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }
Dir['./helpers/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :production, :development do
    enable :logging
  end

  set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]


#rutas 
  ##Authentication

get '/' do
  erb :welcome
end

get '/login' do
  erb :'auth/login'
end

post '/login' do
  user = User.find_by(name: params[:user][:name]).try(:authenticate, params[:user][:password])
  if user
    session[:user_id] = user.id
    redirect('/')
  else
    set_error ("Username not found or password incorrect.")
    redirect('/login')
  end
end

get '/logout' do
  session[:user_id] = nil
  redirect('/')
end


get '/signup' do
  erb :'auth/signup'
end


get '/players' do
  @players = User.all
  response.status = 200
  erb :'players/list'
end

post '/players' do
  user = User.new(params[:user])
  if user.save
    session[:user_id] = user.id
    redirect('/') 
  else
    session[:error] = user.errors.messages
    redirect("/signup")
  end
end


  ##Game

get '/games/new' do
  #if User.first() ? @players = User.all()
   
  @players = User.where.not(id: current_user.id) unless User.first == nil
  erb :'game/create'  
end

post '/games/new' do 
  #crear nuevo juego
  gameboard = Gameboard.new()
end


  ##GameBoard

get '/gameboard/create' do 
  erb :'gameboard/create'
end

get '/gameboard/show' do
  erb :'gameboard/juego'
end



end