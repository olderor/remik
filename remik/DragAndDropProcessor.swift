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
  public weak var mainView: UIView?
  
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
  
  private func updateChipViewPosition(cell: Cell) {
    weak var weakView = view?.chipViewMatrix[cell.row][cell.column]
    AnimationManager.addAnimationBlock {
      if let weakView = weakView {
        weakView.center = CGPoint(
          x: (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth) * 0.5 +
            (ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth) * CGFloat(cell.column),
          y: (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight) * 0.5 +
            (ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight) * CGFloat(cell.row))
      }
    }
  }
  
  private func findFreeColumnInRow(starting from: Cell) -> Int {
    var column = from.column
    while column < view!.chipViewMatrix.columns {
      if view!.chipViewMatrix[from.row][column] == nil {
        return column
      }
      column += 1
    }
    view!.addColumnToMatrix()
    return column
  }
  
  private func shiftChipsToRightIfNeeded(from: Cell) {
    if view == nil {
      return
    }
    
    var freeColumn = findFreeColumnInRow(starting: from)
    
    while from.column < freeColumn {
      weak var viewToMove = view!.chipViewMatrix[from.row][freeColumn - 1]
      view!.chipViewMatrix[from.row][freeColumn] = viewToMove
      viewToMove!.chip.cell.column += 1
      
      AnimationManager.addAnimationBlock {
        if let viewToMove = viewToMove {
          viewToMove.center = CGPoint(
            x: viewToMove.center.x + ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth,
            y: viewToMove.center.y)
        }
      }
      freeColumn -= 1
    }
  }
  
  func moveChip(from: Cell, to: Cell) {
    if self.view == nil {
      return
    }
    let view = self.view!
    if view.chipViewMatrix[from.row][from.column] == nil {
      return
    }
    let cellToMove = view.chipViewMatrix[from.row][from.column]!
    view.chipViewMatrix[from.row][from.column] = nil
    if from != to {
      shiftChipsToRightIfNeeded(from: to)
    }
    view.chipViewMatrix[to.row][to.column] = cellToMove
    updateChipViewPosition(cell: to)
    AnimationManager.addLastAnimationBlock(completion: nil, type: .animation, description: nil)
    AnimationManager.playAll()
  }
  
  func panGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
    if self.view == nil {
      return
    }
    let view = self.view!
    let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
    let state = panGestureRecognizer.state
    let locationInView = panGestureRecognizer.location(in: view)
    let locationInMainView = panGestureRecognizer.location(in: mainView)
    switch state {
    case .began:
      movingFromCell = LocationManager.getCellBy(
        location: locationInView,
        cellRect: CGRect(
          x: ChipView.chipDefaultOffsetX,
          y: ChipView.chipDefaultOffsetY,
          width: ChipView.chipDefaultViewWidth,
          height: ChipView.chipDefaultViewHeight))
      if let chipView = view.chipViewMatrix[movingFromCell.row][movingFromCell.column] {
        chipView.removeFromSuperview()
        mainView?.addSubview(chipView)
        chipView.center = locationInMainView
        mainView?.bringSubview(toFront: chipView)
      }
      break
    case .changed:
      view.chipViewMatrix[movingFromCell.row][movingFromCell.column]?.center = locationInMainView
      break
    case .ended:
      if locationInView.x < 0 || locationInView.y < 0 {
        if let chipView = view.chipViewMatrix[movingFromCell.row][movingFromCell.column] {
          moveOutOfViewEvent.raise(data:
            (chipView: chipView, gestureRecognizer: gestureRecognizer))
        }
        break
      }
      if let chipView = view.chipViewMatrix[movingFromCell.row][movingFromCell.column] {
        chipView.removeFromSuperview()
        view.addSubview(chipView)
        chipView.center = locationInView
      }
      let toCell = LocationManager.getCellBy(
        location: locationInView,
        cellSize: CGSize(
          width: ChipView.chipDefaultOffsetX + ChipView.chipDefaultViewWidth,
          height: ChipView.chipDefaultOffsetY + ChipView.chipDefaultViewHeight))
      moveChip(from: movingFromCell, to: toCell)
      break
    default:
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
      cellRect: CGRect(
        x: ChipView.chipDefaultOffsetX,
        y: ChipView.chipDefaultOffsetY,
        width: ChipView.chipDefaultViewWidth,
        height: ChipView.chipDefaultViewHeight))
    
    if cell == nil {
      return false
    }
    
    if view.chipViewMatrix[cell!.row][cell!.column] == nil {
      return false
    }
    return true
  }
}
