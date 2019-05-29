// Created by bryankeller on 5/23/19.
// Copyright © 2019 Airbnb, Inc.

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

/// Tracks offsets for rows using a Segment Tree for O(log n) lookups and updates.
struct RowOffsetTracker {

  // MARK: Lifecycle

  init(numberOfRows: Int) {
    self.numberOfRows = numberOfRows

    rowOffsets = Array(repeating: 0, count: 2 * numberOfRows)
  }

  // MARK: Internal

  mutating func addOffset(_ offset: CGFloat, forRowsStartingAt rowIndex: Int) {
    var rowIndex = rowIndex + numberOfRows

    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / release calls.
    let rowOffsetsPointer = UnsafeMutableRawPointer(mutating: &rowOffsets)
    let directlyMutableRowOffsets = rowOffsetsPointer.assumingMemoryBound(to: CGFloat.self)
    directlyMutableRowOffsets[rowIndex] = rowOffsets[rowIndex] + offset

    while rowIndex > 1 {
      rowIndex /= 2

      let leftChild = rowOffsets[2 * rowIndex]
      let rightChild = rowOffsets[(2 * rowIndex) + 1]
      directlyMutableRowOffsets[rowIndex] = leftChild + rightChild
    }
  }

  func offsetForRow(at rowIndex: Int) -> CGFloat {
    var lowerBound = numberOfRows
    var upperBound = rowIndex + numberOfRows + 1

    var offset = CGFloat(0)

    while lowerBound < upperBound {
      if lowerBound % 2 != 0 {
        offset += rowOffsets[lowerBound]
        lowerBound += 1
      }

      if upperBound % 2 != 0 {
        upperBound -= 1
        offset += rowOffsets[upperBound]
      }

      lowerBound /= 2
      upperBound /= 2
    }

    return offset
  }

  // MARK: Private

  private let numberOfRows: Int

  private var rowOffsets: [CGFloat]

}
