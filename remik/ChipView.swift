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

class ChipView: UIView {
  var label: UILabel!
  var imageView: UIImageView!
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
    layer.cornerRadius = 5.0
    layer.borderColor = chip.color.getBorderColor().cgColor
    layer.borderWidth = 5.0
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
