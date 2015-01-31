require 'bundler'
require 'matrix'
require 'json'


ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }
Dir['./helpers/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Reloader
  use Rack::MethodOverride

  configure :production, :development do
    enable :logging
    enable :sessions
  end

  set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

#rutas 
  ##Authentication
get '/prueba' do
  erb :tabs
end


get '/' do
  if current_user
    redirect ('/login')
  end
  @mensaje = "welcome to my Site"
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
    redirect("/players/#{user.id}/games")
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
  gameboard_player_1 = GameBoard.create(size: params[:size].to_i, player_id: player1, ships_positions: Matrix.build(params[:size].to_i) { 0 }.to_a.to_json )
  gameboard_player_2 = GameBoard.create(size: params[:size].to_i, player_id: player2.id, ships_positions: Matrix.build(params[:size].to_i) { 0 }.to_a.to_json )
  moves_player1 = Matrix.build(params[:size].to_i) { 0 }.to_a.to_json
  moves_player2 = Matrix.build(params[:size].to_i) { 0 }.to_a.to_json
  #creo el juego
  game = Game.create(player1_id: current_user.id, player2_id: player2.id,
                     game_board1_id: gameboard_player_1.id, game_board2_id: gameboard_player_2.id, moves_p1: moves_player1, moves_p2: moves_player2)
  gameboard_player_1.game_id= game.id
  gameboard_player_2.game_id= game.id

  gameboard_player_1.save
  gameboard_player_2.save
  #verificar si no necesito nada mas
  redirect ("/players/#{current_user.id}/games/#{game.id}")
end

get '/players/:id/games' do
  @player_id = params[:id].to_i

  @games_as_p1 = Game.where(player1_id: @player_id).reverse
  @games_as_p2 = Game.where(player2_id: @player_id).reverse
  erb :'game/list'

end

get '/players/:id/games/:id_game' do
  # pregunto si soy el usuario que viene en la url y si ademas de ser el usuario de la URL, soy jugador del juego indicado
  if ((current_user.id == params[:id].to_i) &&
     ((current_user.games_as_player1.exists?(id: params[:id_game])) || (current_user.games_as_player2.exists?(id: params[:id_game]))))

        #envio a ventana colocar barcos
        @player_id = params[:id].to_i
        @game_id = params[:id_game]
        #buscar tablero a llenar
        game = Game.find_by(id: @game_id)
        #pregunto si hay ganador
        if game.winner.nil?
          if @player_id == game.player1_id
          @gameboard = GameBoard.find_by(id: game.game_board1_id)
          @moves = JSON.parse(game.moves_p1)
          elsif @player_id == game.player2_id
            @gameboard = GameBoard.find_by(id: game.game_board2_id)
            @moves = JSON.parse(game.moves_p2)
          end

          @ships_positions = JSON.parse(@gameboard.ships_positions)
          erb :'game/gameboards'
        elsif game.winner == current_user
          @message = "CONGRATULATIONS! YOU WIN THE GAME!!"
          redirect("/players/#{current_user.id}/games")
        else 
          @message = "Oh... YOU LOST THE GAME, TRY AGAIN!"
          redirect("/players/#{current_user.id}/games")
        end
        
  else
    set_error ("You don't have permission to view the gameboard from other players!! ")
    redirect("/players/#{current_user.id}/games")
  end
end

post '/players/:id/games/:id_game/move' do
  game = Game.find_by(id: params[:id_game])
  #verifico que sea el turno del jugador que realizo el post
  if params[:id].to_i == game.turn_player_id
    move = params[:move].split(",").map { |s| s.to_i }
    #me fijo que jugador realizo el move (player1 o player2).Traigo tablero rival, y actualizo mis movimientos y turno
    if params[:id].to_i == game.player1_id
      gameboard_rival = JSON.parse(game.game_board2.ships_positions)
      moves = JSON.parse(game.moves_p1)
      gameboard_rival[move[0]][move[1]] == 1 ?  moves[move[0]][move[1]] = 2 : moves[move[0]][move[1]] = 1
      game.moves_p1 = moves.to_json
      game.turn_player_id = game.player2_id
    else
      gameboard_rival = JSON.parse(game.game_board1.ships_positions)
      moves = JSON.parse(game.moves_p2)
      gameboard_rival[move[0]][move[1]] == 1 ?  moves[move[0]][move[1]] = 2 : moves[move[0]][move[1]] = 1
      game.moves_p2 = moves.to_json
      game.turn_player_id = game.player1_id
    end
    #verifico si hay ganador
    if ((game.moves_p1.count('2') == (ships game.game_board1.size)) || (game.moves_p2.count('2') == (ships game.game_board1.size) ))
      game.winner = current_user
    end
    game.save
    redirect("/players/#{current_user.id}/games/#{game.id}")     
  else
    set_error ("Is the other player turn. Wait plase! ")
    redirect("/players/#{current_user.id}/games") 
  end
 
end



put '/players/:id/games/:id_game' do
  
  player_id = params[:id].to_i
  game = Game.find_by(id: params[:id_game])
  if game.turn_player == nil
      #busco tablero a actualizar
    if player_id == game.player1_id
      gameboard = GameBoard.find_by(id: game.game_board1_id)
    else 
      gameboard = GameBoard.find_by(id: game.game_board2_id)
    end
    
    sp = Matrix.build(gameboard.size) { 0 }.to_a
    
    #Tomo las posiciones de los barcos para guardarlas
    (1..ships(gameboard.size)).each do |i|
      a = params[(:barco.to_s+i.to_s).to_sym].split(",").map { |s| s.to_i }
      sp[a[1]][a[2]] = 1
    end
    
    #Guardo las posiciones de los barcos
    gameboard.update ships_positions: sp.to_json, ready: true
    #actualizo el Game si es necesario asignando un turno
      g = Game.find_by(id: params[:id_game])
      if g.ready?
        g.update turn_player_id: ([g.player1_id, g.player2_id].sample)
      end
  else
    set_error ("You don't have permission to perform this action. The game is in progress... ")
  end
  redirect("/players/#{current_user.id}/games")
end


  ##GameBoard

get '/gameboard/create' do 
  erb :'gameboard/new'
end

get '/gameboard/show' do
  erb :'gameboard/juego'
end



end