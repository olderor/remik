//
//  Player.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Player {
  var hand = [Chip]()
  var name: String
  
  init(name: String) {
    self.name = name
  }
  
  func draw(chip: Chip) {
    hand.append(chip)
  }
}
