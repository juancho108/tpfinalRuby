class GameBoard < ActiveRecord::Base
  attr_accessor :ships_positions, :size, :ready, :game_id
end
