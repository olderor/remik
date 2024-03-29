//
//  ChipContainerView.swift
//  remik
//
//  Created by olderor on 19.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class ChipsContainerView: UIView {
  var chipViewMatrix: Matrix<ChipView?>
  var dragAndDropProcessor: DragAndDropProcessor!
  let sizeChangedEvent = Event<(CGSize)>()
  
  override init(frame: CGRect) {
    chipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    super.init(frame: frame)
    dragAndDropProcessor = DragAndDropProcessor(view: self)
    updateContentSize()
  }
  
  init(frame: CGRect, rows: Int, columns: Int) {
    chipViewMatrix = Matrix<ChipView?>(rows: rows, columns: columns, repeatedValue: nil)
    super.init(frame: frame)
    dragAndDropProcessor = DragAndDropProcessor(view: self)
    updateContentSize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addSizeChangedEventListener(handler: @escaping (CGSize) -> ()) {
    sizeChangedEvent.addHandler(handler: handler)
  }
  
  func updateContentSize() {
    frame.size = CGSize(
      width: (ChipView.chipDefaultViewWidth + ChipView.chipDefaultOffsetX) * CGFloat(chipViewMatrix.columns),
      height: (ChipView.chipDefaultViewHeight + ChipView.chipDefaultOffsetY) * CGFloat(chipViewMatrix.rows))
    sizeChangedEvent.raise(data: frame.size)
  }
  
  func didMoveChipToView(chipView: ChipView, toLocation: CGPoint) {
    addSubview(chipView)
    chipView.center = toLocation
    chipView.currentLocation = toLocation
    
    let cell = LocationManager.getCellBy(location: toLocation, cellSize: ChipView.cellSize)
    chipViewMatrix.resizeIfNeeded(defaultValue: nil, rows: cell.row + 1, columns: cell.column + 1)
    dragAndDropProcessor.move(chipView: chipView, to: cell)
    updateContentSize()
  }
  
  func addColumnToMatrix() {
    chipViewMatrix.addColumn(defaultValue: nil)
    updateContentSize()
  }
  
  func addMoveOutOfViewEventListener(handler:
    @escaping ((chipView: ChipView, gestureRecognizer: UIGestureRecognizer)) -> ()) {
    
    dragAndDropProcessor.addMoveOutOfViewEventListener(handler: handler)
  }
}
