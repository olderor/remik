//
//  LocationManager.swift
//  remik
//
//  Created by olderor on 19.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class LocationManager {
  static func getCellBy(location: CGPoint, cellRect: CGRect) -> Cell? {
    let cell = Cell(row: Int(location.y / (cellRect.origin.y + cellRect.size.height)),
                    column: Int(location.x / (cellRect.origin.x + cellRect.size.width)))
    
    let positionInRect = CGPoint(
      x: location.x - CGFloat(cell.column) * (cellRect.origin.x + cellRect.size.width),
      y: location.y - CGFloat(cell.row) * (cellRect.origin.y + cellRect.size.height))
    
    if positionInRect.x < cellRect.origin.x * 0.5 ||
      cellRect.origin.x * 0.5 + cellRect.size.width < positionInRect.x ||
      positionInRect.y < cellRect.origin.y * 0.5 ||
      cellRect.origin.y * 0.5 + cellRect.size.height < positionInRect.y {
      
      return nil
    }
    
    return cell
  }
  
  static func getCellBy(location: CGPoint, cellSize: CGSize) -> Cell {
    return Cell(row: Int(location.y / cellSize.height),
                column: Int(location.x / cellSize.width))
  }
}
