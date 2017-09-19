//
//  BoardView.swift
//  remik
//
//  Created by olderor on 19.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class BoardView: ChipsContainerView {
  override init(frame: CGRect) {
    super.init(frame: frame, rows: 0, columns: 0)
    minimumZoomScale = 1.0
    maximumZoomScale = 2.0
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateContentSize() {
    contentSize = CGSize(
      width: (ChipView.chipDefaultViewWidth + ChipView.chipDefaultOffsetX) *
        CGFloat(chipViewMatrix.columns * 2),
      height: (ChipView.chipDefaultViewHeight + ChipView.chipDefaultOffsetY) *
        CGFloat(chipViewMatrix.rows * 2))
  }

  func didMoveChipToBoard(chipView: ChipView, toLocation: CGPoint) {
    chipView.removeFromSuperview()
    addSubview(chipView)
    chipView.center = toLocation
    
    let cell = LocationManager.getCellBy(location: toLocation, cellSize: ChipView.cellSize)
    chipViewMatrix.resizeIfNeeded(defaultValue: nil, rows: cell.row + 1, columns: cell.column + 1)
    dragAndDropProcessor.move(chipView: chipView, to: cell)
    updateContentSize()
  }
}
