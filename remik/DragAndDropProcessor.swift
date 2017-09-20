//
//  DragAndDropProcessor.swift
//  remik
//
//  Created by olderor on 19.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class DragAndDropProcessor: NSObject, UIGestureRecognizerDelegate {
  private var movingFromCell: Cell!
  private var panGestureRecognizerHash: Int!
  private weak var view: ChipsContainerView?
  private let moveOutOfViewEvent = Event<(chipView: ChipView, gestureRecognizer: UIGestureRecognizer)>()
  weak var mainView: UIView?
  
  init(view: ChipsContainerView) {
    super.init()
    self.view = view
    
    let panGestureRecognizer = UIPanGestureRecognizer(
      target: self, action: #selector(panGestureRecognized(gestureRecognizer:)))
    panGestureRecognizer.delegate = self
    panGestureRecognizerHash = panGestureRecognizer.hash
    view.addGestureRecognizer(panGestureRecognizer)
  }
  
  func addMoveOutOfViewEventListener(handler:
    @escaping ((chipView: ChipView, gestureRecognizer: UIGestureRecognizer)) -> ()) {
    
    moveOutOfViewEvent.addHandler(handler: handler)
  }
  
  public func updateChipViewPosition(cell: Cell) {
    if let chipView = view?.chipViewMatrix[cell.row, cell.column] {
      chipView.cell = cell
      chipView.addAnimationToCurrentPosition()
    }
  }
  
  private func findFreeColumnInRow(starting from: Cell) -> Int {
    var column = from.column
    while column < view!.chipViewMatrix.columns {
      if view!.chipViewMatrix[from.row, column] == nil {
        return column
      }
      column += 1
    }
    view!.addColumnToMatrix()
    return column
  }
  
  private func shiftChipsToRightIfNeeded(from: Cell) {
    if self.view == nil {
      return
    }
    
    let view = self.view!
    var freeColumn = findFreeColumnInRow(starting: from)
    
    while from.column < freeColumn {
      let viewToMove = view.chipViewMatrix[from.row, freeColumn - 1]!
      view.chipViewMatrix[from.row, freeColumn] = viewToMove
      viewToMove.cell.column = freeColumn
      viewToMove.addAnimationToCurrentPosition()
      freeColumn -= 1
    }
  }
  
  func move(chipView: ChipView?, to: Cell) {
    if self.view == nil || chipView == nil {
      return
    }
    let view = self.view!
    let chipView = chipView!
    shiftChipsToRightIfNeeded(from: to)
    view.chipViewMatrix[to.row, to.column] = chipView
    chipView.cell = to
    updateChipViewPosition(cell: to)
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
  }
  
  func moveChip(from: Cell, to: Cell) {
    if self.view == nil {
      return
    }
    let view = self.view!
    if view.chipViewMatrix[from.row, from.column] == nil {
      return
    }
    view.chipViewMatrix.resizeIfNeeded(defaultValue: nil, rows: to.row + 1, columns: to.column + 1)
    let cellToMove = view.chipViewMatrix[from.row, from.column]!
    view.chipViewMatrix[from.row, from.column] = nil
    if from != to {
      shiftChipsToRightIfNeeded(from: to)
    }
    view.chipViewMatrix[to.row, to.column] = cellToMove
    cellToMove.cell = to
    updateChipViewPosition(cell: to)
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
  }
  
  private func beginTouch(touch: UITouch) {
    let locationInView = touch.location(in: view)
    
    movingFromCell = LocationManager.getCellBy(
      location: locationInView,
      cellRect: ChipView.cellRect)
  }
  
  @objc func panGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
    if self.view == nil {
      return
    }
    
    let view = self.view!
    
    let state = gestureRecognizer.state
    
    let locationInView = gestureRecognizer.location(in: view)
    let locationInSuperView = gestureRecognizer.location(in: view.superview)
    let locationInMainView = gestureRecognizer.location(in: mainView)
    
    switch state {
    case .began:
      if let chipView = view.chipViewMatrix[movingFromCell.row, movingFromCell.column] {
        mainView?.addSubview(chipView)
        chipView.center = locationInMainView
        chipView.currentLocation = locationInView
        mainView?.bringSubview(toFront: chipView)
        chipView.backgroundColor = ChipView.getChipBackgroundColor(forState: .normal)
      }
      break
    case .cancelled, .failed:
      if movingFromCell != nil {
        if let chipView = view.chipViewMatrix[movingFromCell.row, movingFromCell.column] {
          view.addSubview(chipView)
        }
        updateChipViewPosition(cell: movingFromCell)
      }
      break
    case .changed:
      if let chipView = view.chipViewMatrix[movingFromCell.row, movingFromCell.column] {
        chipView.currentLocation = locationInView
        chipView.center = locationInMainView
      }
      break
    case .ended:
      if locationInSuperView.x < 0 ||
        locationInSuperView.y < 0 ||
        locationInSuperView.x > view.superview!.frame.size.width ||
        locationInSuperView.y > view.superview!.frame.size.height {
        if let chipView = view.chipViewMatrix[movingFromCell.row, movingFromCell.column] {
          view.chipViewMatrix[movingFromCell.row, movingFromCell.column] = nil
          moveOutOfViewEvent.raise(data:
            (chipView: chipView, gestureRecognizer: gestureRecognizer))
        }
        break
      }
      if let chipView = view.chipViewMatrix[movingFromCell.row, movingFromCell.column] {
        view.addSubview(chipView)
        chipView.center = locationInView
        chipView.currentLocation = locationInView
      }
      let toCell = LocationManager.getCellBy(
        location: locationInView,
        cellSize: ChipView.cellSize)
      moveChip(from: movingFromCell, to: toCell)
      break
    default:
      print(state)
      break
    }
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if self.view == nil {
      return true
    }
    let view = self.view!
    
    if gestureRecognizer.hash != panGestureRecognizerHash {
      return true
    }
    
    let locationInView = touch.location(in: view)
    
    let cell = LocationManager.getCellBy(
      location: locationInView,
      cellRect: ChipView.cellRect)
    
    if cell == nil {
      return false
    }
    if cell!.row >= view.chipViewMatrix.rows ||
      cell!.column >= view.chipViewMatrix.columns {
      return false
    }
    
    if view.chipViewMatrix[cell!.row, cell!.column] == nil {
      return false
    }
    beginTouch(touch: touch)
    return true
  }
}
