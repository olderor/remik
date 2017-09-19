//
//  ChipView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

extension ChipColor {
  func getTextColor() -> UIColor {
    switch self {
    case .red:
      return UIColor.init(red: 251.0/255.0, green: 0.0, blue: 7.0/255.0, alpha: 1.0)
    case .green:
      return UIColor.init(red: 21.0/255.0, green: 158.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    case .blue:
      return UIColor.init(red: 0.0, green: 0.0, blue: 202.0/255.0, alpha: 1.0)
    case .black:
      return UIColor.black
    default:
      return UIColor.clear
    }
  }
  
  func getBorderColor() -> UIColor {
    switch self {
    case .red:
      return UIColor.init(red: 251.0/255.0, green: 0.0, blue: 7.0/255.0, alpha: 1.0)
    case .green:
      return UIColor.init(red: 21.0/255.0, green: 158.0/255.0, blue: 24.0/255.0, alpha: 1.0)
    case .blue:
      return UIColor.init(red: 0.0, green: 0.0, blue: 202.0/255.0, alpha: 1.0)
    case .black:
      return UIColor.black
    default:
      return UIColor.black
    }
  }
  
  func getJokerImagePath() -> String? {
    switch self {
    case .red:
      return "joker_red.png"
    case .green:
      return "joker_green.png"
    case .blue:
      return "joker_blue.png"
    case .black:
      return "joker_black.png"
    default:
      return nil
    }
  }
}

class ChipView: UIView {
  var label: UILabel!
  var imageView: UIImageView!
  var chip: Chip
  
  let imageViewOffset: CGFloat = 5
  
  static let chipDefaultOffsetX: CGFloat  = 10
  static let chipDefaultOffsetY: CGFloat  = 50
  static let chipDefaultViewWidth: CGFloat = 50
  static let chipDefaultViewHeight: CGFloat = 50
  
  static var cellSize: CGSize {
    get {
      return CGSize(
        width: chipDefaultOffsetX + chipDefaultViewWidth,
        height: chipDefaultOffsetY + chipDefaultViewHeight)
    }
  }
  
  static var cellRect: CGRect {
    get {
      return CGRect(
        x: ChipView.chipDefaultOffsetX,
        y: ChipView.chipDefaultOffsetY,
        width: ChipView.chipDefaultViewWidth,
        height: ChipView.chipDefaultViewHeight)
    }
  }
  
  init(chip: Chip, frame: CGRect) {
    self.chip = chip
    super.init(frame: frame)
    backgroundColor = UIColor.white
    layer.cornerRadius = 5.0
    layer.borderColor = chip.color.getBorderColor().cgColor
    layer.borderWidth = 2.0
    switch chip.type {
    case .coloredJoker:
      imageView = UIImageView(frame: CGRect(x: imageViewOffset, y: imageViewOffset, width: frame.width - 2 * imageViewOffset, height: frame.height - 2 * imageViewOffset))
      imageView.image = UIImage(named: chip.color.getJokerImagePath()!)
      self.addSubview(imageView)
      break
    case .number:
      label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
      label.text = chip.text
      label.textAlignment = .center
      label.textColor = chip.color.getTextColor()
      label.font = UIFont.boldSystemFont(ofSize: 20.0)
      self.addSubview(label)
      break
    default:
      break
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
