//
//  Matrix.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Cell {
  var row: Int
  var column: Int
  
  init(row: Int, column: Int) {
    self.row = row
    self.column = column
  }
  
  static func !=(first: Cell, second: Cell) -> Bool {
    return first.row != second.row || first.column != second.column
  }
}

// Row is fixed, column is the range.
// From including, to excluding.
class CellRange {
  var row: Int
  var fromColumn: Int
  var toColumn: Int
  
  init(row: Int, fromColumn: Int, toColumn: Int) {
    self.row = row
    self.fromColumn = fromColumn
    self.toColumn = toColumn
  }
}

class Matrix<Element> {
  private(set) var rows: Int
  private(set) var columns: Int
  private var contents: [[Element]]
  
  init(rows: Int, columns: Int, repeatedValue: Element) {
    self.rows = rows
    self.columns = columns
    self.contents = [[Element]]()
    for _ in 0..<rows {
      self.contents.append([Element](repeating: repeatedValue, count: columns))
    }
  }
  
  init(contents: [[Element]]) {
    self.rows = contents.count
    if (rows == 0) {
      self.columns = 0
    } else {
      self.columns = contents[0].count
    }
    
    self.contents = [[Element]]()
    for rowIndex in 0..<contents.count {
      assert(self.columns == contents[rowIndex].count)
      self.contents.append([Element]())
      for columnIndex in 0..<contents[rowIndex].count {
        self.contents[rowIndex].append(contents[rowIndex][columnIndex])
      }
    }
  }
  
  init(contents: Matrix<Element>) {
    self.rows = contents.rows
    self.columns = contents.columns
    
    self.contents = [[Element]]()
    for rowIndex in 0..<contents.rows {
      self.contents.append([Element]())
      for columnIndex in 0..<contents.columns {
        self.contents[rowIndex].append(contents[rowIndex][columnIndex])
      }
    }
  }
  
  subscript(row: Int, column: Int) -> Element {
    get {
      assert(indexIsValidFor(row: row, column: column))
      return contents[row][column]
    }
    
    set {
      assert(indexIsValidFor(row: row, column: column))
      contents[row][column] = newValue
    }
  }
  
  subscript(row: Int) -> [Element] {
    get {
      assert(row < rows)
      return contents[row]
    }
    
    set {
      assert(row < rows)
      assert(newValue.count == columns)
      contents[row] = newValue
    }
  }
  
  func resizeIfNeeded(defaultValue: Element, rows: Int, columns: Int) {
    if rows - self.rows > 0 {
      addRows(defaultValue: defaultValue, count: rows - self.rows)
    }
    if columns - self.columns > 0 {
      addColumns(defaultValue: defaultValue, count: columns - self.columns)
    }
  }
  
  func addRow(defaultValue: Element) {
    addRows(defaultValue: defaultValue, count: 1)
  }
  
  func addRows(defaultValue: Element, count: Int) {
    for _ in 0..<count {
      contents.append([Element](repeating: defaultValue, count: columns))
    }
    rows += count
  }
  
  func addColumns(defaultValue: Element, count: Int) {
    for row in 0..<contents.count {
      for _ in 0..<count {
        contents[row].append(defaultValue)
      }
    }
    columns += count
  }
  
  func addColumn(defaultValue: Element) {
    addColumns(defaultValue: defaultValue, count: 1)
  }
  
  fileprivate func indexIsValidFor(row: Int, column: Int) -> Bool {
    return 0 <= row && row < rows && 0 <= column && column < columns
  }
}
