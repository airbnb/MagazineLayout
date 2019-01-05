// Created by bryankeller on 8/17/18.
// Copyright © 2018 Airbnb, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CoreGraphics

// MARK: - ElementLocationFramePairs

/// Stores pairs of `ElementLocationFramePair`s in an efficient way for appending to and
/// iterating over.
///
/// The main reason this exists (and why its implementation uses a singly-linked-list) is so that,
/// as we find the section and item index and frame for an element in a visible rect, we can append
/// it to this data structure without copy-on-write performance issues, or array buffer resizing
/// issues. (The cost of appending to an array is much more expensive due to copy-on-write and the
/// backing buffer needing to be resized).
struct ElementLocationFramePairs {

  // MARK: Lifecycle

  init() { }

  init(elementLocationFramePair: ElementLocationFramePair) {
    append(elementLocationFramePair)
  }

  // MARK: Internal

  mutating func append(_ elementLocationFramePair: ElementLocationFramePair) {
    if first == nil {
      first = elementLocationFramePair
    } else {
      last.next = elementLocationFramePair
    }

    last = elementLocationFramePair
  }

  // MARK: Fileprivate

  fileprivate var first: ElementLocationFramePair?

  // MARK: Private

  private var last: ElementLocationFramePair!

}

// MARK: Sequence

extension ElementLocationFramePairs: Sequence {

  func makeIterator() -> ElementLocationFramePairsIterator {
    return ElementLocationFramePairsIterator(self)
  }

}

// MARK: - ElementLocationFramePairsIterator

/// Used for iterating through `ElementLocationFramePairs` instances
struct ElementLocationFramePairsIterator: IteratorProtocol {

  typealias Element = ElementLocationFramePair

  // MARK: Lifecycle

  init(_ elementLocationFramePairs: ElementLocationFramePairs) {
    self.elementLocationFramePairs = elementLocationFramePairs
  }

  // MARK: Internal

  mutating func next() -> ElementLocationFramePair? {
    if lastReturnedElement == nil {
      lastReturnedElement = elementLocationFramePairs.first
    } else {
      lastReturnedElement = lastReturnedElement?.next
    }

    return lastReturnedElement
  }

  // MARK: Private

  private let elementLocationFramePairs: ElementLocationFramePairs

  private var lastReturnedElement: ElementLocationFramePair?

}

// MARK: - ElementLocationFramePair

/// Encapsulates a `ElementLocation` and a `CGRect` frame for an element.
final class ElementLocationFramePair {

  // MARK: Lifecycle

  init(elementLocation: ElementLocation, frame: CGRect) {
    self.elementLocation = elementLocation
    self.frame = frame
  }

  // MARK: Internal

  let elementLocation: ElementLocation
  let frame: CGRect

  // MARK: Fileprivate

  fileprivate var next: ElementLocationFramePair?

}

// MARK: Equatable

extension ElementLocationFramePair: Equatable {

  static func == (lhs: ElementLocationFramePair, rhs: ElementLocationFramePair) -> Bool {
    return lhs.elementLocation == rhs.elementLocation && lhs.frame == rhs.frame
  }

}
