class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :winner
      t.references :player1
      t.references :player2
      t.integer :turn
      t.references :game_board1
      t.references :game_board2
    end
  end
end
