//
//  HandView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

enum HandError: Error {
  case rowIsBusy
}

class HandView: ChipsContainerView {
  private var player: Player
  
  private var chipOffset: CGFloat  = 5
  
  static let defaultBackgroundColor = UIColor.darkGray
  
  weak var previousDrawnChipView: ChipView?
  
  init(player: Player, frame: CGRect) {
    self.player = player
    super.init(frame: frame, rows: 1, columns: player.hand.columns)
    
    backgroundColor = HandView.defaultBackgroundColor
    player.addDidDrawEventListener(handler: didDraw)
    hide()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func didDraw(chip: Chip, handIndex: Int) {
    previousDrawnChipView?.backgroundColor = UIColor.white
    let chipView = ChipView(chip: chip, cell: Cell(row: 0, column: handIndex))
    addSubview(chipView)
    while chipView.cell.column >= chipViewMatrix.columns {
      chipViewMatrix.addColumn(defaultValue: nil)
    }
    chipViewMatrix[chipView.cell.row, chipView.cell.column] = chipView
    chipView.backgroundColor = ChipView.getChipBackgroundColor(forState: .justDrawn)
    previousDrawnChipView = chipView
    updateContentSize()
  }
  
  func hide() {
    isHidden = true
  }
  
  func show() {
    isHidden = false
    sizeChangedEvent.raise(data: frame.size)
  }
  
  override func updateContentSize() {
    frame.size = CGSize(
      width: (ChipView.chipDefaultViewWidth + ChipView.chipDefaultOffsetX) * CGFloat(chipViewMatrix.columns),
      height: (ChipView.chipDefaultViewHeight + ChipView.chipDefaultOffsetY) * CGFloat(chipViewMatrix.rows))
    sizeChangedEvent.raise(data: frame.size)
  }
  
  override func addColumnToMatrix() {
    super.addColumnToMatrix()
  }
  
  func addRowToMatrix() {
    chipViewMatrix.addRow(defaultValue: nil)
    updateContentSize()
  }
  
  func removeLastRow() throws {
    for column in 0..<chipViewMatrix.columns {
      if chipViewMatrix[chipViewMatrix.rows - 1, column] != nil {
        throw HandError.rowIsBusy
      }
    }
    chipViewMatrix.removeLastRow()
    updateContentSize()
  }
}
