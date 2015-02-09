class Game < ActiveRecord::Base
  # accessors
  #attr_accessor :turn, :winner, :moves_p1, :moves_p2, :player1, :player2, :game_board1, :game_board2

  # associations
  belongs_to :player1, :class_name => 'User', :foreign_key => 'player1_id'
  belongs_to :player2, :class_name => 'User', :foreign_key => 'player2_id'
  belongs_to :winner, :class_name => 'User'
  belongs_to :turn_player, :class_name => 'User'
  belongs_to :game_board1, :class_name => 'GameBoard', :foreign_key => 'game_board1_id'
  belongs_to :game_board2, :class_name => 'GameBoard', :foreign_key => 'game_board2_id'

  # validations
  validates :player1_id, :player2_id, :game_board1_id, :game_board2_id, :moves_p1, :moves_p2, presence: true, allow_blank: false

  def self.turn_update game_id
    g = Game.find_by(id: game_id)
    if g.ready?
      g.update turn_player_id: ([g.player1_id, g.player2_id].sample)
    end
  end
  
  def ready? 
    ((self.game_board1.ready == self.game_board2.ready) == true)
  end

  def self.ships size
    if size == 5
      return 7
    elsif size == 10
      return 15
    elsif size == 15
      return 20
    else
      return false
    end
  end
  
end
