
class Manager

  def self.have_access_and_verify_my_games player_id, game_id, current_user
    player_id = player_id.to_i
    if ((current_user.id == player_id) && ((current_user.games_as_player1.exists?(id: game_id)) || (current_user.games_as_player2.exists?(id: game_id))))
      return true
    end
  end

  def self.give_gameboard_and_moves_for_show game, player_id
      a = []
      if player_id == game.player1_id
        a << GameBoard.find_by(id: game.game_board1_id)
        a << JSON.parse(game.moves_p1)
      elsif player_id == game.player2_id
        a << GameBoard.find_by(id: game.game_board2_id)
        a << JSON.parse(game.moves_p2)
      end
      return a
  end

  def self.update_gameboard game, player_id, params
    #busco tablero a actualizar
    if player_id == game.player1_id
      gameboard = GameBoard.find_by(id: game.game_board1_id)
    else 
      gameboard = GameBoard.find_by(id: game.game_board2_id)
    end
    
    sp = Matrix.build(gameboard.size) { 0 }.to_a

    #Tomo las posiciones de los barcos para guardarlas
    (1..Game.ships(gameboard.size)).each do |i|
      a = params[(:barco.to_s+i.to_s).to_sym].split(",").map { |s| s.to_i }
      sp[a[1]][a[2]] = 1
    end
    
    #Guardo las posiciones de los barcos
    gameboard.update ships_positions: sp.to_json, ready: true
  end

  def self.change_move_and_turn params, game, current_user
    move = params[:move].split(",").map { |s| s.to_i }
    if params[:id].to_i == game.player1_id
      gameboard_rival = JSON.parse(game.game_board2.ships_positions)
      moves = JSON.parse(game.moves_p1)
      gameboard_rival[move[0]][move[1]] == 1 ?  moves[move[0]][move[1]] = 2 : moves[move[0]][move[1]] = 1
      game.moves_p1 = moves.to_json
      game.turn_player_id = game.player2_id
    else
      gameboard_rival = JSON.parse(game.game_board1.ships_positions)
      moves = JSON.parse(game.moves_p2)
      gameboard_rival[move[0]][move[1]] == 1 ?  moves[move[0]][move[1]] = 2 : moves[move[0]][move[1]] = 1
      game.moves_p2 = moves.to_json
      game.turn_player_id = game.player1_id
    end    
    #verifico si hay ganador
    if ((game.moves_p1.count('2') == (Game.ships game.game_board1.size)) || (game.moves_p2.count('2') == (Game.ships game.game_board1.size) ))
      game.winner = current_user
    end
    game.save
  end
end