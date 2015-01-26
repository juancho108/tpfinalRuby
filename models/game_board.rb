class GameBoard < ActiveRecord::Base
  #accessors
  #attr_accessor :size, :ready, :ships_positions, :game_id

  #associations
  belongs_to :game, foreign_key: :game_id, class_name: 'Game'

end
