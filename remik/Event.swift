//
//  Event.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

class Event<T> {
  typealias EventHandler = (T) -> ()
  
  private var eventHandlers = [EventHandler]()
  
  func addHandler(handler: @escaping EventHandler) {
    eventHandlers.append(handler)
  }
  
  func raise(data: T) {
    for handler in eventHandlers {
      handler(data)
    }
  }
}
