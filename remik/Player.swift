//
//  Player.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Player {
  var hand: Matrix<Chip?>
  var updatedState: Matrix<Chip?>!
  let name: String
  
  private(set) var chipsInHandCount = 0
  
  private let didDrawEvent = Event<(chip: Chip, handIndex: Int)>()
  
  init(name: String) {
    self.name = name
    self.hand = Matrix<Chip?>(rows: 1, columns: 0, repeatedValue: nil)
  }
  
  func addDidDrawEventListener(handler: @escaping ((chip: Chip, handIndex: Int)) -> ()) {
    didDrawEvent.addHandler(handler: handler)
  }
  
  func findFreeSpaceInHand() -> Int {
    var index = 0
    while index < hand.columns && hand[0, index] != nil {
      index += 1
    }
    if index == hand.columns {
      hand.addColumn(defaultValue: nil)
    }
    return index
  }
  
  func draw(chip: Chip) {
    let index = findFreeSpaceInHand()
    hand[0, index] = chip
    chipsInHandCount += 1
    didDrawEvent.raise(data: (chip: chip, handIndex: index))
  }
  
  func applyUpdatedHandState() {
    hand = Matrix<Chip?>(contents: updatedState)
    chipsInHandCount = 0
    for row in 0..<hand.rows {
      for column in 0..<hand.columns {
        if hand[row, column] != nil {
          chipsInHandCount += 1
        }
      }
    }
  }
}
