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
    super.init(frame: frame, rows: 1000, columns: 1000)
    // todo size
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
