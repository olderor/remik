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
    super.init(frame: frame, rows: 1, columns: player.hand.count)
    
    backgroundColor = HandView.defaultBackgroundColor
    player.addDidDrawEventListener(handler: didDraw)
    hide()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func didDraw(chip: Chip) {
    let chipView = ChipView(chip: chip, frame:
      CGRect(x: chipOffset,
             y: (frame.size.height - ChipView.chipDefaultViewHeight) / 2.0,
             width: ChipView.chipDefaultViewWidth,
             height: ChipView.chipDefaultViewHeight))
    chipOffset += ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewHeight
    updateContentSize()
    addSubview(chipView)
    while chip.cell.column >= chipViewMatrix.columns {
      chipViewMatrix.addColumn(defaultValue: nil)
    }
    chipViewMatrix[chip.cell.row, chip.cell.column] = chipView
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
