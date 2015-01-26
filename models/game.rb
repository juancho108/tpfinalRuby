class Game < ActiveRecord::Base
  # accessors
  #attr_accessor :turn, :winner, :movesPlayer1, :movesPlayer2, :player1, :player2, :game_board1, :game_board2

  # associations
  belongs_to :player1, foreign_key: :player1_id, class_name: 'User'
  belongs_to :player2, foreign_key: :player2_id, class_name: 'User'
  belongs_to :winner, class_name: 'User'

  # validations
  #validates :player1_id, :player2_id, :game_board1_id, :game_board2_id, presence: true

  # g = Game.create player1_id: u1.id, player2_id: u2.id
end
