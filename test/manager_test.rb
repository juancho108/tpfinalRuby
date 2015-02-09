require 'test_helper'
require 'matrix'

class TestManager < MiniTest::Test

  def setup
    #users
    @user1 = User.create name: 'juan', password: '12345678'
    @user2 = User.create name: 'maria', password: '12345678'
    @user3 = User.create name: 'carlos', password: '12345678'
    
    #gameboards
    @gb1 = GameBoard.create size: 5, player: @user1, ships_positions: Matrix.build(5){0}.to_a.to_json
    @gb2 = GameBoard.create size: 5, player: @user2, ships_positions: Matrix.build(5){0}.to_a.to_json
    @gb3 = GameBoard.create size: 5, player: @user1, ships_positions: Matrix.build(5){0}.to_a.to_json, ready: true
    @gb4 = GameBoard.create size: 5, player: @user2, ships_positions: Matrix.build(5){0}.to_a.to_json, ready: true
    
    #moves
    @moves1 = Matrix.build(5){0}.to_a.to_json
    @moves2 = Matrix.build(5){0}.to_a.to_json
    @moves3 = [[2,2,2,2,2],[2,2,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]].to_json
    @moves4 = [[1,1,1,1,1],[1,1,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]].to_json
    
    #games
    @game = Game.create player1: @user1, player2: @user2, game_board1: @gb1, game_board2: @gb2, moves_p1: @moves1, moves_p2: @moves2
    @game2 = Game.create player1: @user3, player2: @user2, game_board1: @gb3, game_board2: @gb4, moves_p1: @moves1, moves_p2: @moves2, turn_player: @user3
    @game3 =  Game.create player1: @user3, player2: @user2, game_board1: @gb3, game_board2: @gb4, moves_p1: @moves3, moves_p2: @moves4, turn_player: @user3
  end

  def teardown
    User.delete_all
    GameBoard.delete_all
    Game.delete_all
  end

  def test_have_access_and_verify_my_games_method
    #should be return true if the player agrees, is player game that is sent as parameter
    assert_equal true, Manager.have_access_and_verify_my_games(@user1.id, @game.id, @user1)
    #should be return false if the player agrees, not is player game that is sent as parameter
    assert_equal nil, Manager.have_access_and_verify_my_games(@user1.id, @game.id, @user3)
  end


  def test_give_gameboard_and_moves_for_show_method
    #should be return an array with gameboard and moves for play
    a = Manager.give_gameboard_and_moves_for_show(@game, @user1.id)
    assert_equal Array, a.class
    assert_equal GameBoard, a[0].class #gameboard
    assert_equal Array, a[1].class #moves
  end

  def test_update_gameboard_method
    #first all ships positions have 0 
    assert_equal 0, @game.game_board1.ships_positions.count('1')
    params = {barco1: "00,1,1", barco2: "00,1,0", barco3: "00,0,0", barco4: "00,0,4", barco5: "00,0,3", barco6: "00,0,2", barco7:"00,0,1"}
    Manager.update_gameboard(@game, @user1.id, params)
    game = Game.first
    assert_equal 7, game.game_board1.ships_positions.count('1')
  end

  def test_change_move_and_turn_method
    params = {move: "1,1", id: @user3.id}
    assert_equal @user3, Game.all[1].turn_player
    Manager.change_move_and_turn(params, @game2, @user3)
    assert_equal @user2, Game.all[1].turn_player
  end

  def test_change_move_and_turn_method_winner
    params = {move: "2,1", id: @user3.id}
    assert_equal nil, Game.all[2].winner
    Manager.change_move_and_turn(params, @game3, @user3)
    assert_equal @user3, Game.all[2].winner
  end

end