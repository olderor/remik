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
  
  private let didDrawEvent = Event<(chip: Chip, handIndex: Int)>()
  
  init(name: String) {
    self.name = name
    self.hand = [Chip?](repeating: nil, count: 0)
  }
  
  func addDidDrawEventListener(handler: @escaping ((chip: Chip, handIndex: Int)) -> ()) {
    didDrawEvent.addHandler(handler: handler)
  }
  
  func findFreeSpaceInHand() -> Int {
    var index = 0
    while index < hand.count && hand[index] != nil {
      index += 1
    }
    if index == hand.count {
      hand.append(nil)
    }
    return index
  }
  
  func draw(chip: Chip) {
    let index = findFreeSpaceInHand()
    hand[index] = chip
    didDrawEvent.raise(data: (chip: chip, handIndex: index))
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

