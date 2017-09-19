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
}
