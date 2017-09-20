//
//  Player.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Player {
  var hand: [Chip?]
  let name: String
  
  private let didDrawEvent = Event<Chip>()
  
  init(name: String) {
    self.name = name
    self.hand = [Chip?](repeating: nil, count: 0)
  }
  
  func addDidDrawEventListener(handler: @escaping (Chip) -> ()) {
    didDrawEvent.addHandler(handler: handler)
  }
  
  func findFreeCellInHand() -> Cell {
    let cell = Cell(row: 0, column: 0)
    while cell.column < hand.count && hand[cell.column] != nil {
      cell.column += 1
    }
    if cell.column == hand.count {
      hand.append(nil)
    }
    return cell
  }
  
  func draw(chip: Chip) {
    chip.cell = findFreeCellInHand()
    hand[chip.cell.column] = chip
    didDrawEvent.raise(data: chip)
  }
  
  func move(from: Int, to: Int) {
    move(chip: hand[from]!, to: to)
    hand[from] = nil
  }
  
  func move(chip: Chip, to position: Int) {
    hand[position] = chip
  }
  
  func updateHand(newHand: Matrix<ChipView?>) {
    while newHand.columns > hand.count {
      hand.append(nil)
    }
    for i in 0..<hand.count {
      hand[i] = newHand[0, i]?.chip
    }
  }
}

