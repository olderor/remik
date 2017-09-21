//
//  PlayerTableViewCell.swift
//  remik
//
//  Created by olderor on 21.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var nameTextField: UITextField!
  
  func updateCell(playerIndex: Int, playerName: String?) {
    label.text = "Player \(playerIndex + 1) name: "
    label.sizeToFit()
    nameTextField.text = playerName ?? "Player \(playerIndex + 1)"
    nameTextField.tag = playerIndex
  }
}
