//
//  Deque.swift
//  remik
//
//  Created by olderor on 18.09.17.
//  Copyright © 2017 Bohdan Yevchenko. All rights reserved.
//

import Foundation

let DequeOverAllocateFactor = 2
let DequeDownsizeTriggerFactor = 16
let DequeDefaultMinimumCapacity = 0

struct Deque<T>: RandomAccessCollection, RangeReplaceableCollection, ExpressibleByArrayLiteral, CustomDebugStringConvertible {
  typealias Index = Int
  typealias Indices = CountableRange<Int>
  typealias Element = T
  
  var buffer: DequeBuffer<T>? = nil
  let minCapacity: Int
  
  init() {
    self.minCapacity = DequeDefaultMinimumCapacity
  }
  
  init(minCapacity: Int) {
    self.minCapacity = minCapacity
  }
  
  init(arrayLiteral: T...) {
    self.minCapacity = DequeDefaultMinimumCapacity
    replaceSubrange(0..<0, with: arrayLiteral)
  }
  
  var debugDescription: String {
    var result = "\(type(of: self))(["
    var iterator = makeIterator()
    if let next = iterator.next() {
      debugPrint(next, terminator: "", to: &result)
      while let n = iterator.next() {
        result += ", "
        debugPrint(n, terminator: "", to: &result)
      }
    }
    result += "])"
    return result
  }
  
  subscript(bounds: Range<Index>) -> RangeReplaceableRandomAccessSlice<Deque<T>> {
    return RangeReplaceableRandomAccessSlice<Deque<T>>(base: self, bounds: bounds)
  }
  
  subscript(_ at: Index) -> T {
    get {
      if let b = buffer {
        precondition(at < b.unsafeHeader.pointee.count)
        var offset = b.unsafeHeader.pointee.offset + at
        if offset >= b.unsafeHeader.pointee.capacity {
          offset -= b.unsafeHeader.pointee.capacity
        }
        return b.unsafeElements[offset]
      } else {
        preconditionFailure("Index beyond end of queue")
      }
    }
  }
  
  var startIndex: Index {
    return 0
  }
  
  var endIndex: Index {
    if let b = buffer {
      return b.unsafeHeader.pointee.count
    }
    
    return 0
  }
  
  var isEmpty: Bool {
    if let b = buffer {
      return b.unsafeHeader.pointee.count == 0
    }
    
    return true
  }
  
  var count: Int {
    return endIndex
  }
  
  mutating func append(_ newElement: T) {
    if let b = buffer {
      if b.unsafeHeader.pointee.capacity >= b.unsafeHeader.pointee.count + 1 {
        var index = b.unsafeHeader.pointee.offset + b.unsafeHeader.pointee.count
        if index >= b.unsafeHeader.pointee.capacity {
          index -= b.unsafeHeader.pointee.capacity
        }
        b.unsafeElements.advanced(by: index).initialize(to: newElement)
        b.unsafeHeader.pointee.count += 1
        return
      }
    }
    
    let index = endIndex
    return replaceSubrange(index..<index, with: CollectionOfOne(newElement))
  }
  
  mutating func prepend(_ newElement: T) {
    var index = startIndex
    if let b = buffer {
      if b.unsafeHeader.pointee.capacity >= b.unsafeHeader.pointee.count + 1 {
        let index = (b.unsafeHeader.pointee.offset - 1 + b.unsafeHeader.pointee.capacity) % b.unsafeHeader.pointee.capacity
        b.unsafeElements.advanced(by: index).initialize(to: newElement)
        b.unsafeHeader.pointee.count += 1
        b.unsafeHeader.pointee.offset = index
        return
      }
      index = 0
    }
    return replaceSubrange(index..<index, with: CollectionOfOne(newElement))
  }
  
  mutating func insert(_ newElement: T, at: Int) {
    if let b = buffer {
      if at == 0, b.unsafeHeader.pointee.capacity >= b.unsafeHeader.pointee.count + 1 {
        var index = b.unsafeHeader.pointee.offset - 1
        if index < 0 {
          index += b.unsafeHeader.pointee.capacity
        }
        b.unsafeElements.advanced(by: index).initialize(to: newElement)
        b.unsafeHeader.pointee.count += 1
        b.unsafeHeader.pointee.offset = index
        return
      }
    }
    
    return replaceSubrange(at..<at, with: CollectionOfOne(newElement))
  }
  
  mutating func remove(at: Int) {
    if let b = buffer {
      if at == b.unsafeHeader.pointee.count - 1 {
        b.unsafeHeader.pointee.count -= 1
        return
      } else if at == 0, b.unsafeHeader.pointee.count > 0 {
        b.unsafeHeader.pointee.offset += 1
        if b.unsafeHeader.pointee.offset >= b.unsafeHeader.pointee.capacity {
          b.unsafeHeader.pointee.offset -= b.unsafeHeader.pointee.capacity
        }
        b.unsafeHeader.pointee.count -= 1
        return
      }
    }
    
    return replaceSubrange(at...at, with: EmptyCollection())
  }
  
  mutating func removeFirst() -> T {
    if let b = buffer {
      precondition(b.unsafeHeader.pointee.count > 0, "Index beyond bounds")
      let result = b.unsafeElements[b.unsafeHeader.pointee.offset]
      b.unsafeElements.advanced(by: b.unsafeHeader.pointee.offset).deinitialize()
      b.unsafeHeader.pointee.offset += 1
      if b.unsafeHeader.pointee.offset >= b.unsafeHeader.pointee.capacity {
        b.unsafeHeader.pointee.offset -= b.unsafeHeader.pointee.capacity
      }
      b.unsafeHeader.pointee.count -= 1
      return result
    }
    preconditionFailure("Index beyond bounds")
  }
  
  fileprivate static func deinitialize(range: CountableRange<Int>, header: UnsafeMutablePointer<DequeHeader>, body: UnsafeMutablePointer<T>) {
    let splitRange = Deque.mapIndices(inRange: range, header: header)
    body.advanced(by: splitRange.low.startIndex).deinitialize(count: splitRange.low.count)
    body.advanced(by: splitRange.high.startIndex).deinitialize(count: splitRange.high.count)
  }
  
  fileprivate static func moveInitialize(preMappedSourceRange: CountableRange<Int>, postMappedDestinationRange: CountableRange<Int>, sourceHeader: UnsafeMutablePointer<DequeHeader>, sourceBody: UnsafeMutablePointer<T>, destinationBody: UnsafeMutablePointer<T>) {
    let sourceSplitRange = Deque.mapIndices(inRange: preMappedSourceRange, header: sourceHeader)
    
    assert(sourceSplitRange.low.startIndex >= 0 && (sourceSplitRange.low.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.low.startIndex == sourceSplitRange.low.endIndex))
    assert(sourceSplitRange.low.endIndex >= 0 && sourceSplitRange.low.endIndex <= sourceHeader.pointee.capacity)
    
    assert(sourceSplitRange.high.startIndex >= 0 && (sourceSplitRange.high.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.high.startIndex == sourceSplitRange.high.endIndex))
    assert(sourceSplitRange.high.endIndex >= 0 && sourceSplitRange.high.endIndex <= sourceHeader.pointee.capacity)
    
    destinationBody.advanced(by: postMappedDestinationRange.startIndex).moveInitialize(from: sourceBody.advanced(by: sourceSplitRange.low.startIndex), count: sourceSplitRange.low.count)
    destinationBody.advanced(by: postMappedDestinationRange.startIndex + sourceSplitRange.low.count).moveInitialize(from: sourceBody.advanced(by: sourceSplitRange.high.startIndex), count: sourceSplitRange.high.count)
  }
  
  fileprivate static func copyInitialize(preMappedSourceRange: CountableRange<Int>, postMappedDestinationRange: CountableRange<Int>, sourceHeader: UnsafeMutablePointer<DequeHeader>, sourceBody: UnsafeMutablePointer<T>, destinationBody: UnsafeMutablePointer<T>) {
    let sourceSplitRange = Deque.mapIndices(inRange: preMappedSourceRange, header: sourceHeader)
    
    assert(sourceSplitRange.low.startIndex >= 0 && (sourceSplitRange.low.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.low.startIndex == sourceSplitRange.low.endIndex))
    assert(sourceSplitRange.low.endIndex >= 0 && sourceSplitRange.low.endIndex <= sourceHeader.pointee.capacity)
    
    assert(sourceSplitRange.high.startIndex >= 0 && (sourceSplitRange.high.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.high.startIndex == sourceSplitRange.high.endIndex))
    assert(sourceSplitRange.high.endIndex >= 0 && sourceSplitRange.high.endIndex <= sourceHeader.pointee.capacity)
    
    destinationBody.advanced(by: postMappedDestinationRange.startIndex).initialize(from: sourceBody.advanced(by: sourceSplitRange.low.startIndex), count: sourceSplitRange.low.count)
    destinationBody.advanced(by: postMappedDestinationRange.startIndex + sourceSplitRange.low.count).initialize(from: sourceBody.advanced(by: sourceSplitRange.high.startIndex), count: sourceSplitRange.high.count)
  }
  
  fileprivate static func mapIndices(inRange: CountableRange<Int>, header: UnsafeMutablePointer<DequeHeader>) -> (low: CountableRange<Int>, high: CountableRange<Int>) {
    let limit = header.pointee.capacity - header.pointee.offset
    if inRange.startIndex >= limit {
      return (low: (inRange.startIndex - limit)..<(inRange.endIndex - limit), high: (inRange.endIndex - limit)..<(inRange.endIndex - limit))
    } else if inRange.endIndex > limit {
      return (low: (inRange.startIndex + header.pointee.offset)..<header.pointee.capacity, high: 0..<(inRange.endIndex - limit))
    }
    return (low: (inRange.startIndex + header.pointee.offset)..<(inRange.endIndex + header.pointee.offset), high: (inRange.endIndex + header.pointee.offset)..<(inRange.endIndex + header.pointee.offset))
  }
  
  private static func mutateWithoutReallocate<C>(info: DequeMutationInfo, elements newElements: C, header: UnsafeMutablePointer<DequeHeader>, body: UnsafeMutablePointer<T>) where C: Collection, C.Iterator.Element == T {
    if info.removed > 0 {
      Deque.deinitialize(range: info.start..<(info.start + info.removed), header: header, body: body)
    }
    
    if info.removed != info.inserted {
      if info.start < header.pointee.count - (info.start + info.removed) {
        let oldOffset = header.pointee.offset
        header.pointee.offset -= info.inserted - info.removed
        if header.pointee.offset < 0 {
          header.pointee.offset += header.pointee.capacity
        } else if header.pointee.offset >= header.pointee.capacity {
          header.pointee.offset -= header.pointee.capacity
        }
        let delta = oldOffset - header.pointee.offset
        if info.start != 0 {
          let destinationSplitIndices = Deque.mapIndices(inRange: 0..<info.start, header: header)
          let lowCount = destinationSplitIndices.low.count
          Deque.moveInitialize(preMappedSourceRange: delta..<(delta + lowCount), postMappedDestinationRange: destinationSplitIndices.low, sourceHeader: header, sourceBody: body, destinationBody: body)
          if lowCount != info.start {
            Deque.moveInitialize(preMappedSourceRange: (delta + lowCount)..<(info.start + delta), postMappedDestinationRange: destinationSplitIndices.high, sourceHeader: header, sourceBody: body, destinationBody: body)
          }
        }
      } else {
        if (info.start + info.removed) != header.pointee.count {
          let start = info.start + info.inserted
          let end = header.pointee.count - info.removed + info.inserted
          let destinationSplitIndices = Deque.mapIndices(inRange: start..<end, header: header)
          let lowCount = destinationSplitIndices.low.count
          Deque.moveInitialize(preMappedSourceRange: start..<(start + lowCount), postMappedDestinationRange: destinationSplitIndices.low, sourceHeader: header, sourceBody: body, destinationBody: body)
          if lowCount != end - start {
            Deque.moveInitialize(preMappedSourceRange: (start + lowCount)..<header.pointee.count, postMappedDestinationRange: destinationSplitIndices.high, sourceHeader: header, sourceBody: body, destinationBody: body)
          }
        }
      }
      header.pointee.count = header.pointee.count - info.removed + info.inserted
    }
    
    if info.inserted == 1, let e = newElements.first {
      if info.start >= header.pointee.capacity - header.pointee.offset {
        body.advanced(by: info.start - header.pointee.capacity + header.pointee.offset).initialize(to: e)
      } else {
        body.advanced(by: header.pointee.offset + info.start).initialize(to: e)
      }
    } else if info.inserted > 0 {
      let inserted = Deque.mapIndices(inRange: info.start..<(info.start + info.inserted), header: header)
      var iterator = newElements.makeIterator()
      for i in inserted.low {
        if let n = iterator.next() {
          body.advanced(by: i).initialize(to: n)
        }
      }
      for i in inserted.high {
        if let n = iterator.next() {
          body.advanced(by: i).initialize(to: n)
        }
      }
    }
  }
  
  private mutating func reallocateAndMutate<C>(info: DequeMutationInfo, elements newElements: C, header: UnsafeMutablePointer<DequeHeader>?, body: UnsafeMutablePointer<T>?, deletePrevious: Bool) where C: Collection, C.Iterator.Element == T {
    if info.newCount == 0 {
      buffer = nil
    } else {
      let newCapacity: Int
      let oldCapacity = header?.pointee.capacity ?? 0
      if info.newCount > oldCapacity || info.newCount <= oldCapacity / DequeDownsizeTriggerFactor {
        newCapacity = Swift.max(minCapacity, info.newCount * DequeOverAllocateFactor)
      } else {
        newCapacity = oldCapacity
      }
      
      let newBuffer = DequeBuffer<T>.create(capacity: newCapacity, count: info.newCount)
      if let headerPtr = header, let bodyPtr = body {
        if deletePrevious, info.removed > 0 {
          Deque.deinitialize(range: info.start..<(info.start + info.removed), header: headerPtr, body: bodyPtr)
        }
        
        let newBody = newBuffer.unsafeElements
        if info.start != 0 {
          if deletePrevious {
            Deque.moveInitialize(preMappedSourceRange: 0..<info.start, postMappedDestinationRange: 0..<info.start, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
          } else {
            Deque.copyInitialize(preMappedSourceRange: 0..<info.start, postMappedDestinationRange: 0..<info.start, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
          }
        }
        
        let oldCount = header?.pointee.count ?? 0
        if info.start + info.removed != oldCount {
          if deletePrevious {
            Deque.moveInitialize(preMappedSourceRange: (info.start + info.removed)..<oldCount, postMappedDestinationRange: (info.start + info.inserted)..<info.newCount, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
          } else {
            Deque.copyInitialize(preMappedSourceRange: (info.start + info.removed)..<oldCount, postMappedDestinationRange: (info.start + info.inserted)..<info.newCount, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
          }
        }
        
        if deletePrevious {
          headerPtr.pointee.count = 0
        }
      }
      
      if info.inserted > 0 {
        newBuffer.unsafeElements.advanced(by: info.start).initialize(from: newElements)
      }
      
      buffer = newBuffer
    }
  }
  
  mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Iterator.Element == T {
    precondition(subrange.lowerBound >= 0, "Subrange lowerBound is negative")
    
    if isKnownUniquelyReferenced(&buffer), let b = buffer {
      let (header, body) = (b.unsafeHeader, b.unsafeElements)
      let info = DequeMutationInfo(subrange: subrange, previousCount: header.pointee.count, insertedCount: numericCast(newElements.count))
      if info.newCount <= header.pointee.capacity && (info.newCount < minCapacity || info.newCount > header.pointee.capacity / DequeDownsizeTriggerFactor) {
        Deque.mutateWithoutReallocate(info: info, elements: newElements, header: header, body: body)
      } else {
        reallocateAndMutate(info: info, elements: newElements, header: header, body: body, deletePrevious: true)
      }
    } else if let b = buffer {
      let (header, body) = (b.unsafeHeader, b.unsafeElements)
      let info = DequeMutationInfo(subrange: subrange, previousCount: header.pointee.count, insertedCount: numericCast(newElements.count))
      reallocateAndMutate(info: info, elements: newElements, header: header, body: body, deletePrevious: false)
    } else {
      let info = DequeMutationInfo(subrange: subrange, previousCount: 0, insertedCount: numericCast(newElements.count))
      reallocateAndMutate(info: info, elements: newElements, header: nil, body: nil, deletePrevious: true)
    }
  }
}

struct DequeHeader {
  var offset: Int
  var count: Int
  var capacity: Int
}

struct DequeMutationInfo {
  let start: Int
  let removed: Int
  let inserted: Int
  let newCount: Int
  
  init(subrange: Range<Int>, previousCount: Int, insertedCount: Int) {
    precondition(subrange.upperBound <= previousCount, "Subrange upperBound is out of range")
    
    self.start = subrange.lowerBound
    self.removed = subrange.count
    self.inserted = insertedCount
    self.newCount = previousCount - self.removed + self.inserted
  }
}

final class DequeBuffer<T> {
  typealias ValueType = T
  
  class func create(capacity: Int, count: Int) -> DequeBuffer<T> {
    let p = ManagedBufferPointer<DequeHeader, T>(bufferClass: self, minimumCapacity: capacity) { buffer, capacityFunction in
      DequeHeader(offset: 0, count: count, capacity: capacity)
    }
    
    let result = unsafeDowncast(p.buffer, to: DequeBuffer<T>.self)
    
    assert(ManagedBufferPointer<DequeHeader, T>(unsafeBufferObject: result).withUnsafeMutablePointers { (header, body) in result.unsafeHeader == header && result.unsafeElements == body })
    
    return result
  }
  
  static var headerOffset: Int {
    return Int(roundUp(UInt(MemoryLayout<HeapObject>.size), toAlignment: MemoryLayout<DequeHeader>.alignment))
  }
  
  static var elementOffset: Int {
    return Int(roundUp(UInt(headerOffset) + UInt(MemoryLayout<DequeHeader>.size), toAlignment: MemoryLayout<T>.alignment))
  }
  
  var unsafeElements: UnsafeMutablePointer<T> {
    return Unmanaged<DequeBuffer<T>>.passUnretained(self).toOpaque().advanced(by: DequeBuffer<T>.elementOffset).assumingMemoryBound(to: T.self)
  }
  
  var unsafeHeader: UnsafeMutablePointer<DequeHeader> {
    return Unmanaged<DequeBuffer<T>>.passUnretained(self).toOpaque().advanced(by: DequeBuffer<T>.headerOffset).assumingMemoryBound(to: DequeHeader.self)
  }
  
  deinit {
    let h = unsafeHeader
    if h.pointee.count > 0 {
      Deque<T>.deinitialize(range: 0..<h.pointee.count, header: h, body: unsafeElements)
    }
  }
}

func roundUp(_ offset: UInt, toAlignment alignment: Int) -> UInt {
  let x = offset + UInt(bitPattern: alignment) &- 1
  return x & ~(UInt(bitPattern: alignment) &- 1)
}

struct HeapObject {
  let metadata: Int = 0
  let strongRefCount: UInt32 = 0
  let weakRefCount: UInt32 = 0
}
