//
//  ViewController.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {

  @IBOutlet weak var handScrollView: UIScrollView!
  
  @IBOutlet weak var boardScrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let contentLength = max(self.view.bounds.size.width, self.view.bounds.size.height) * 2
    boardScrollView.contentSize = CGSize(width: contentLength, height: contentLength)
    boardScrollView.maximumZoomScale = 2.0
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

