class CreateGameBoards < ActiveRecord::Migration
  def change
    create_table :game_boards do |t|
      t.integer :size
      t.boolean :ready, default: false
      t.string :ships_positions

      t.references :game
      t.references :player
    end    
  end
end
