//
//  HandView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class HandView: UIScrollView {
  var player: Player
  
  let chipDefaultOffset: CGFloat  = 10
  var chipOffset: CGFloat  = 5
  let chipDefaultViewSize: CGFloat = 50
  
  var chipViews = [ChipView]()
  
  init(player: Player, frame: CGRect) {
    self.player = player
    super.init(frame: frame)
    self.backgroundColor = UIColor.black
    player.addDidDrawEventListener(handler: didDraw)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func didDraw(chip: Chip) {
    let chipView = ChipView(chip: chip, frame:
      CGRect(x: chipOffset,
             y: (frame.size.height - chipDefaultViewSize) / 2.0,
             width: chipDefaultViewSize,
             height: chipDefaultViewSize))
    chipOffset += chipDefaultOffset + chipDefaultViewSize
    self.contentSize = CGSize(width: (chipDefaultViewSize + chipDefaultOffset) * CGFloat(player.handLastIndex), height: self.frame.size.height)
    self.addSubview(chipView)
  }
  
  func hide() {
    self.isHidden = true
  }
  
  func show() {
    self.isHidden = true
  }
}
