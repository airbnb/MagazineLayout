// Created by bryankeller on 11/12/18.
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

import UIKit

@testable import MagazineLayout

// MARK: - ModelHelpers

final class ModelHelpers {

  static func basicSectionModels(
    numberOfSections: UInt,
    numberOfItemsPerSection: UInt)
    -> [SectionModel]
  {
    var sectionModels = [SectionModel]()

    for _ in 0..<numberOfSections {
      var itemModels = [ItemModel]()
      for _ in 0..<numberOfItemsPerSection {
        itemModels.append(basicItemModel())
      }

      let sectionModel = SectionModel(
        itemModels: itemModels,
        headerModel: nil,
        backgroundModel: nil,
        metrics: MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 320))
      sectionModels.append(sectionModel)
    }

    return sectionModels
  }

  static func basicItemModel() -> ItemModel {
    return ItemModel(
      sizeMode: MagazineLayoutItemSizeMode(
        widthMode: .fullWidth(respectsHorizontalInsets: true),
        heightMode: .static(height: 20)),
      height: 20)
  }

}

// MARK: - FrameHelpers

final class FrameHelpers {

  static func expectedFrames(
    _ expectedFrames: [CGRect],
    match elementLocationFramePairs: ElementLocationFramePairs)
    -> Bool
  {
    var checkedFramesCount = 0

    for (i, elementLocationFramePair) in elementLocationFramePairs.enumerated() {
      if i < expectedFrames.count && expectedFrames[i] != elementLocationFramePair.frame {
        return false
      }

      checkedFramesCount += 1
    }

    return checkedFramesCount == expectedFrames.count
  }

  static func expectedFrames(
    _ expectedFrames: [CGRect],
    matchItemFramesInSectionIndexRange sectionIndexRange: Range<Int>,
    modelState: ModelState)
    -> Bool
  {
    var expectedFrameIndex = 0
    for sectionIndex in sectionIndexRange {
      for itemIndex in 0..<modelState.numberOfItems(inSectionAtIndex: sectionIndex, .afterUpdates) {
        let itemFrame = modelState.frameForItem(
          at: ElementLocation(elementIndex: itemIndex, sectionIndex: sectionIndex),
          .afterUpdates)
        if
          expectedFrameIndex < expectedFrames.count &&
          expectedFrames[expectedFrameIndex] != itemFrame
        {
          return false
        }

        expectedFrameIndex += 1
      }
    }

    return true
  }

  static func expectedFrames(
    _ expectedFrames: [CGRect?],
    matchHeaderFramesInSectionIndexRange sectionIndexRange: Range<Int>,
    modelState: ModelState)
    -> Bool
  {
    var expectedFrameIndex = 0
    for sectionIndex in sectionIndexRange {
      let headerFrame = modelState.frameForHeader(inSectionAtIndex: sectionIndex, .afterUpdates)

      guard headerFrame != nil else { continue }

      if
        expectedFrameIndex < expectedFrames.count &&
        expectedFrames[expectedFrameIndex] != headerFrame
      {
        return false
      }

      expectedFrameIndex += 1
    }

    return true
  }

  static func expectedFrames(
    _ expectedFrames: [CGRect?],
    matchBackgroundFramesInSectionIndexRange sectionIndexRange: Range<Int>,
    modelState: ModelState)
    -> Bool
  {
    var expectedFrameIndex = 0
    for sectionIndex in sectionIndexRange {
      let backgroundFrame = modelState.frameForBackground(
        inSectionAtIndex: sectionIndex,
        .afterUpdates)

      guard backgroundFrame != nil else { continue }

      if
        expectedFrameIndex < expectedFrames.count &&
        expectedFrames[expectedFrameIndex] != backgroundFrame
      {
        return false
      }

      expectedFrameIndex += 1
    }

    return true
  }

}

// MARK: - Remove duplicates

extension Array where Element == CGRect {

  func removingDuplicates() -> [Element] {
    var newArray = [Element]()

    var seenElements = Set<Element>()
    for element in self {
      guard !seenElements.contains(element) else { continue }

      newArray.append(element)
      seenElements.insert(element)
    }

    return newArray
  }

}

// MARK: Hashable

extension CGRect: Hashable {

  public var hashValue: Int {
    return NSCoder.string(for: self).hashValue
  }

}

// MARK: - DebugHelpers

final class DebugHelpers {

  /// Only used while developing
  static func printExpectedFrameCodeToConsole(
    modelState: ModelState,
    visibleRect0: CGRect,
    visibleRect1: CGRect)
  {
    print("let expectedItemFrames0: [CGRect] = [")
    for foo in modelState.itemFrameInfo(forItemsIn: visibleRect0) {
      print("\tCGRect(x: \(foo.frame.minX), y: \(foo.frame.minY), width: \(foo.frame.width), height: \(foo.frame.height)),")
    }
    print("]")

    print("let expectedItemFrames1: [CGRect] = [")
    for foo in modelState.itemFrameInfo(forItemsIn: visibleRect1) {
      print("\tCGRect(x: \(foo.frame.minX), y: \(foo.frame.minY), width: \(foo.frame.width), height: \(foo.frame.height)),")
    }
    print("]")

    print("let expectedHeaderFrames0: [CGRect] = [")
    for foo in modelState.headerFrameInfo(forHeadersIn: visibleRect0) {
      print("\tCGRect(x: \(foo.frame.minX), y: \(foo.frame.minY), width: \(foo.frame.width), height: \(foo.frame.height)),")
    }
    print("]")

    print("let expectedHeaderFrames1: [CGRect] = [")
    for foo in modelState.headerFrameInfo(forHeadersIn: visibleRect1) {
      print("\tCGRect(x: \(foo.frame.minX), y: \(foo.frame.minY), width: \(foo.frame.width), height: \(foo.frame.height)),")
    }
    print("]")

    print("let expectedBackgroundFrames0: [CGRect] = [")
    for foo in modelState.backgroundFrameInfo(forBackgroundsIn: visibleRect0) {
      print("\tCGRect(x: \(foo.frame.minX), y: \(foo.frame.minY), width: \(foo.frame.width), height: \(foo.frame.height)),")
    }
    print("]")

    print("let expectedBackgroundFrames1: [CGRect] = [")
    for foo in modelState.backgroundFrameInfo(forBackgroundsIn: visibleRect1) {
      print("\tCGRect(x: \(foo.frame.minX), y: \(foo.frame.minY), width: \(foo.frame.width), height: \(foo.frame.height)),")
    }
    print("]")
  }

}
