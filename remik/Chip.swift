//
//  Chip.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

enum ChipType {
  case number,
  coloredJoker,
  anyJoker
}

enum ChipColor {
  case red,
  green,
  blue,
  any
  
  static func colored() -> [ChipColor] {
    return [red, green, blue]
  }

  static func all() -> [ChipColor] {
    return [red, green, blue, any]
  }
}

class Chip {
  let color: ChipColor
  let text: String
  let type: ChipType
  let number: Int?
  
  var handIndex: Int?
  var cell: Cell?
  
  init(color: ChipColor, number: Int?, text: String, type: ChipType) {
    self.color = color
    self.number = number
    self.text = text
    self.type = type
  }
}

class NumberChip: Chip {
  init(color: ChipColor, number: Int) {
    super.init(color: color, number: number, text: "\(number)", type: .number)
  }
}

class JokerChip: Chip {
  init(color: ChipColor) {
    if color == .any {
      super.init(color: color, number: nil, text: "", type: .anyJoker)
    } else {
      super.init(color: color, number: nil, text: "🃏", type: .coloredJoker)
    }
  }
}
