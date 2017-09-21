//
//  PlayersViewController.swift
//  remik
//
//  Created by olderor on 20.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class PlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var playerNames = [String?]()
  
  let minimumNumberOfPlayers = 1
  
  @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
  
  @IBOutlet weak var editButton: UIButton!
  
  @IBOutlet weak var playersTableView: UITableView!
  
  @IBAction func onAddPlayerButtonTouchUpInside(_ sender: UIButton) {
    playerNames.append(nil)
    playersTableView.reloadData()
  }
  
  @IBAction func onEditButtonTouchUpInside(_ sender: UIButton) {
    if playersTableView.isEditing {
      editButton.setTitle("Edit", for: UIControlState.normal)
    } else {
      editButton.setTitle("Done", for: UIControlState.normal)
    }
    playersTableView.setEditing(!playersTableView.isEditing, animated: true)
  }
  
  
  @IBAction func onStartGameButtonTouchUpInside(_ sender: UIButton) {
    let boardViewController = storyboard?.instantiateViewController(withIdentifier: "board") as! BoardViewController
    var names = [String]()
    for index in 0..<playerNames.count {
      if let name = playerNames[index] {
        names.append(name)
      } else {
        names.append("Player \(index + 1)")
      }
    }
    boardViewController.playerNames = names
    
    self.present(boardViewController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    for _ in 0..<3 {
      playerNames.append(nil)
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }
  
  @objc func nameTextFieldDidChange(_ textField: UITextField) {
    playerNames[textField.tag] = textField.text!
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return playerNames.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.row == playerNames.count {
      let cell = playersTableView.dequeueReusableCell(withIdentifier: "addCell")!
      return cell
    }
    
    let cell = playersTableView.dequeueReusableCell(withIdentifier: "cell") as! PlayerTableViewCell
    cell.updateCell(playerIndex: indexPath.row, playerName: playerNames[indexPath.row])
    cell.nameTextField.addTarget(
      self,
      action: #selector(nameTextFieldDidChange(_:)),
      for: UIControlEvents.editingChanged)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if indexPath.row == playerNames.count {
      return UITableViewCellEditingStyle.none
    }
    return UITableViewCellEditingStyle.delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      if playerNames.count == minimumNumberOfPlayers {
        let alertController = UIAlertController(
          title: "Warning",
          message: "The minimum number of players is \(minimumNumberOfPlayers)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertActionStyle.default,
          handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
      }
      playerNames.remove(at: indexPath.row)
      playersTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
      playersTableView.reloadData()
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func keyboardNotification(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
      let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
      if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
        self.keyboardHeightLayoutConstraint?.constant = 0.0
      } else {
        self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
      }
      UIView.animate(withDuration: duration,
                     delay: TimeInterval(0),
                     options: animationCurve,
                     animations: { self.view.layoutIfNeeded() },
                     completion: nil)
    }
  }
}
