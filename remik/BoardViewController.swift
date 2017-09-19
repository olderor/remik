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
  var handViews: [HandView]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    boardView = BoardView(frame:
      CGRect(x: 0,
             y: 0,
             width: self.view.bounds.size.width,
             height: self.view.bounds.size.height -
              (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
    boardView.dragAndDropProcessor.mainView = self.view
    boardView.addMoveOutOfViewEventListener(handler: moveToHand)
    self.view.addSubview(boardView)
    
    let players = [Player(name: "pl1"), Player(name: "pl2")]
    handViews = []
    for player in players {
      let handView = HandView(player: player, frame: CGRect(
        x: 0,
        y: self.view.bounds.size.height - (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight),
        width: self.view.bounds.size.width,
        height: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight)))
      self.view.addSubview(handView)
      handView.dragAndDropProcessor.mainView = self.view
      handView.addMoveOutOfViewEventListener(handler: moveToBoard)
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
      let locationInBoard = gestureRecognizer.location(in: boardView)
      boardView.didMoveChipToView(chipView: chipView, toLocation: locationInBoard)
    }
  }
}

