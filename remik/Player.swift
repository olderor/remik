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
    // TODO Think about hand size.
    self.hand = [Chip?](repeating: nil, count: 90)
  }
  
  func addDidDrawEventListener(handler: @escaping (Chip) -> ()) {
    didDrawEvent.addHandler(handler: handler)
  }
  
  func draw(chip: Chip) {
    chip.handIndex = handLastIndex
    hand[handLastIndex] = chip
    handLastIndex += 1
    didDrawEvent.raise(data: chip)
  }
  
  func move(chip: Chip, from: Int, to: Int) {
    hand[from] = nil
    move(chip: chip, to: to)
  }
  
  func move(chip: Chip, to position: Int) {
    handLastIndex = max(handLastIndex, position + 1)
    hand[position] = chip
  }
}

