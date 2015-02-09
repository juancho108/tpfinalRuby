require 'bundler'
require 'matrix'
require 'json'
require 'sinatra/flash'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }
Dir['./helpers/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Reloader
  use Rack::MethodOverride
  register Sinatra::Flash

  helpers AppHelpers

  configure :production, :development do
    enable :logging
    enable :sessions
  end

  set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

#rutas 
  #===========================================Authentication================================================

get '/' do
  redirect '/index'
end

get '/index' do
  if current_user
    redirect ("/players/#{current_user.id}/games")
  end
  erb :welcome
end


get '/login' do
  if current_user == nil
    erb :'auth/login'
  else 
    redirect("/players/#{current_user.id}/games")
  end
end

post '/login' do
  user = User.find_by(name: params[:user][:name]).try(:authenticate, params[:user][:password])
  if user
    session[:user_id] = user.id
    flash[:msg] = "Ok, 200"
    redirect("/players/#{user.id}/games")
  else
    set_error ("Username not found or password incorrect.")
    flash[:msg] = "Bad Request, 400"
    response.status = 400
    erb :'auth/login'
  end
end

get '/logout' do
  session[:user_id] = nil
  redirect('/index')
end


get '/signup' do
  erb :'auth/signup'
end


post '/players' do
  user = User.new(params[:user])
  if user.save
    session[:user_id] = user.id
    flash[:msg] = "Created, 201"
    redirect ("/players/#{current_user.id}/games")
  end
  if User.find_by(name: params[:user][:name])
    set_error ("Conflict, 409")
    response.status = 409
  elsif (params[:user] =~ /\A\p{Alnum}+\z/).nil?
    set_error ("Bad Request, 400")
    response.status = 400
  else
    session[:error] = user.errors.messages
  end
  erb :'auth/signup'
end
    
get '/players' do
  access
  @players = User.all
  response.status = 200
  erb :'players/list'
end

 




  #===========================================   Game  ================================================



get '/players/games' do
  access
  @players = User.where.not(id: current_user.id) unless User.first == nil
  erb :'game/new'
end

post '/players/games' do 
  access
  #crear jugadores
  player1 = current_user.id
  player2 = User.find_by(name: params[:player2])
  #crear tableros
  gameboard_player_1 = GameBoard.create(size: params[:size].to_i, player_id: player1, ships_positions: Matrix.build(params[:size].to_i) { 0 }.to_a.to_json )
  gameboard_player_2 = GameBoard.create(size: params[:size].to_i, player_id: player2.id, ships_positions: Matrix.build(params[:size].to_i) { 0 }.to_a.to_json )
  moves_player1 = Matrix.build(params[:size].to_i) { 0 }.to_a.to_json
  moves_player2 = Matrix.build(params[:size].to_i) { 0 }.to_a.to_json
  #creo el juego
  game = Game.new(player1_id: current_user.id, player2_id: player2.id,
                     game_board1_id: gameboard_player_1.id, game_board2_id: gameboard_player_2.id, moves_p1: moves_player1, moves_p2: moves_player2)
  if game.save
    gameboard_player_1.game_id= game.id
    gameboard_player_2.game_id= game.id
    gameboard_player_1.save
    gameboard_player_2.save
  
    flash[:msh] = "Created, 201"
    redirect ("/players/#{current_user.id}/games/#{game.id}")
  else
    set_error("Bad Request, 400")
    @players = User.where.not(id: current_user.id) unless User.first == nil
    response.status = 400
    erb :'game/new'
  end
end



get '/players/:id/games' do
  access
  @player_id = params[:id].to_i
  if current_user.id == @player_id
    @games_as_p1 = Game.where(player1_id: @player_id).reverse
    @games_as_p2 = Game.where(player2_id: @player_id).reverse
    flash[:msg] = "Ok, 200"
    response.status = 200
    erb :'game/list'
  else
    flash[:msg] = "Bad Request, 400"
    redirect("/players/#{current_user.id}/games")
  end
end

get '/players/:id/games/:id_game' do
  access
  # pregunto si soy el usuario que viene en la url y si ademas de ser el usuario de la URL, soy jugador del juego indicado
  if Manager.have_access_and_verify_my_games(params[:id], params[:id_game], current_user)
        #envio a ventana colocar barcos
        @player_id = params[:id].to_i
        @game_id = params[:id_game]
        #buscar tablero a llenar
        game = Game.find_by(id: @game_id)
        
        #pregunto si hay ganador
        if game.winner.nil?
          obj = Manager.give_gameboard_and_moves_for_show(game, @player_id)
          @gameboard = obj[0]
          @moves = obj[1]
          @ships_positions = JSON.parse(@gameboard.ships_positions)
          @cant_ships = Game.ships @gameboard.size
          flash[:msg] = "Ok, 200"
          response.status = 200
          erb :'game/gameboards'
        elsif game.winner == current_user
          flash[:msg] = "CONGRATULATIONS! YOU WIN THE GAME!!"
          redirect("/players/#{current_user.id}/games")
        else 
          flash[:msg] = "Oh... YOU LOST THE GAME, TRY AGAIN!"
          redirect("/players/#{current_user.id}/games")
        end
  else
    set_error ("You don't have permission to view the gameboard from other players!! ")
    redirect("/players/#{current_user.id}/games")
  end
end


post '/players/:id/games/:id_game/move' do
  @player_id = params[:id].to_i
  game = Game.find_by(id: params[:id_game])
  #verifico que sea el turno del jugador que realizo el post
  if params[:id].to_i == game.turn_player_id
    Manager.change_move_and_turn(params, game, current_user)
    flash[:msg] = "Created, 201"
    redirect ("/players/#{current_user.id}/games/#{game.id}")
  else
    set_error ("Forbbiden, 403. Is the other player turn. Wait plase! ")
    response.status = 403
    @games_as_p1 = Game.where(player1_id: @player_id).reverse
    @games_as_p2 = Game.where(player2_id: @player_id).reverse
    erb :'game/list'
  end
 
end



put '/players/:id/games/:id_game' do
  @player_id = params[:id].to_i
  game = Game.find_by(id: params[:id_game])
  if game.turn_player == nil
    Manager.update_gameboard(game, @player_id, params)
    #actualizo el Game si es necesario asignando un turno
    Game.turn_update(params[:id_game])
    flash[:msg] = "Ok, 200"
    response.status = 200

    @games_as_p1 = Game.where(player1_id: @player_id).reverse
    @games_as_p2 = Game.where(player2_id: @player_id).reverse
    erb :'game/list'
    
  else
    set_error ("Permission Denied, 500. You don't have permission to perform this action. The game is in progress... ")
    redirect ("/players/#{current_user.id}/games")
  end
end

end