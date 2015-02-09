require 'test_helper'

class RootTest < AppTest

  def setup
    @user = User.create! name:'admin', password:'12345678'
    @user2 = User.create! name:'juan', password:'12345678'
    @gb1 = GameBoard.create(size: 5, player_id: @user.id, ships_positions: Matrix.build(5) { 0 }.to_a.to_json )
    @gb2 = GameBoard.create(size: 5, player_id: @user2.id, ships_positions: Matrix.build(5) { 0 }.to_a.to_json )
    @mv1 = Matrix.build(5) { 0 }.to_a.to_json
    @mv2 = Matrix.build(5) { 0 }.to_a.to_json
    @game1 = Game.create! player1_id: @user.id, player2_id: @user2.id, game_board1_id: @gb1.id, game_board2_id: @gb2.id, moves_p1: @mv1, moves_p2: @mv2
    @game2 = Game.create! player1_id: @user.id, player2_id: @user2.id, game_board1_id: @gb1.id, game_board2_id: @gb2.id, moves_p1: @mv1, moves_p2: @mv2, turn_player: @user
    game = Game.first
    gb1 = GameBoard.first
    gb2 = GameBoard.last
    gb1.game_id = game.id
    gb2.game_id = game.id
    gb1.save
    gb2.save
  end 

  def teardown
    User.delete_all
    Game.delete_all
    GameBoard.delete_all
  end

  

  # TEST POST /login
  
  def test_correct_login_user
    post '/login', {:user => {name: 'admin', password: '12345678' }}
    assert_equal 302, last_response.status
  end

  def test_failed_login_user
    post '/login', {:user => {name: 'admasdin', password: '12345678' }}
    assert_equal 400, last_response.status
    assert last_response.body.include? ("Username not found or password incorrect.")
  end

  

  #TEST GET /players
  
  def test_list_user
    get '/players', {}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 200, last_response.status
  end

  

  #TEST POST /players
  
  def test_correct_signup
    post '/players', {:user => {name: 'gonzalo', password: '12345678', password_confirmation: '12345678' }}
    assert_equal 302, last_response.status
  end

  def test_failed_signup_existing_user
    post '/players', {:user => {name: 'admin', password: '12345678', password_confirmation: '12345678' }}
    assert_equal 409, last_response.status
    assert last_response.body.include? ("Conflict, 409")
  end

  def test_failed_signup_invalid_username
    post '/players', {:user => {name: 'admin!!', password: '12345678', password_confirmation: '12345678' }}
    assert_equal 400, last_response.status
    assert last_response.body.include? ("Bad Request, 400")
  end

  

  #TEST POST /players/games
  
  def test_correct_create_game
    post '/players/games', {size: '5', player2: 'juan' }, {'rack.session'=> {user_id: @user.id}}
    assert_equal 302, last_response.status
  end

  def test_incorrect_create_game
    post '/players/games', {size: '7', player2: 'juan' }, {'rack.session'=> {user_id: @user.id}}
    assert_equal 400, last_response.status
    assert last_response.body.include? ("Bad Request, 400")
  end
  
  

  #TEST GET /players/:id/games
  
  def test_get_correct_games
    get "/players/#{@user.id}/games", {}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 200, last_response.status
    assert last_response.body.include? ("Games as Player 1")
    assert last_response.body.include? ("Games as Player 2")
  end

  def test_get_incorrect_games
    get "/players/3/games", {}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 302, last_response.status
  end



  #TEST GET /players/:id/games/:id_game
  
  def test_get_correct_game
    get "/players/#{@user.id}/games/#{@game1.id}", {}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 200, last_response.status
    assert last_response.body.include? ("Puts your ships in position")
  end

  def test_get_incorrect_game
    get "/players/3/games/1", {}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 302, last_response.status
  end

  

  #TEST PUT /players/:id/games/:id_game
  
  def test_correct_update_gameboard
    put "/players/#{@user.id}/games/#{@game1.id}", {_method: "PUT", barco1: "00,1,4", barco2: "00,1,3", barco3: "00,0,4", barco4: "00,0,3", barco5: "00,0,2", barco6: "00,0,1", barco7: "00,0,0"}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 200, last_response.status
  end

  def test_incorrect_update_gameboard
    put "/players/#{@user.id}/games/#{@game2.id}", {_method: "PUT", barco1: "00,1,4", barco2: "00,1,3", barco3: "00,0,4", barco4: "00,0,3", barco5: "00,0,2", barco6: "00,0,1", barco7: "00,0,0"}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 302, last_response.status
  end


  #TEST POST /players/:id/games/:id_game/move
  
  def test_move_in_correct_turn
    post "/players/#{@user.id}/games/#{@game2.id}/move", {move: "1,1"}, {'rack.session'=> {user_id: @user.id}}
    assert_equal 302, last_response.status
  end

  def test_move_incorrect_turn
    post "/players/#{@user.id}/games/#{@game1.id}/move", {move: "1,1"}, {'rack.session'=> {user_id: @user2.id}}
    assert_equal 403, last_response.status
    assert last_response.body.include? ("Forbbiden, 403. Is the other player turn. Wait plase! ")
  end

end
