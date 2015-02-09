require 'test_helper'
require 'matrix'

class TestGame < MiniTest::Test

  def setup
    #users
    @user1 = User.create name: 'juan', password: '12345678'
    @user2 = User.create name: 'maria', password: '12345678'
    #gameboards
    @gb1 = GameBoard.create size: 5, player: @user1
    @gb2 = GameBoard.create size: 5, player: @user2
    @gb3 = GameBoard.create size: 5, player: @user1, ready: true
    @gb4 = GameBoard.create size: 5, player: @user2, ready: true
    #moves
    @moves1 = Matrix.build(5){0}.to_a.to_json
    @moves2 = Matrix.build(5){0}.to_a.to_json
    #games
    @game = Game.new player1: @user1, player2: @user2, game_board1: @gb1, game_board2: @gb2, moves_p1: @moves1, moves_p2: @moves2
    @game2 = Game.new player2: @user1, game_board1: @gb1, game_board2: @gb2, moves_p1: @moves1, moves_p2: @moves2
    @game3 = Game.new player1: @user2, player2: @user1, game_board1: @gb1, game_board2: @gb2, moves_p2: @moves2
    @game4 = Game.new player1: @user2, player2: @user1, game_board2: @gb2, moves_p1: @moves1, moves_p2: @moves2
    @game5 = Game.new player1: @user1, player2: @user2, game_board1: @gb3, game_board2: @gb4, moves_p1: @moves1, moves_p2: @moves2
  end

  def teardown
    User.delete_all
    GameBoard.delete_all
    Game.delete_all
  end

  def test_perfect_new_instance
    assert_equal @game.valid?, true
    assert_equal Game, @game.class
    assert @game.save
    assert_equal User, @game.player1.class
    assert_equal User, @game.player2.class
    assert_equal GameBoard, @game.game_board1.class
    assert_equal GameBoard, @game.game_board2.class
    assert_equal String, @game.moves_p1.class
    assert_equal String, @game.moves_p2.class
  end

  def test_should_not_save_game_without_some_player
    assert_equal false, @game2.save
    assert_equal ["can't be blank"], @game2.errors.messages[:player1_id]
    assert_equal @game2.valid?, false
  end

  def test_should_not_save_game_without_some_move
    assert_equal false, @game3.save
    assert_equal ["can't be blank"], @game3.errors.messages[:moves_p1]
    assert_equal @game3.valid?, false
  end

  def test_should_not_save_game_without_some_gameboard
    assert_equal false, @game4.save
    assert_equal ["can't be blank"], @game4.errors.messages[:game_board1_id]
    assert_equal @game4.valid?, false
  end

  def test_ships_method
    assert_equal Game.ships(5), 7
    assert_equal Game.ships(10), 15
    assert_equal Game.ships(15), 20
    assert_equal Game.ships(2), false
    assert_equal Game.ships('a'), false
  end

  def test_method_ready?
    assert_equal @game5.ready?, true
  end

  def test_turn_update_method
    assert_equal @game5.turn_player, nil
    @game5.save
    Game.turn_update(@game5.id)
    assert_includes [@user1.id, @user2.id], Game.last.turn_player_id
  end
end