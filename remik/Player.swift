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
  var handLastIndex = 0
  
  private let didDrawEvent = Event<Chip>()
  
  init(name: String) {
    self.name = name
    self.hand = [Chip?](repeating: nil, count: 0)
  }
  
  func addDidDrawEventListener(handler: @escaping (Chip) -> ()) {
    didDrawEvent.addHandler(handler: handler)
  }
  
  func draw(chip: Chip) {
    chip.cell = Cell(row: 0, column: handLastIndex)
    if (handLastIndex == hand.count) {
      hand.append(nil)
    }
    hand[handLastIndex] = chip
    handLastIndex += 1
    didDrawEvent.raise(data: chip)
  }
  
  func move(from: Int, to: Int) {
    move(chip: hand[from]!, to: to)
    hand[from] = nil
  }
  
  func move(chip: Chip, to position: Int) {
    handLastIndex = max(handLastIndex, position + 1)
    hand[position] = chip
  }
}

