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
}
