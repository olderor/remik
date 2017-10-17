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
      let j = Int(arc4random_uniform(UInt32(count - i - 1)) + 1) + i
      self.swapAt(i, j)
    }
  }
}

enum ChipsCollectionError: Error {
  case noChipsLeft
}

class ChipsCollection {
  private var collection: [Chip]
  private var currentChipIndex = -1
  
  static let minNumber = 1
  static let maxNumber = 17
  static let numberCount = 2
  static let coloredJokersCount = 2
  static let uncoloredJokersCount = 8
  
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
    for _ in 0..<numberCount {
      for number in minNumber...maxNumber {
        for color in ChipColor.colored() {
          let chip = NumberChip(color: color, number: number)
          collection.append(chip)
        }
      }
    }
    for _ in 0..<coloredJokersCount {
      for color in ChipColor.colored() {
        let chip = JokerChip(color: color)
        collection.append(chip)
      }
    }
    for _ in 0..<uncoloredJokersCount {
      let chip = JokerChip(color: .any)
      collection.append(chip)
    }
    return collection
  }
  
  func drawChip() throws -> Chip {
    if (currentChipIndex + 1 >= collection.count) {
      throw ChipsCollectionError.noChipsLeft
    }
    currentChipIndex += 1
    return collection[currentChipIndex]
  }
}
