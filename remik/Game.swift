//
//  Game.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Game {
  private(set) var players: [Player]
  private var bagChipsCollection = ChipsCollection()
  private(set) var currentPlayerIndex = 0
  private(set) var board: Board
  
  let initialHandSize = 14
  
  var chipsPlacedOnBoardCount = 0
  
  init(players: [Player]) {
    self.players = players
    bagChipsCollection.shuffle()
    
    board = Board()
    
    for player in players {
      for _ in 0..<initialHandSize {
        do {
          try drawChip(player: player)
        } catch { }
      }
    }
  }
  
  private func drawChip(player: Player) throws {
    let chip = try bagChipsCollection.drawChip()
    player.draw(chip: chip)
  }
  
  private func drawChip() {
    do {
      try drawChip(player: players[currentPlayerIndex])
    } catch {
      print("no cheaps left");
    }
  }
  
  func endTurn(handState: Matrix<Chip?>, boardState: Matrix<Chip?>) -> VerificationResult {
    if chipsPlacedOnBoardCount == 0 {
      drawChip()
    } else {
      let result = board.verifyBoardState(state: boardState)
      if !result.success {
        return result
      }
      board.applyUpdatedBoardState(newState: boardState)
      players[currentPlayerIndex].upd(handState)
    }
    currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    chipsPlacedOnBoardCount = 0
    return VerificationResult()
  }
}
