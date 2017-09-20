//
//  Board.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

enum BoardError: Error {
  case cellIsAlreadyBusy(cell: Cell)
}

enum VerificationError: Error {
  case incorrectSequenceLength(range: CellRange),
  tooManyJokers(range: CellRange, jokersCount: Int),
  incorrectJoker(range: CellRange, possibleNumber: Int),
  incorrectOneColorNumber(range: CellRange),
  incorrectDifference(range: CellRange, difference: Int),
  incorrectNumber(range: CellRange, possibleNumber: Int),
  incorrectColorInSequence(range: CellRange)
}

extension VerificationError: LocalizedError {
  public var errorDescription: String {
    switch self {
    case .incorrectSequenceLength(let length):
      return "Incorrect sequence length: \(length). Sequence must contain at least \(Board.minimumSequenceLength) chips."
    case .tooManyJokers(let jokersCount):
      return "Too many jokers in the sequence (\(jokersCount)). More than a half of the chips must be numbered chips."
    case .incorrectJoker(_, let possibleNumber):
      return "Incorrect joker found. Predicted \(possibleNumber) number. Mind that all chips can be only \(ChipsCollection.minNumber)-\(ChipsCollection.maxNumber) including."
    case .incorrectOneColorNumber(_):
      return "Incorrect sequence. If sequence contains of few colors, its numbers must have the same value. If sequence is the sequence of consecutive numbers, then they all must be the same color."
    case .incorrectDifference(_, let difference):
      return "Incorrect sequence. The sequence must be the sequence of consecutive numbers (found \(difference) between adjacent numbers, it has to be either 1 or -1)."
    case .incorrectNumber(_, let possibleNumber):
      return "Incorrect sequence. The sequence must be the sequence of consecutive numbers (hint: there must be \(possibleNumber) chip)."
    case .incorrectColorInSequence(_):
      return "Incorrect color in the sequence found. There can only be one chip for each of the colors."
    }
  }
  
  public var cellRange: CellRange {
    switch self {
    case .incorrectSequenceLength(let range):
      return range
    case .tooManyJokers(let range, _):
      return range
    case .incorrectJoker(let range, _):
      return range
    case .incorrectOneColorNumber(let range):
      return range
    case .incorrectDifference(let range, _):
      return range
    case .incorrectNumber(let range, _):
      return range
    case .incorrectColorInSequence(let range):
      return range
    }
  }
}

class VerificationResult {
  var errors = [VerificationError]()
  var success: Bool {
    get {
      return errors.count == 0
    }
  }
}

class Board {
  var state: Matrix<Chip?>
  var updatedState: Matrix<Chip?>
  
  static let minimumSequenceLength = 3
  
  convenience init() {
    self.init(rows: 0, columns: 0)
  }
  
  init(rows: Int, columns: Int) {
    state = Matrix(rows: rows, columns: columns, repeatedValue: nil)
    updatedState = Matrix(rows: rows, columns: columns, repeatedValue: nil)
  }
  
  func moveChip(from: Cell, to: Cell) throws {
    guard updatedState[to.row, to.column] == nil else {
      throw BoardError.cellIsAlreadyBusy(cell: to)
    }
    
    swap(&updatedState[from.row, from.column], &updatedState[to.row, to.column])
  }
  
  func move(chip: Chip, to: Cell) throws {
    guard updatedState[to.row, to.column] == nil else {
      throw BoardError.cellIsAlreadyBusy(cell: to)
    }
    
    updatedState[to.row, to.column] = chip
  }
  
  // Minimum sequence length is 3 chips.
  // More than a half of the chips must be numbered chips.
  // Jokers can only replace number in range 1...17.
  // The sequence must be either:
  // a sequence with equal numbers but different colors or
  // a sequence with increasing or decreasing by 1 numbers of the same color.
  private func verifyCellRange(range: CellRange) -> VerificationError? {
    if range.toColumn - range.fromColumn < Board.minimumSequenceLength {
      return .incorrectSequenceLength(range: range)
    }
    
    var jokersCount = 0
    var anyJokers = 0
    var colors = Set<ChipColor>()
    for column in range.fromColumn..<range.toColumn {
      if updatedState[range.row, column]!.type == .anyJoker {
        jokersCount += 1
        anyJokers += 1
        continue
      }
      colors.insert(updatedState[range.row, column]!.color)
      if updatedState[range.row, column]!.type == .coloredJoker {
        jokersCount += 1
      }
    }
    
    if jokersCount * 2 >= range.toColumn - range.fromColumn {
      return .tooManyJokers(range: range, jokersCount: jokersCount)
    }
    
    if colors.count != 1 {
      if colors.count + anyJokers != range.toColumn - range.fromColumn ||
        range.toColumn - range.fromColumn > ChipColor.colored().count {
        return .incorrectColorInSequence(range: range)
      }
      var startColumn = range.fromColumn
      while updatedState[range.row, startColumn]!.number == nil {
        startColumn += 1
      }
      let correctNumber = updatedState[range.row, startColumn]!.number!
      for column in (startColumn + 1)..<range.toColumn {
        if let number = updatedState[range.row, column]!.number {
          if number != correctNumber {
            return .incorrectOneColorNumber(range: range)
          }
        }
      }
      return nil
    }
    
    // check this:
    // _ 1 2
    // 2 1 _
    // 16 17 _
    // _ 17 16
    // 1 _ 3
    // 3 _ 1
    
    // Find first chip with number and second chip with number,
    // check difference between them.
    var firstNumberedColumn = range.fromColumn
    while updatedState[range.row, firstNumberedColumn]!.number == nil {
      firstNumberedColumn += 1
    }
    let firstNumber = updatedState[range.row, firstNumberedColumn]!.number!
    var secondNumberedColumn = firstNumberedColumn + 1
    while updatedState[range.row, secondNumberedColumn]!.number == nil {
      secondNumberedColumn += 1
    }
    let secondNumber = updatedState[range.row, secondNumberedColumn]!.number!
    
    let difference = (secondNumber - firstNumber) / (secondNumberedColumn - firstNumberedColumn)
    if (difference != 1 && difference != -1) {
      return .incorrectDifference(range: range, difference: difference)
    }
    
    // Check all jokers before first number.
    // Get jokers count, invert difference and get leftmost joker,
    // check if it fits the range 1...17.
    let beforeJokers = firstNumberedColumn - range.fromColumn
    let jokerNumber = firstNumber - difference * beforeJokers
    if jokerNumber < ChipsCollection.minNumber ||
      ChipsCollection.maxNumber < jokerNumber {
      
      return .incorrectJoker(range: range, possibleNumber: jokerNumber)
    }
    
    // Compare all other chips in the sequence using the difference.
    // We can predict jokers value.
    var currentNumber = secondNumber
    for column in (secondNumberedColumn + 1)..<range.toColumn {
      currentNumber += difference
      if let number = updatedState[range.row, column]!.number {
        if number != currentNumber {
          return .incorrectNumber(range: range, possibleNumber: currentNumber)
        }
      } else {
        if currentNumber < ChipsCollection.minNumber ||
          ChipsCollection.maxNumber < currentNumber {
          
          return .incorrectJoker(range: range, possibleNumber: currentNumber)
        }
      }
    }
    return nil
  }
  
  // Finds range with busy cells.
  // Returns nil is range was not found.
  private func findBusyCellRange(row: Int, columnOffset: Int) -> CellRange? {
    var startColumn = columnOffset
    while startColumn < updatedState[row].count &&
      updatedState[row, startColumn] == nil {
        startColumn += 1
    }
    if startColumn == updatedState[row].count {
      return nil
    }
    var endColumn = startColumn + 1
    while endColumn < updatedState[row].count &&
      updatedState[row, endColumn] != nil {
        endColumn += 1
    }
    return CellRange(row: row, fromColumn: startColumn, toColumn: endColumn)
  }
  
  func verifyBoardState() -> VerificationResult {
    let result = VerificationResult()
    for rowIndex in 0..<updatedState.rows {
      var offset = 0
      while let range = findBusyCellRange(row: rowIndex, columnOffset: offset) {
        if let error = verifyCellRange(range: range) {
          result.errors.append(error)
        }
        offset = range.toColumn
      }
    }
    return result
  }
  
  func applyUpdatedBoardState() {
    state = Matrix(contents: updatedState)
  }
}
