//
//  ChipsCollection.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

extension Array {
  mutating func shuffle() {
    for i in 0 ..< (count - 1) {
      let j = Int(arc4random_uniform(UInt32(count - i))) + i
      swap(&self[i], &self[j])
    }
  }
}

class ChipsCollection {
  
  var collection: [Chip]
  
  init() {
    collection = ChipsCollection.createNewCollection()
  }
  
  func shuffle() {
    collection.shuffle()
  }
  
  // Creates new chips collection, that contains:
  // 2x chips from 1 to 17 each color (r,g,b,y)
  // 1x joker each color (r,g,b,y)
  // 4x uncolored jokers
  static func createNewCollection() -> [Chip] {
    var collection = [Chip]()
    for _ in 0..<2 {
      for index in 1...17 {
        for color in ChipColor.colored() {
          let chip = Chip(color: color, text: "\(index)")
          collection.append(chip)
        }
      }
    }
    for color in ChipColor.colored() {
      let chip = JokerChip(color: color)
      collection.append(chip)
    }
    for _ in 0..<4 {
      let chip = JokerChip(color: .any)
      collection.append(chip)
    }
    return collection
  }
}
