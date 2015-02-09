class GameBoard < ActiveRecord::Base
  #accessors
  #attr_accessor :size, :ready, :ships_positions, :game_id

  #associations
  belongs_to :game, foreign_key: 'game_id', class_name: 'Game'
  belongs_to :player, foreign_key: 'player_id', class_name: 'User'

  validates  :player, :size, presence: true


  validates :size, numericality: { only_integer: true }, inclusion: {:in => [5, 10, 15]}

end
