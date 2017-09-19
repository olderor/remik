//
//  ChipContainerView.swift
//  remik
//
//  Created by olderor on 19.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class ChipsContainerView: UIScrollView {
  public var chipViewMatrix: Matrix<ChipView?>
  public var dragAndDropProcessor: DragAndDropProcessor!
  
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
  
  func updateContentSize() {
    contentSize = CGSize(
      width: (ChipView.chipDefaultViewWidth + ChipView.chipDefaultOffsetX) * CGFloat(chipViewMatrix.columns),
      height: (ChipView.chipDefaultViewHeight + ChipView.chipDefaultOffsetY) * CGFloat(chipViewMatrix.rows))
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
