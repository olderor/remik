//
//  HandView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class HandView: ChipsContainerView {
  private var player: Player
  
  private var chipOffset: CGFloat  = 5
  
  static let defaultBackgroundColor = UIColor.darkGray
  
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
    let chipView = ChipView(chip: chip, cell: Cell(row: 0, column: handIndex))
    addSubview(chipView)
    while chipView.cell.column >= chipViewMatrix.columns {
      chipViewMatrix.addColumn(defaultValue: nil)
    }
    chipViewMatrix[chipView.cell.row, chipView.cell.column] = chipView
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
}
