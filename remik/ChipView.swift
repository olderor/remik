//
//  ChipView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

extension ChipColor {
  func getUIColor() -> UIColor {
    switch self {
    case .red:
      return UIColor.red
    case .green:
      return UIColor.green
    case .blue:
      return UIColor.blue
    case .yellow:
      return UIColor.init(red: 255.0 / 255.0, green: 204.0 / 255.0, blue: 0, alpha: 1.0)
    default:
      return UIColor.clear
    }
  }
}

class ChipView: UIView {
  var label: UILabel!
  var chip: Chip
  
  init(chip: Chip, frame: CGRect) {
    self.chip = chip
    super.init(frame: frame)
    label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    backgroundColor = UIColor.white
    label.text = chip.text
    label.textAlignment = .center
    label.textColor = chip.color.getUIColor()
    // todo: do something with a font.
    self.addSubview(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
