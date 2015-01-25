require 'bundler'


ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }
Dir['./helpers/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :production, :development do
    enable :logging
    enable :sessions
  end

  set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

#rutas 
  ##Authentication

get '/' do
  @mensaje = "welcome to my Site"
  erb :welcome
end

get '/login' do
  if current_user == nil
    erb :'auth/login'
  else 
    @message = "Hola #{current_user.name}"
    erb :welcome
  end
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

get '/players/games' do
  #if User.first() ? @players = User.all()
  @players = User.where.not(id: current_user.id) unless User.first == nil
  erb :'game/new'
end

post '/players/games/' do 
  #crear jugadores
  player1 = current_user.id
  player2 = User.find_by(name: params[:player2])
  #crear tableros
  gameboard_player_1 = GameBoard.create(size: params[:size].to_i, ready: false)
  gameboard_player_2 = GameBoard.create(size: params[:size].to_i, ready: false)

  #creo el juego
  game = Game.create(player1_id: current_user.id, player2_id: player2.id,
                     game_board1_id: gameboard_player_1.id, game_board2_id: gameboard_player_2.id,
                     turn: current_user.id)
  gameboard_player_1.game_id= game.id
  gameboard_player_2.game_id= game.id

  gameboard_player_1.save
  gameboard_player_2.save
  #verificar si no necesito nada mas
  redirect ("/players/#{current_user.id}/games/#{game.id}")
end

get '/players/:id/games/:id_game' do
  #envio a ventana colocar barcos
  @player_id = params[:id]
  @game_id = params[:id_game]
  #buscar tablero a llenar
  game = Game.find_by(id: @game_id)
  if @player_id == game.player1_id
    @gameboard = Gameboard.find_by(id: game.gameboard_player_1)
  elsif @player_id == game.player2_id
    @gameboard = Gameboard.find_by(id: game.gameboard_player_2)
  else
    @mensaje = "error"
  end
  erb :'game/update'
end

put '/players/:id/games/:id_game' do
  #envio a ventana colocar barcos
  player = User.find(params[:id])
  game = Game.find(params[:id_game])
  @mensaje = "#{@player.name} #{@game.id}"
  erb :welcome
end



  ##GameBoard

get '/gameboard/create' do 
  erb :'gameboard/new'
end

get '/gameboard/show' do
  erb :'gameboard/juego'
end



end