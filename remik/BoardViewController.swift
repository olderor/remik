//
//  ViewController.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {
  
  @IBOutlet weak var boardScrollView: UIScrollView!
  
  var game: Game!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let contentLength = max(self.view.bounds.size.width, self.view.bounds.size.height) * 2
    boardScrollView.contentSize = CGSize(width: contentLength, height: contentLength)
    boardScrollView.maximumZoomScale = 2.0
    
    
    let pl1 = Player(name: "pl1")
    let pl2 = Player(name: "pl2")
    
    let hand1 = HandView(player: pl1, frame: CGRect(x: 0, y: self.view.bounds.size.height - 100, width: self.view.bounds.size.width, height: 100))
    let hand2 = HandView(player: pl2, frame: CGRect(x: 0, y: self.view.bounds.size.height - 100, width: self.view.bounds.size.width, height: 100))
    self.view.addSubview(hand1)
    self.view.addSubview(hand2)
    hand2.hide()
    
    game = Game(players: [pl1, pl2])
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

