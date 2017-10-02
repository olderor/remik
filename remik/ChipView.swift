//
//  ChipView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

enum ChipViewState {
  case normal,
  wrongPlaced,
  justDrawn,
  placedToBoardByOtherPlayerInPreviousTurn
}

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
  
  func getBorderGradientColors() -> [UIColor] {
    if self == .any {
      return [UIColor].rainbow2
    }
    return [getBorderColor()]
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

extension ChipView {
  static func getChipBackgroundColor(forState state: ChipViewState) -> UIColor {
    switch state {
    case .normal:
      return UIColor.white
    case .justDrawn:
      return UIColor.init(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
    case .wrongPlaced:
      return UIColor.yellow
    case .placedToBoardByOtherPlayerInPreviousTurn:
      return UIColor.init(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
    }
  }
  
  func updateChipBackgroundColor(forState state: ChipViewState) {
    if chip.isInHistory && state == .normal {
      backgroundColor = ChipView.getChipBackgroundColor(forState: .placedToBoardByOtherPlayerInPreviousTurn)
    } else {
      backgroundColor = ChipView.getChipBackgroundColor(forState: state)
    }
  }
}

extension UIColor {
  static var indigo: UIColor {
    return UIColor.init(
      red: 75.0 / 255.0,
      green: 0.0,
      blue: 130.0 / 255.0,
      alpha: 1.0)
  }
  
  static var violet: UIColor {
    return UIColor.init(
      red: 127.0 / 255.0,
      green: 0.0,
      blue: 255.0 / 255.0,
      alpha: 1.0)
  }
  
  convenience init(hexValue: Int) {
    self.init(
      red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat((hexValue & 0x0000FF) >> 0) / 255.0,
      alpha: 1.0)
  }
}

extension Array where Element: UIColor  {
  static var rainbow: [Element] {
    return [UIColor.red,
            UIColor.orange,
            UIColor.yellow,
            UIColor.green,
            UIColor.blue,
            UIColor.indigo,
            UIColor.violet] as! [Element]
  }
  static var rainbow2: [Element] {
    return [UIColor.init(hexValue: 0x61bb46),
            UIColor.init(hexValue: 0xfdb827),
            UIColor.init(hexValue: 0xf5821f),
            UIColor.init(hexValue: 0xe03a3e),
            UIColor.init(hexValue: 0x963d97),
            UIColor.init(hexValue: 0x009ddc)] as! [Element]
  }
}

infix operator *: MultiplicationPrecedence
extension Array {
  static func * (left: Array, right: Int) -> Array {
    var result = [Element]()
    for _ in 0..<right {
      for index in 0..<left.count {
        result.append(left[index])
      }
    }
    return result
  }
  
  func getShiftedCopy(shiftingValue: Int) -> Array {
    var result = [Element]()
    for index in shiftingValue..<self.count {
      result.append(self[index])
    }
    for index in 0..<shiftingValue {
      result.append(self[index])
    }
    return result
  }
}

extension CAGradientLayer {
  static func getGradientBorder(colors: [CGColor],
                                bounds: CGRect,
                                width: CGFloat = 10,
                                cornerRadius: CGFloat = 5) -> CAGradientLayer {
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: bounds.size)
    gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
    gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
    gradientLayer.colors = colors
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.lineWidth = width
    shapeLayer.path = UIBezierPath(rect: bounds).cgPath
    shapeLayer.fillColor = nil
    shapeLayer.strokeColor = UIColor.black.cgColor
    gradientLayer.mask = shapeLayer
    
    gradientLayer.cornerRadius = cornerRadius
    return gradientLayer
  }
}

class ChipView: UIView, CAAnimationDelegate {
  var label: UILabel!
  var imageView: UIImageView!
  
  var gradientLayer: CAGradientLayer!
  var gradientColorsOffset = 0
  var gradientColors: [CGColor]!
  
  var chip: Chip
  
  let imageViewOffset: CGFloat = 5
  
  var currentLocation: CGPoint!
  var initialLocation: CGPoint!
  
  var cell: Cell!
  var initialCell: Cell!
  
  static let chipDefaultOffsetX: CGFloat  = 10
  static let chipDefaultOffsetY: CGFloat  = 20
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
  
  convenience init(chip: Chip, cell: Cell) {
    self.init(chip: chip, frame: CGRect(
      x: ChipView.chipDefaultOffsetX / 2.0 +
        CGFloat(cell.column) * (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth),
      y: ChipView.chipDefaultOffsetY / 2.0 +
        CGFloat(cell.row) * (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight),
      width: ChipView.chipDefaultViewWidth,
      height: ChipView.chipDefaultViewHeight))
    self.cell = Cell(row: cell.row, column: cell.column)
    self.initialCell = Cell(row: cell.row, column: cell.column)
  }
  
  init(chip: Chip, frame: CGRect) {
    self.chip = chip
    super.init(frame: frame)
    currentLocation = self.center
    updateChipBackgroundColor(forState: .normal)
    
    gradientColors = chip.color.getBorderGradientColors().map({ $0.cgColor })
    
    self.layer.cornerRadius = 5
    gradientLayer = CAGradientLayer.getGradientBorder(
      colors: getCurrentGradientColors(),
      bounds: self.layer.bounds,
      cornerRadius: self.layer.cornerRadius)
    self.layer.addSublayer(gradientLayer)
    gradientLayer.drawsAsynchronously = true
    
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
    case .anyJoker:
      addBorderAnimation()
      break
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func getCurrentGradientColors() -> [CGColor] {
    let colors = gradientColors.getShiftedCopy(shiftingValue: gradientColorsOffset)
    return colors * 3
  }
  
  func addBorderAnimation() {
    let animation = CABasicAnimation(keyPath: "colors")
    animation.fillMode = kCAFillModeForwards
    // animation.fromValue = getCurrentGradientColors()
    gradientColorsOffset = (gradientColorsOffset + 1) % gradientColors.count
    animation.toValue = getCurrentGradientColors()
    animation.duration = 0.5
    animation.isRemovedOnCompletion = false
    animation.delegate = self
    self.gradientLayer.add(animation, forKey: "colorChange")
  }
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
      gradientLayer.colors = getCurrentGradientColors()
      addBorderAnimation()
  }
  
  func addAnimationToCurrentPosition() {
    currentLocation = CGPoint(
      x: (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth) * 0.5 +
        (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth) * CGFloat(cell.column),
      y: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight) * 0.5 +
        (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight) * CGFloat(cell.row))
    weak var weakSelf = self
    AnimationManager.addAnimationBlock {
      if let weakSelf = weakSelf {
        weakSelf.center = CGPoint(
          x: (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth) * 0.5 +
            (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth) * CGFloat(weakSelf.cell.column),
          y: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight) * 0.5 +
            (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight) * CGFloat(weakSelf.cell.row))
      }
    }
  }
  
  func resetToInitialState() {
    cell.row = initialCell.row
    cell.column = initialCell.column
    chip.gamePosition = chip.initialGamePosition
    updateChipBackgroundColor(forState: .normal)
  }
  
  func applyState() {
    initialCell.row = cell.row
    initialCell.column = cell.column
    if chip.gamePosition == .onBoard && chip.initialGamePosition == .inHand {
      updateChipBackgroundColor(forState: .justDrawn)
    } else {
      updateChipBackgroundColor(forState: .normal)
    }
    chip.initialGamePosition = chip.gamePosition
  }
}
