//
//  ViewController.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var handScrollViewHeightLayoutConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var boardScrollView: UIScrollView!
  
  @IBOutlet weak var handScrollView: UIScrollView!
  
  var game: Game!
  
  var boardView: BoardView!
  var handViews: [HandView]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    handScrollView.backgroundColor = HandView.defaultBackgroundColor
    
    boardScrollView.delegate = self
    boardScrollView.minimumZoomScale = 0.5
    boardScrollView.maximumZoomScale = 1.0
    
    boardView = BoardView(frame:
      CGRect(x: 0,
             y: 0,
             width: self.view.bounds.size.width,
             height: self.view.bounds.size.height -
              (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
    boardView.dragAndDropProcessor.mainView = self.view
    boardView.addMoveOutOfViewEventListener(handler: moveToHand)
    boardView.addSizeChangedEventListener(handler: updateBoardScrollViewContentSize)
    boardScrollView.addSubview(boardView)
    
    let players = [Player(name: "pl1"), Player(name: "pl2")]
    handViews = []
    for player in players {
      let handView = HandView(player: player, frame: CGRect(
        x: 0,
        y: 0,
        width: self.view.bounds.size.width,
        height: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
      handScrollView.addSubview(handView)
      handView.dragAndDropProcessor.mainView = self.view
      handView.addMoveOutOfViewEventListener(handler: moveToBoard)
      handView.addSizeChangedEventListener(handler: updateHandScrollViewContentSize)
      handViews.append(handView)
    }
    
    handViews[0].show()
    game = Game(players: players)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func moveToBoard(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
    let locationInBoard = gestureRecognizer.location(in: boardView)
    boardView.didMoveChipToView(chipView: chipView, toLocation: locationInBoard)
  }
  
  func moveToHand(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
    // Only jokers are allowed to be returned into the hand.
    if chipView.chip.type == .anyJoker || chipView.chip.type == .coloredJoker {
      let locationInHand = gestureRecognizer.location(in: handViews[game.currentPlayerIndex])
      handViews[game.currentPlayerIndex].didMoveChipToView(chipView: chipView, toLocation: locationInHand)
    } else {
      //todo show alert: wrong move
      boardView.addSubview(chipView)
      boardView.chipViewMatrix[chipView.chip.cell.row, chipView.chip.cell.column] = chipView
      boardView.dragAndDropProcessor.updateChipViewPosition(cell: chipView.chip.cell)
      AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
      AnimationManager.playAll()
    }
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return true
  }
  
  func updateBoardScrollViewContentSize(newSize: CGSize) {
    boardScrollView.contentSize = newSize
  }
  
  func updateHandScrollViewContentSize(newSize: CGSize) {
    handScrollView.contentSize = newSize
    handScrollViewHeightLayoutConstraint.constant = newSize.height
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    if scrollView.subviews.count == 0 {
      return nil
    }
    return scrollView.subviews[0]
  }
}
