require 'test_helper'

class TestGameBoard < MiniTest::Test

  def setup
    @user = User.new name: 'juan', password: '12345678'
    @gb1 = GameBoard.new size: 5, player: @user
    @gb2 = GameBoard.new size: 5
    @gb3 = GameBoard.new size: 6, player: @user
    @gb4 = GameBoard.new size: 'h'
  end

  def teardown
    User.delete_all
    GameBoard.delete_all
  end

  def test_perfect_new_instance
    assert_equal @gb1.valid?, true
    assert_equal GameBoard, @gb1.class
    assert @gb1.save
    assert_equal 5, @gb1.size
    assert_equal @user, @gb1.player
  end

  def test_should_not_save_gameboard_without_set_player
    assert_equal false, @gb2.save
    assert_equal ["can't be blank"], @gb2.errors.messages[:player]
    assert_equal @gb2.valid?, false
  end

  def test_should_not_save_gameboard_if_size_value_is_not_in_the_allowed_list
    assert_equal false, @gb3.save
    assert_equal ["is not included in the list"], @gb3.errors.messages[:size]
    assert_equal @gb3.valid?, false
  end

  def test_should_not_save_gameboard_if_size_value_is_not_a_number
    assert_equal false, @gb4.save
    assert_equal ["is not a number", "is not included in the list"], @gb4.errors.messages[:size]
    assert_equal @gb4.valid?, false
  end
end