//
//  HandView.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class HandView: UIScrollView, UIGestureRecognizerDelegate {
  var player: Player
  
  let chipDefaultOffset: CGFloat  = 10
  var chipOffset: CGFloat  = 5
  let chipDefaultViewSize: CGFloat = 50
  
  var panGestureRecognizerHash: Int!
  
  var chipViews: [ChipView?]
  
  init(player: Player, frame: CGRect) {
    self.player = player
    chipViews = [ChipView?](repeating: nil, count: player.hand.count)
    
    super.init(frame: frame)
    
    backgroundColor = UIColor.black
    player.addDidDrawEventListener(handler: didDraw)
    
    let panGestureRecognizer = UIPanGestureRecognizer(
      target: self, action: #selector(panGestureRecognized(gestureRecognizer:)))
    panGestureRecognizer.delegate = self
    panGestureRecognizerHash = panGestureRecognizer.hash
    addGestureRecognizer(panGestureRecognizer)
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
    updateContentSize()
    addSubview(chipView)
    chipViews[chip.handIndex!] = chipView
  }
  
  func updateContentSize() {
    contentSize = CGSize(width: (chipDefaultViewSize + chipDefaultOffset) * CGFloat(player.handLastIndex), height: self.frame.size.height)
  }
  
  func hide() {
    isHidden = true
  }
  
  func show() {
    isHidden = false
  }
  
  func shiftChips(from: Int) {
    weak var weakSelf = self
    for index in from..<chipViews.count {
      weak var weakView = chipViews[index]
      if let chip = chipViews[index]?.chip {
        chip.handIndex! += 1
        AnimationManager.addAnimationBlock {
          if let weakSelf = weakSelf, let weakView = weakView {
            weakView.center = CGPoint(
              x: weakView.center.x + weakSelf.chipDefaultOffset + weakSelf.chipDefaultViewSize,
              y: weakView.center.y)
          }
        }
      }
    }
    
    player.handLastIndex += 1
    player.hand.insert(nil, at: from)
    chipViews.insert(nil, at: from)
  }
  
  private func updateChipViewPosition(index: Int) {
    weak var weakView = chipViews[index]
    weak var weakSelf = self
    AnimationManager.addAnimationBlock {
      if let weakSelf = weakSelf, let weakView = weakView {
        weakView.center = CGPoint(
          x: (weakSelf.chipDefaultOffset + weakSelf.chipDefaultViewSize) * 0.5 +
          (weakSelf.chipDefaultOffset + weakSelf.chipDefaultViewSize) * CGFloat(index),
          y: weakSelf.frame.size.height / 2.0)
      }
    }
  }
  
  func moveChip(from: Int, to: Int) {
    if chipViews[from] == nil {
      return
    }
    if from != to {
      var from = from
      if player.hand[to] != nil {
        shiftChips(from: to)
        if from > to {
          from += 1
        }
      }
      player.move(from: from, to: to)
      chipViews[to] = chipViews[from]
      chipViews[from] = nil
    }
    updateChipViewPosition(index: to)
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
  }
  
  private var movingFrom: Int!
  
  func getChipIndexBy(location: CGPoint) -> Int {
    // todo: test when scrolled
    return Int(location.x / (chipDefaultViewSize + chipDefaultOffset))
  }
  
  func panGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
    let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
    let state = panGestureRecognizer.state
    let locationInView = panGestureRecognizer.location(in: self)
    switch state {
    case .began:
      movingFrom = getChipIndexBy(location: locationInView)
      chipViews[movingFrom]?.layer.zPosition = 100
      break
    case .changed:
      chipViews[movingFrom]?.center = locationInView
      break
    case .ended:
      chipViews[movingFrom]?.layer.zPosition = 0
      moveChip(from: movingFrom, to: getChipIndexBy(location: locationInView))
      break
    default:
      break
    }
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if gestureRecognizer.hash != panGestureRecognizerHash {
      return true
    }
    let yOffset = (frame.size.height - chipDefaultViewSize) / 2.0
    let locationInView = touch.location(in: self)
    if locationInView.y < yOffset ||
      yOffset + chipDefaultViewSize < locationInView.y {
      return false
    }
    let chipIndex = getChipIndexBy(location: locationInView)
    if chipViews[chipIndex] == nil {
      return false
    }
    return true
  }
}
