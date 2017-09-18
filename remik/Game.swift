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
  
  init(players: [Player]) {
    self.players = players
    bagChipsCollection.shuffle()
    
    // TODO adjust matrix size somehow
    board = Board(rows: 100, columns: 100)
  }
  
  func endTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.count
  }
  
  func drawChip() {
    do {
      let chip = try bagChipsCollection.drawChip()
      players[currentPlayerIndex].draw(chip: chip)
      endTurn()
    } catch {
      print("no cheaps left");
    }
  }
}
