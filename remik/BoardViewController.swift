//
//  ViewController.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {
  var game: Game!
  
  var boardView: BoardView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    boardView = BoardView(frame:
      CGRect(x: 0,
             y: 0,
             width: self.view.bounds.size.width,
             height: self.view.bounds.size.height -
              (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
    boardView.maximumZoomScale = 2.0
    boardView.backgroundColor = UIColor.brown
    self.view.addSubview(boardView)
    
    let pl1 = Player(name: "pl1")
    let pl2 = Player(name: "pl2")
    
    let hand1 = HandView(player: pl1, frame: CGRect(
      x: 0,
      y: self.view.bounds.size.height - (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight),
      width: self.view.bounds.size.width,
      height: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
    
    let hand2 = HandView(player: pl2, frame: CGRect(
      x: 0,
      y: self.view.bounds.size.height - (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight),
      width: self.view.bounds.size.width,
      height: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
    
    
    self.view.addSubview(hand1)
    self.view.addSubview(hand2)
    
    boardView.dragAndDropProcessor.mainView = self.view
    hand1.dragAndDropProcessor.mainView = self.view
    hand2.dragAndDropProcessor.mainView = self.view
    hand1.addMoveOutOfViewEventListener(handler: moveToBoard(chipView:gestureRecognizer:))
    hand2.addMoveOutOfViewEventListener(handler: moveToBoard(chipView:gestureRecognizer:))
    
    hand2.hide()
    game = Game(players: [pl1, pl2])
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func moveToBoard(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
    let locationInBoard = gestureRecognizer.location(in: boardView)
    
    chipView.removeFromSuperview()
    boardView.addSubview(chipView)
    chipView.center = locationInBoard
  }
}

