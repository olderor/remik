//
//  Game.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Game {
  private var players: [Player]
  private var bagChipsCollection = ChipsCollection()
  private var currentPlayerIndex = 0
  private var board: Board
  
  let initialHandSize = 14
  
  init(players: [Player]) {
    self.players = players
    bagChipsCollection.shuffle()
    
    // TODO adjust matrix size somehow
    board = Board(rows: 100, columns: 100)
    
    for player in players {
      for _ in 0 ..< initialHandSize {
        do {
          try drawChip(player: player)
        } catch { }
      }
    }
  }
  
  func endTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.count
  }
  
  private func drawChip(player: Player) throws {
    let chip = try bagChipsCollection.drawChip()
    player.draw(chip: chip)
  }

  func drawChip() {
    do {
      try drawChip(player: players[currentPlayerIndex])
      endTurn()
    } catch {
      print("no cheaps left");
    }
  }
}
