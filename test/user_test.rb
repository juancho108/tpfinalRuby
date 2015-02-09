require 'test_helper'

class TestUser < MiniTest::Test

  def setup
    @user = User.new name: 'juan', password: '12345678'
    @user2 = User.new name: 'pedro!', password: '12345678'
    @user3 = User.new name: 'maria', password: 'hola'
    @user4 = User.new name: 'juan', password: '12234567'
    @user5 = User.new password: '12345678'
  end

  def teardown
    User.delete_all
  end

  def test_perfect_new_instance
    assert_equal User, @user.class
    assert @user.save
    assert_equal 'juan', @user.name
  end

  def test_should_not_save_user_with_symbols_name
    assert_equal false, @user2.save
    assert_equal ["only allows letters and numbers"], @user2.errors.messages[:name]
  end

  def test_should_not_save_user_with_short_password
    assert_equal false, @user3.save
    assert_equal ["is too short (minimum is 6 characters)"], @user3.errors.messages[:password]
  end

  def test_should_not_save_user_with_same_name
    @user.save
    assert_equal false, @user4.save
    assert_equal ["has already been taken"], @user4.errors.messages[:name]
  end

  def test_should_not_save_user_with_blank_name
    assert_equal false, @user5.save
    assert_equal ["can't be blank", "only allows letters and numbers", "is too short (minimum is 2 characters)"], @user5.errors.messages[:name]
  end

end