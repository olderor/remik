//
//  Chip.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

enum ChipColor {
  case red,
  green,
  blue,
  any
}

class Chip {
  let color: ChipColor
  let text: String
  
  init(color: ChipColor, text: String) {
    self.color = color
    self.text = text
  }
}
