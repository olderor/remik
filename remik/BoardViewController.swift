//
//  ViewController.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

enum EndTurnStates: String {
  case endTurn = "End turn",
  drawChip = "Draw chip"
}

class BoardViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var endTurnButton: UIButton!
  
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
  
  private func updateChipView(
    chipView: ChipView,
    playerIndex: Int,
    handChipViewMatrix: Matrix<ChipView?>,
    boardChipViewMatrix: Matrix<ChipView?>) {
    
    switch chipView.chip.gamePosition {
    case .inHand:
      handViews[playerIndex].addSubview(chipView)
      handChipViewMatrix.resizeIfNeeded(
        defaultValue: nil,
        rows: chipView.cell.row + 1,
        columns: chipView.cell.column + 1)
      
      handChipViewMatrix[chipView.cell.row, chipView.cell.column] = chipView
      break
    case .onBoard:
      boardView.addSubview(chipView)
      boardChipViewMatrix.resizeIfNeeded(
        defaultValue: nil,
        rows: chipView.cell.row + 1,
        columns: chipView.cell.column + 1)
      
      boardChipViewMatrix[chipView.cell.row, chipView.cell.column] = chipView
      break
    }
    chipView.addAnimationToCurrentPosition()
  }
  
  func getCurrentHandState(playerIndex: Int) -> Matrix<Chip?> {
    let state = Matrix<Chip?>(
      rows: handViews[playerIndex].chipViewMatrix.rows,
      columns: handViews[playerIndex].chipViewMatrix.columns,
      repeatedValue: nil)
    
    for row in 0..<handViews[playerIndex].chipViewMatrix.rows {
      for column in 0..<handViews[playerIndex].chipViewMatrix.columns {
        state[row, column] = handViews[playerIndex].chipViewMatrix[row, column]?.chip
      }
    }
    
    return state
  }
  
  func getCurrentBoardState() -> Matrix<Chip?> {
    let state = Matrix<Chip?>(
      rows: boardView.chipViewMatrix.rows,
      columns: boardView.chipViewMatrix.columns,
      repeatedValue: nil)
    
    for row in 0..<boardView.chipViewMatrix.rows {
      for column in 0..<boardView.chipViewMatrix.columns {
        state[row, column] = boardView.chipViewMatrix[row, column]?.chip
      }
    }
    
    return state
  }
  
  func applyStateChanges(for playerIndex: Int) {
    game.chipsPlacedOnBoardCount = 0
    endTurnButton.setTitle(EndTurnStates.drawChip.rawValue, for: .normal)
    let handChipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    let boardChipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    for row in 0..<handViews[playerIndex].chipViewMatrix.rows {
      for column in 0..<handViews[playerIndex].chipViewMatrix.columns {
        if let chipView = handViews[playerIndex].chipViewMatrix[row, column] {
          chipView.applyState()
          updateChipView(
            chipView: chipView,
            playerIndex: playerIndex,
            handChipViewMatrix: handChipViewMatrix,
            boardChipViewMatrix: boardChipViewMatrix)
        }
      }
    }
    for row in 0..<boardView.chipViewMatrix.rows {
      for column in 0..<boardView.chipViewMatrix.columns {
        if let chipView = boardView.chipViewMatrix[row, column] {
          chipView.applyState()
          updateChipView(
            chipView: chipView,
            playerIndex: playerIndex,
            handChipViewMatrix: handChipViewMatrix,
            boardChipViewMatrix: boardChipViewMatrix)
        }
      }
    }
    handViews[playerIndex].chipViewMatrix = handChipViewMatrix
    boardView.chipViewMatrix = boardChipViewMatrix
    handViews[playerIndex].updateContentSize()
    boardView.updateContentSize()
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
    
    game.players[playerIndex].updatedState =
      getCurrentHandState(playerIndex: playerIndex)
    game.board.updatedState = getCurrentBoardState()
  }
  
  func resetBoardStateChanges(for playerIndex: Int) {
    game.chipsPlacedOnBoardCount = 0
    endTurnButton.setTitle(EndTurnStates.drawChip.rawValue, for: .normal)
    
    let handChipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    let boardChipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    for row in 0..<handViews[playerIndex].chipViewMatrix.rows {
      for column in 0..<handViews[playerIndex].chipViewMatrix.columns {
        if let chipView = handViews[playerIndex].chipViewMatrix[row, column] {
          
          // Can put joker in the hand. And still draw.
          // Can move chip from one place in hand to another place in hand.
          if chipView.chip.isJoker || chipView.chip.initialGamePosition == .inHand {
            chipView.applyState()
          } else {
            chipView.resetToInitialState()
          }
          updateChipView(
            chipView: chipView,
            playerIndex: playerIndex,
            handChipViewMatrix: handChipViewMatrix,
            boardChipViewMatrix: boardChipViewMatrix)
        }
      }
    }
    for row in 0..<boardView.chipViewMatrix.rows {
      for column in 0..<boardView.chipViewMatrix.columns {
        if let chipView = boardView.chipViewMatrix[row, column] {
          chipView.resetToInitialState()
          updateChipView(
            chipView: chipView,
            playerIndex: playerIndex,
            handChipViewMatrix: handChipViewMatrix,
            boardChipViewMatrix: boardChipViewMatrix)
        }
      }
    }
    handViews[playerIndex].chipViewMatrix = handChipViewMatrix
    boardView.chipViewMatrix = boardChipViewMatrix
    handViews[playerIndex].updateContentSize()
    boardView.updateContentSize()
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
    
    game.players[playerIndex].updatedState =
      getCurrentHandState(playerIndex: playerIndex)
  }
  
  func resetStateChanges(for playerIndex: Int) {
    game.chipsPlacedOnBoardCount = 0
    endTurnButton.setTitle(EndTurnStates.drawChip.rawValue, for: .normal)
    let handChipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    let boardChipViewMatrix = Matrix<ChipView?>(rows: 0, columns: 0, repeatedValue: nil)
    for row in 0..<handViews[playerIndex].chipViewMatrix.rows {
      for column in 0..<handViews[playerIndex].chipViewMatrix.columns {
        if let chipView = handViews[playerIndex].chipViewMatrix[row, column] {
          chipView.resetToInitialState()
          updateChipView(
            chipView: chipView,
            playerIndex: playerIndex,
            handChipViewMatrix: handChipViewMatrix,
            boardChipViewMatrix: boardChipViewMatrix)
        }
      }
    }
    for row in 0..<boardView.chipViewMatrix.rows {
      for column in 0..<boardView.chipViewMatrix.columns {
        if let chipView = boardView.chipViewMatrix[row, column] {
          chipView.resetToInitialState()
          updateChipView(
            chipView: chipView,
            playerIndex: playerIndex,
            handChipViewMatrix: handChipViewMatrix,
            boardChipViewMatrix: boardChipViewMatrix)
        }
      }
    }
    handViews[playerIndex].chipViewMatrix = handChipViewMatrix
    boardView.chipViewMatrix = boardChipViewMatrix
    handViews[playerIndex].updateContentSize()
    boardView.updateContentSize()
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
    
    game.players[playerIndex].updatedState =
      getCurrentHandState(playerIndex: playerIndex)
  }
  
  @IBAction func onEndTurnButtonTouchUpInside(_ sender: UIButton) {
    let currentPlayerIndex = game.currentPlayerIndex
    
    if game.shouldDrawChip {
      handViews[currentPlayerIndex].hide()
      resetBoardStateChanges(for: currentPlayerIndex)
      game.drawChip()
      handViews[game.currentPlayerIndex].show()
      return
    }
    
    let result = game.tryEndTurn()
    if result.success {
      handViews[currentPlayerIndex].hide()
      applyStateChanges(for: currentPlayerIndex)
      handViews[game.currentPlayerIndex].show()
    } else {
      for error in result.errors {
        print(error.localizedDescription)
      }
    }
  }
  
  @IBAction func onResetButtonTouchUpInside(_ sender: UIButton) {
    resetStateChanges(for: game.currentPlayerIndex)
  }
  
  func moveToBoard(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
    chipView.chip.gamePosition = .onBoard
    game.chipsPlacedOnBoardCount += 1
    endTurnButton.setTitle(EndTurnStates.endTurn.rawValue, for: .normal)
    let locationInBoard = gestureRecognizer.location(in: boardView)
    boardView.didMoveChipToView(chipView: chipView, toLocation: locationInBoard)
  }
  
  func moveToHand(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
    // Only jokers are allowed to be returned into the hand. Or user wants to cancel his choice.
    
    if chipView.chip.initialGamePosition == .inHand {
      game.chipsPlacedOnBoardCount -= 1
      if game.chipsPlacedOnBoardCount == 0 {
        endTurnButton.setTitle(EndTurnStates.drawChip.rawValue, for: .normal)
      }
    }
    
    if chipView.chip.type == .anyJoker ||
      chipView.chip.type == .coloredJoker ||
      chipView.chip.initialGamePosition == .inHand {
      let locationInHand = gestureRecognizer.location(in: handViews[game.currentPlayerIndex])
      handViews[game.currentPlayerIndex].didMoveChipToView(chipView: chipView, toLocation: locationInHand)
      chipView.chip.gamePosition = .inHand
    } else {
      let alertController = UIAlertController(title: "Incorrect move", message: "You can not move chips with numbers to your hand. Only jokers are allowed to be grabbed.", preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
      boardView.addSubview(chipView)
      boardView.chipViewMatrix[chipView.cell.row, chipView.cell.column] = chipView
      boardView.dragAndDropProcessor.updateChipViewPosition(cell: chipView.cell)
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
