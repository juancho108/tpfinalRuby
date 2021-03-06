class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :moves_p1
      t.string :moves_p2

      t.references :winner
      t.references :player1
      t.references :player2
      t.references :turn_player
      t.references :game_board1
      t.references :game_board2

    end
  end
end
