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
  
  private var game: Game!
  
  private var boardView: BoardView!
  private var handViews: [HandView]!
  
  var playerNames: [String]!
  
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
    
    handViews = []
    var players = [Player]()
    for name in playerNames {
      let player = Player(name: name)
      players.append(player)
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
    
    game = Game(players: players)
    for handView in handViews {
      handView.previousDrawnChipView?.backgroundColor =
        ChipView.getChipBackgroundColor(forState: .normal)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if game.isStarted {
      return
    }
    
    let alertController = UIAlertController(
      title: "Ready",
      message: "Game is ready to start. The first player is \(game.currentPlayer.name). Press OK, when ready.", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: "OK",
      style: UIAlertActionStyle.default,
      handler: {(alert: UIAlertAction!) in
        self.game.isStarted = true
        self.showCurrentHand()
    }))
    self.present(alertController, animated: true, completion: nil)
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
  
  private func getCurrentHandState(playerIndex: Int) -> Matrix<Chip?> {
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
  
  private func getCurrentBoardState() -> Matrix<Chip?> {
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
  
  private func applyStateChanges(for playerIndex: Int) {
    game.chipsPlacedOnBoardCount = 0
    endTurnButton.setTitle(EndTurnStates.drawChip.rawValue, for: .normal)
    let handChipViewMatrix = Matrix<ChipView?>(rows: handViews[playerIndex].chipViewMatrix.rows, columns: 0, repeatedValue: nil)
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
  }
  
  private func resetBoardStateChanges(for playerIndex: Int) {
    game.chipsPlacedOnBoardCount = 0
    endTurnButton.setTitle(EndTurnStates.drawChip.rawValue, for: .normal)
    
    let handChipViewMatrix = Matrix<ChipView?>(rows: handViews[playerIndex].chipViewMatrix.rows, columns: 0, repeatedValue: nil)
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
  
  private func resetStateChanges(for playerIndex: Int) {
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
  
  private func hightlightWrongPlacedChipsOnBoard(range: CellRange) {
    for column in range.fromColumn..<range.toColumn {
      if let chipView = boardView.chipViewMatrix[range.row, column] {
        chipView.backgroundColor = ChipView.getChipBackgroundColor(forState: .wrongPlaced)
      }
    }
  }
  
  private func waitForNextPlayer() {
    let alertController = UIAlertController(
      title: "Waiting for the next player",
      message: "Give device to the next player \(game.currentPlayer.name). Press OK, when ready.", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: "OK",
      style: UIAlertActionStyle.default,
      handler: {(alert: UIAlertAction!) in
        self.showCurrentHand()
      }))
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func onPlayerWon() {
    let alertController = UIAlertController(
      title: "You win!",
      message: "Congratulations! Player \(game.currentPlayer.name) won the game.", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: "OK",
      style: UIAlertActionStyle.default,
      handler: {(alert: UIAlertAction!) in
        self.dismiss(animated: true, completion: nil)
    }))
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func endTurn() {
    let currentPlayerIndex = game.currentPlayerIndex
    
    if game.shouldDrawChip {
      
      game.board.updatedState = getCurrentBoardState()
      let result = game.board.verifyBoardState()
      if result.success {
        game.players[currentPlayerIndex].updatedState =
          getCurrentHandState(playerIndex: currentPlayerIndex)
        applyStateChanges(for: currentPlayerIndex)
        handViews[currentPlayerIndex].hide()
        game.drawChip()
        waitForNextPlayer()
      } else {
        for error in result.errors {
          hightlightWrongPlacedChipsOnBoard(range: error.cellRange)
        }
        askToResetStateBeforeEndTurn()
      }
      return
    }
    
    game.board.updatedState = getCurrentBoardState()
    game.players[currentPlayerIndex].updatedState =
      getCurrentHandState(playerIndex: currentPlayerIndex)
    
    let result = game.tryEndTurn()
    if result.success {
      if game.currentPlayer.chipsInHandCount == 0 {
        onPlayerWon()
        return
      }
      handViews[currentPlayerIndex].hide()
      applyStateChanges(for: currentPlayerIndex)
      waitForNextPlayer()
    } else {
      var errorsList = [String]()
      for error in result.errors {
        hightlightWrongPlacedChipsOnBoard(range: error.cellRange)
        if errorsList.count < 3 {
          errorsList.append(error.errorDescription)
        }
      }
      var errorsMessage = errorsList.joined(separator: "\n\n")
      if errorsList.count != result.errors.count {
        errorsMessage += "..."
      }
      let alertController = UIAlertController(title: "Incorrect board state (found \(result.errors.count) incorrect sequences)", message: "Consider fixing those mistakes (or you can reset board state).\n\n" + errorsMessage, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  private func askToResetStateBeforeEndTurn() {
    let alertController = UIAlertController(
      title: "Board is in incorrect state",
      message: "You did some actions that turned board into incorrect state. Do you want to cancel your actions and end the turn by drawing a chip or continue your turn and do some other actions?", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: "Reset",
      style: UIAlertActionStyle.default,
      handler: {(alert: UIAlertAction!) in
        self.resetStateChanges(for: self.game.currentPlayerIndex)
        self.endTurn()
    }))
    alertController.addAction(UIAlertAction(
      title: "Continue turn",
      style: UIAlertActionStyle.default,
      handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func onEndTurnButtonTouchUpInside(_ sender: UIButton) {
    endTurn()
  }
  
  @IBAction func onResetButtonTouchUpInside(_ sender: UIButton) {
    resetStateChanges(for: game.currentPlayerIndex)
  }
  
  @IBAction func onExitButtonTouchUpInside(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func moveToBoard(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
    chipView.chip.gamePosition = .onBoard
    game.chipsPlacedOnBoardCount += 1
    endTurnButton.setTitle(EndTurnStates.endTurn.rawValue, for: .normal)
    let locationInBoard = gestureRecognizer.location(in: boardView)
    boardView.didMoveChipToView(chipView: chipView, toLocation: locationInBoard)
  }
  
  private func moveToHand(chipView: ChipView, gestureRecognizer: UIGestureRecognizer) {
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
      handViews[game.currentPlayerIndex].didMoveChipToView(
        chipView: chipView, toLocation: locationInHand)
      chipView.chip.gamePosition = .inHand
    } else {
      let alertController = UIAlertController(
        title: "Incorrect move",
        message: "You can not move chips with numbers to your hand. Only jokers are allowed to be grabbed.",
        preferredStyle: .alert)
      
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
      boardView.addSubview(chipView)
      boardView.chipViewMatrix[chipView.cell.row, chipView.cell.column] = chipView
      boardView.dragAndDropProcessor.updateChipViewPosition(cell: chipView.cell)
      AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
      AnimationManager.playAll()
    }
  }
  
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch) -> Bool {
    
    return true
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    if scrollView.subviews.count == 0 {
      return nil
    }
    return scrollView.subviews[0]
  }
  
  private func updateBoardScrollViewContentSize(newSize: CGSize) {
    boardScrollView.contentSize = newSize
  }
  
  private func updateHandScrollViewContentSize(newSize: CGSize) {
    handScrollView.contentSize = newSize
    handScrollViewHeightLayoutConstraint.constant = newSize.height
  }
  
  private func showCurrentHand() {
    handViews[game.currentPlayerIndex].show()
  }
  
  @IBAction func increaseHandSize(_ sender: UIBarButtonItem) {
    handViews[game.currentPlayerIndex].addRowToMatrix()
  }
  
  @IBAction func decreaseHandSize(_ sender: UIBarButtonItem) {
    do {
      try handViews[game.currentPlayerIndex].removeLastRow()
    } catch {
      let alertController = UIAlertController(
        title: "Warning",
        message: "The raw contains some chips, move them up to clear the row before removing it.",
        preferredStyle: .alert)
      
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
  }
}
