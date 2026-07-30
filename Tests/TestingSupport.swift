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

  // MARK: Internal

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
        idGenerator: idGenerator,
        itemModels: itemModels,
        headerModel: nil,
        footerModel: nil,
        backgroundModel: nil,
        metrics: MagazineLayoutSectionMetrics.defaultSectionMetrics(
          forCollectionViewWidth: 320,
          scale: 1))
      sectionModels.append(sectionModel)
    }

    return sectionModels
  }

  static func basicItemModel() -> ItemModel {
    return ItemModel(
      idGenerator: idGenerator,
      sizeMode: MagazineLayoutItemSizeMode(
        widthMode: .fullWidth(respectsHorizontalInsets: true),
        heightMode: .static(height: 20)),
      height: 20)
  }

  // MARK: Private

  private static let idGenerator = IDGenerator()

}

// MARK: - Single section mutations

/// `MagazineLayout` mutates section models in place, through the `inout SectionModel` handed out by
/// `forEachSectionModel`, to avoid copy-on-write traffic. These helpers give tests that same access
/// one section at a time.
@available(iOS 18.0, *)
extension ModelState {

  func updateMetrics(
    to sectionMetrics: MagazineLayoutSectionMetrics,
    forSectionAtIndex sectionIndex: Int)
  {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      updateMetrics(
        to: sectionMetrics,
        forSectionAtIndex: sectionIndex,
        sectionModel: &sectionModel)
    }
  }

  func updateItemSizeModes(
    forSectionAtIndex sectionIndex: Int,
    sizeModeProvider: (_ itemIndex: Int) -> MagazineLayoutItemSizeMode)
  {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      updateItemSizeModes(
        forSectionAtIndex: sectionIndex,
        sectionModel: &sectionModel,
        sizeModeProvider: sizeModeProvider)
    }
  }

  func setHeader(_ headerModel: HeaderModel, forSectionAtIndex sectionIndex: Int) {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      setHeader(headerModel, forSectionAtIndex: sectionIndex, sectionModel: &sectionModel)
    }
  }

  func removeHeader(forSectionAtIndex sectionIndex: Int) {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      removeHeader(forSectionAtIndex: sectionIndex, sectionModel: &sectionModel)
    }
  }

  func setFooter(_ footerModel: FooterModel, forSectionAtIndex sectionIndex: Int) {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      setFooter(footerModel, forSectionAtIndex: sectionIndex, sectionModel: &sectionModel)
    }
  }

  func removeFooter(forSectionAtIndex sectionIndex: Int) {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      removeFooter(forSectionAtIndex: sectionIndex, sectionModel: &sectionModel)
    }
  }

  func setBackground(_ backgroundModel: BackgroundModel, forSectionAtIndex sectionIndex: Int) {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      setBackground(backgroundModel, forSectionAtIndex: sectionIndex, sectionModel: &sectionModel)
    }
  }

  func removeBackground(forSectionAtIndex sectionIndex: Int) {
    mutateSectionModel(atIndex: sectionIndex) { sectionIndex, sectionModel in
      removeBackground(forSectionAtIndex: sectionIndex, sectionModel: &sectionModel)
    }
  }

  // MARK: Private

  private func mutateSectionModel(
    atIndex index: Int,
    _ mutate: (_ sectionIndex: Int, _ sectionModel: inout SectionModel) -> Void)
  {
    forEachSectionModel { sectionIndex, sectionModel in
      guard sectionIndex == index else { return }
      mutate(sectionIndex, &sectionModel)
    }
  }

}

// MARK: - FrameHelpers

@available(iOS 18.0, *)
final class FrameHelpers {

  static func expectedFrames(
    _ expectedFrames: [CGRect],
    match elementLocationFramePairs: ElementLocationFramePairs)
    -> Bool
  {
    let expectedFrames = Set(expectedFrames)
    var checkedFramesCount = 0

    for elementLocationFramePair in elementLocationFramePairs {
      if !expectedFrames.contains(elementLocationFramePair.frame) {
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
    let expectedFrames = Set(expectedFrames)
    var checkedFramesCount = 0

    for sectionIndex in sectionIndexRange {
      for itemIndex in 0..<modelState.numberOfItems(inSectionAtIndex: sectionIndex) {
        let itemFrame = modelState.frameForItem(
          at: ElementLocation(elementIndex: itemIndex, sectionIndex: sectionIndex))
        if !expectedFrames.contains(itemFrame) {
          return false
        }

        checkedFramesCount += 1
      }
    }

    return checkedFramesCount == expectedFrames.count
  }

  static func expectedFrames(
    _ expectedFrames: [CGRect?],
    matchHeaderFramesInSectionIndexRange sectionIndexRange: Range<Int>,
    modelState: ModelState)
    -> Bool
  {
    var expectedFrameIndex = 0
    for sectionIndex in sectionIndexRange {
      let headerFrame = modelState.frameForHeader(inSectionAtIndex: sectionIndex)

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
    matchFooterFramesInSectionIndexRange sectionIndexRange: Range<Int>,
    modelState: ModelState)
    -> Bool
  {
    var expectedFrameIndex = 0
    for sectionIndex in sectionIndexRange {
      let footerFrame = modelState.frameForFooter(inSectionAtIndex: sectionIndex)

      guard footerFrame != nil else { continue }

      if
        expectedFrameIndex < expectedFrames.count &&
        expectedFrames[expectedFrameIndex] != footerFrame
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
      let backgroundFrame = modelState.frameForBackground(inSectionAtIndex: sectionIndex)

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

@available(iOS 18.0, *)
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

// MARK: - DebugHelpers

final class DebugHelpers {

  /// Only used while developing
  static func printExpectedFrameCodeToConsole(
    modelState: ModelState,
    visibleRect0: CGRect,
    visibleRect1: CGRect)
  {
    print("let expectedItemFrames0: [CGRect] = [")
    for pair in modelState.itemLocationFramePairs(forItemsIn: visibleRect0) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedItemFrames1: [CGRect] = [")
    for pair in modelState.itemLocationFramePairs(forItemsIn: visibleRect1) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedHeaderFrames0: [CGRect] = [")
    for pair in modelState.headerLocationFramePairs(forHeadersIn: visibleRect0) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedHeaderFrames1: [CGRect] = [")
    for pair in modelState.headerLocationFramePairs(forHeadersIn: visibleRect1) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedFooterFrames0: [CGRect] = [")
    for pair in modelState.footerLocationFramePairs(forFootersIn: visibleRect0) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedFooterFrames1: [CGRect] = [")
    for pair in modelState.footerLocationFramePairs(forFootersIn: visibleRect1) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedBackgroundFrames0: [CGRect] = [")
    for pair in modelState.backgroundLocationFramePairs(forBackgroundsIn: visibleRect0) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")

    print("let expectedBackgroundFrames1: [CGRect] = [")
    for pair in modelState.backgroundLocationFramePairs(forBackgroundsIn: visibleRect1) {
      print("\tCGRect(x: \(pair.frame.minX), y: \(pair.frame.minY), width: \(pair.frame.width), height: \(pair.frame.height)),")
    }
    print("]")
  }

}
