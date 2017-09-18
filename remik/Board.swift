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
  case invalidSequenceLength(length: Int),
  tooManyJokers(jokersCount: Int),
  incorrectJoker(position: Cell, possibleNumber: Int),
  incorrectOneColorNumber(position: Cell, differTo: Cell),
  incorrectDifference(firstNumber: Cell, secondNumber: Cell, difference: Int),
  incorrectNumber(position: Cell, possibleNumber: Int)
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
  
  init(rows: Int, columns: Int) {
    state = Matrix(rows: rows, columns: columns, repeatedValue: nil)
    updatedState = Matrix(rows: rows, columns: columns, repeatedValue: nil)
  }
  
  func moveChip(from: Cell, to: Cell) throws {
    guard updatedState[to.row][to.column] == nil else {
      throw BoardError.cellIsAlreadyBusy(cell: to)
    }
    
    swap(&updatedState[from.row][from.column], &updatedState[to.row][to.column])
  }
  
  func move(chip: Chip, to: Cell) throws {
    guard updatedState[to.row][to.column] == nil else {
      throw BoardError.cellIsAlreadyBusy(cell: to)
    }
    
    updatedState[to.row][to.column] = chip
  }
  
  // Minimum sequence length is 3 chips.
  // At least half of the chips must be numbered chips.
  // Jokers can only replace number in range 1...17.
  // The sequence must be either:
  // a sequence with equal numbers but different colors or
  // a sequence with increasing or decreasing by 1 numbers of the same color.
  private func verifyCellRange(range: CellRange) -> VerificationError? {
    if range.toColumn - range.fromColumn < 3 {
      return .invalidSequenceLength(length: range.toColumn - range.fromColumn)
    }
    
    var jokersCount = 0
    var colors = Set<ChipColor>()
    for column in range.fromColumn ..< range.toColumn {
      if updatedState[range.row][column]!.type == .anyJoker {
        jokersCount += 1
        continue
      }
      colors.insert(updatedState[range.row][column]!.color)
      if updatedState[range.row][column]!.type == .coloredJoker {
        jokersCount += 1
      }
    }
    
    if jokersCount * 2 >= range.toColumn - range.fromColumn {
      return .tooManyJokers(jokersCount: jokersCount)
    }
    
    if colors.count != 1 {
      var startColumn = range.fromColumn
      while updatedState[range.row][startColumn]!.number == nil {
          startColumn += 1
      }
      let correctNumber = updatedState[range.row][startColumn]!.number!
      for column in (startColumn + 1) ..< range.toColumn {
        if let number = updatedState[range.row][column]!.number {
          if number != correctNumber {
            return .incorrectOneColorNumber(
              position: Cell(row: range.row, column: column),
              differTo: Cell(row: range.row, column: startColumn))
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
    while updatedState[range.row][firstNumberedColumn]!.number == nil {
      firstNumberedColumn += 1
    }
    let firstNumber = updatedState[range.row][firstNumberedColumn]!.number!
    var secondNumberedColumn = firstNumberedColumn + 1
    while updatedState[range.row][secondNumberedColumn]!.number == nil {
      secondNumberedColumn += 1
    }
    let secondNumber = updatedState[range.row][secondNumberedColumn]!.number!
    
    let difference = (secondNumber - firstNumber) / (secondNumberedColumn - firstNumberedColumn)
    if (difference != 1 && difference != -1) {
      return .incorrectDifference(
        firstNumber: Cell(row: range.row, column: firstNumberedColumn),
        secondNumber: Cell(row: range.row, column: secondNumberedColumn),
        difference: difference)
    }
    
    // Check all jokers before first number.
    // Get jokers count, invert difference and get leftmost joker,
    // check if it fits the range 1...17.
    let beforeJokers = firstNumberedColumn - range.fromColumn
    let jokerNumber = firstNumber - difference * beforeJokers
    if jokerNumber < 1 || 17 < jokerNumber {
      return .incorrectJoker(position: Cell(row: range.row, column: range.fromColumn), possibleNumber: jokerNumber)
    }
    
    // Compare all other chips in the sequence using the difference.
    // We can predict jokers value.
    var currentNumber = secondNumber
    for column in (secondNumberedColumn + 1) ..< range.toColumn {
      currentNumber += difference
      if let number = updatedState[range.row][column]!.number {
        if number != currentNumber {
          return .incorrectNumber(position: Cell(row: range.row, column: column),
                                  possibleNumber: currentNumber)
        }
      } else {
        if currentNumber < 1 || 17 < currentNumber {
          return .incorrectJoker(position: Cell(row: range.row, column: column),
                                 possibleNumber: currentNumber)
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
      updatedState[row][startColumn] == nil {
        startColumn += 1
    }
    if startColumn == updatedState[row].count {
      return nil
    }
    var endColumn = startColumn + 1
    while endColumn < updatedState[row].count &&
      updatedState[row][endColumn] != nil {
        endColumn += 1
    }
    return CellRange(row: row, fromColumn: startColumn, toColumn: endColumn)
  }
  
  func verifyBoardState() -> VerificationResult {
    let result = VerificationResult()
    for rowIndex in 0 ..< updatedState.rows {
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
