class Game < ActiveRecord::Base
  # accessors
  #attr_accessor :turn, :winner, :movesPlayer1, :movesPlayer2, :player1, :player2, :game_board1, :game_board2

  # associations
  belongs_to :player1, :class_name => 'User', :foreign_key => 'player1_id'
  belongs_to :player2, :class_name => 'User', :foreign_key => 'player2_id'
  belongs_to :winner, :class_name => 'User'
  belongs_to :turn_player, :class_name => 'User'
  belongs_to :game_board1, :class_name => 'GameBoard', :foreign_key => 'game_board1_id'
  belongs_to :game_board2, :class_name => 'GameBoard', :foreign_key => 'game_board2_id'

  # validations
  validates :player1_id, :player2_id, :game_board1_id, :game_board2_id, presence: true


  def ready? 
    ((self.game_board1.ready == self.game_board2.ready) == true)
  end
  # g = Game.create player1_id: u1.id, player2_id: u2.id
end
