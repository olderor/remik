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
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateContentSize() {
    let width = (ChipView.chipDefaultViewWidth + ChipView.chipDefaultOffsetX) *
      CGFloat(chipViewMatrix.columns)
    let height = (ChipView.chipDefaultViewHeight + ChipView.chipDefaultOffsetY) *
      CGFloat(chipViewMatrix.rows)
    
    let size = max(width, height) * 2
    frame.size = CGSize(width: size, height: size)
    sizeChangedEvent.raise(data: frame.size)
  }
}
