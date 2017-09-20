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
  
  var shouldDrawChip: Bool {
    get {
      return chipsPlacedOnBoardCount == 0
    }
  }
  
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
  
  func drawChip() {
    players[currentPlayerIndex].applyUpdatedHandState()
    do {
      try drawChip(player: players[currentPlayerIndex])
    } catch {
      print("no cheaps left");
    }
    forceEndTurn()
  }
  
  func tryEndTurn() -> VerificationResult {
    let result = board.verifyBoardState()
    if !result.success {
      return result
    }
    players[currentPlayerIndex].applyUpdatedHandState()
    board.applyUpdatedBoardState()
    forceEndTurn()
    return VerificationResult()
  }
  
  func forceEndTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    chipsPlacedOnBoardCount = 0
  }
}
