// Created by bryankeller on 7/9/17.
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
import Foundation

/// Represents the layout information for a section.
struct SectionModel {

  // MARK: Lifecycle

  init(
    itemModels: [ItemModel],
    headerModel: HeaderModel?,
    backgroundModel: BackgroundModel?,
    metrics: MagazineLayoutSectionMetrics)
  {
    id = NSUUID().uuidString
    self.itemModels = itemModels
    self.headerModel = headerModel
    self.backgroundModel = backgroundModel
    self.metrics = metrics
    calculatedHeight = 0

    indexOfFirstInvalidatedItem = 0

    recomputeItemPositionsIfNecessary()
  }

  // MARK: Internal

  let id: String

  private(set) var headerModel: HeaderModel?

  var numberOfItems: Int {
    return itemModels.count
  }

  func idForItemModel(atIndex index: Int) -> String {
    return itemModels[index].id
  }

  func indexForItemModel(withID id: String) -> Int? {
    return itemModels.index { $0.id == id }
  }

  func itemModel(atIndex index: Int) -> ItemModel {
    return itemModels[index]
  }

  func preferredHeightForItemModel(atIndex index: Int) -> CGFloat? {
    return itemModels[index].preferredHeight
  }

  mutating func calculateHeight() -> CGFloat {
    recomputeItemPositionsIfNecessary()
    return calculatedHeight
  }

  mutating func calculateFrameForHeader() -> CGRect? {
    guard let headerModel = headerModel else { return nil }

    if
      let indexOfFirstInvalidatedItem = indexOfFirstInvalidatedItem,
      indexOfFirstInvalidatedItem <= 0
    {
      recomputeItemPositionsIfNecessary()
    }

    return CGRect(
      origin: CGPoint(x: headerModel.originInSection.x, y: headerModel.originInSection.y),
      size: headerModel.size)
  }

  mutating func calculateFrameForBackground() -> CGRect? {
    guard let backgroundModel = backgroundModel else { return nil }

    if indexOfFirstInvalidatedItem != nil {
      recomputeItemPositionsIfNecessary()
    }

    return CGRect(
      origin: CGPoint(x: backgroundModel.originInSection.x, y: backgroundModel.originInSection.y),
      size: backgroundModel.size)
  }

  mutating func calculateFrameForItem(atIndex itemIndex: Int) -> CGRect {
    if
      let indexOfFirstInvalidatedItem = indexOfFirstInvalidatedItem,
      indexOfFirstInvalidatedItem <= itemIndex
    {
      recomputeItemPositionsIfNecessary()
    }

    return frameForItem(atIndex: itemIndex)
  }

  @discardableResult
  mutating func deleteItemModel(atIndex indexOfDeletion: Int) -> ItemModel {
    let deletedItemModel = itemModels.remove(at: indexOfDeletion)

    updateIndexOfFirstInvalidatedItem(forChangeToItemAtIndex: indexOfDeletion)

    return deletedItemModel
  }

  mutating func insert(_ itemModel: ItemModel, atIndex indexOfInsertion: Int) {
    itemModels.insert(itemModel, at: indexOfInsertion)

    updateIndexOfFirstInvalidatedItem(forChangeToItemAtIndex: indexOfInsertion)
  }

  mutating func updateMetrics(to metrics: MagazineLayoutSectionMetrics) {
    guard self.metrics != metrics else { return }

    self.metrics = metrics

    indexOfFirstInvalidatedItem = 0
  }

  mutating func updateItemSizeMode(to sizeMode: MagazineLayoutItemSizeMode, atIndex index: Int) {
    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / releases calls.
    let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
    let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(
      to: ItemModel.self)

    directlyMutableItemModels[index].sizeMode = sizeMode

    if case let .static(staticHeight) = sizeMode.heightMode {
      directlyMutableItemModels[index].size.height = staticHeight
    }

    updateIndexOfFirstInvalidatedItem(forChangeToItemAtIndex: index)
  }

  mutating func updateItemHeight(
    toPreferredHeight preferredHeight: CGFloat,
    atIndex index: Int)
  {
    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / releases calls.
    let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
    let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(
      to: ItemModel.self)

    directlyMutableItemModels[index].preferredHeight = preferredHeight

    updateIndexOfFirstInvalidatedItem(forChangeToItemAtIndex: index)
  }

  mutating func setHeader(_ headerModel: HeaderModel) {
    let oldPreferredHeight = self.headerModel?.preferredHeight
    self.headerModel = headerModel

    if case let .static(staticHeight) = headerModel.heightMode {
      self.headerModel?.size.height = staticHeight
    } else if case .dynamic = headerModel.heightMode {
      self.headerModel?.preferredHeight = oldPreferredHeight
    }

    indexOfFirstInvalidatedItem = 0
  }

  mutating func removeHeader() {
    headerModel = nil

    indexOfFirstInvalidatedItem = 0
  }

  mutating func updateHeaderHeight(toPreferredHeight preferredHeight: CGFloat) {
    headerModel?.preferredHeight = preferredHeight

    indexOfFirstInvalidatedItem = 0
  }

  mutating func setBackground(_ backgroundModel: BackgroundModel) {
    self.backgroundModel = backgroundModel

    indexOfFirstInvalidatedItem = 0
  }

  mutating func removeBackground() {
    backgroundModel = nil
  }

  // MARK: Private

  private var itemModels: [ItemModel]
  private var backgroundModel: BackgroundModel?
  private var metrics: MagazineLayoutSectionMetrics
  private var calculatedHeight: CGFloat
  private var indexOfFirstInvalidatedItem: Int?

  private mutating func updateIndexOfFirstInvalidatedItem(
    forChangeToItemAtIndex changedIndex: Int)
  {
    guard changedIndex > 0 else {
      indexOfFirstInvalidatedItem = changedIndex
      return
    }

    let candidateFirstAffectedIndex = min(itemModels.count - 1, changedIndex)

    let indexRangeOfItemsInSameRow = indexRangeOfItemsInSameRowAsItem(
      atIndex: candidateFirstAffectedIndex)
    var rowContainsStretchToTallestItemInRowItem = false
    for index in indexRangeOfItemsInSameRow {
      if itemModels[index].sizeMode.heightMode == .dynamicAndStretchToTallestItemInRow {
        rowContainsStretchToTallestItemInRowItem = true
        break
      }
    }

    let indexOfFirstInvalidatedItemForChangedIndex: Int
    if rowContainsStretchToTallestItemInRowItem {
      indexOfFirstInvalidatedItemForChangedIndex = indexRangeOfItemsInSameRow.lowerBound
    } else {
      indexOfFirstInvalidatedItemForChangedIndex = candidateFirstAffectedIndex
    }

    indexOfFirstInvalidatedItem = min(
      indexOfFirstInvalidatedItemForChangedIndex,
      indexOfFirstInvalidatedItem ?? indexOfFirstInvalidatedItemForChangedIndex)
  }

  private func indexRangeOfItemsInSameRowAsItem(atIndex index: Int) -> CountableClosedRange<Int> {
    guard index >= 0 && index < itemModels.count else {
      preconditionFailure("Cannot invoke `indexRangeOfItemsInSameRowAsItem(atIndex:)` with an out-of-bounds index")
    }

    let rowWidthMode = itemModels[index].sizeMode.widthMode

    // Find row start
    var backwardTraversingIndex = index
    while
      backwardTraversingIndex > 0 &&
      itemModels[backwardTraversingIndex - 1].sizeMode.widthMode == rowWidthMode
    {
      backwardTraversingIndex -= 1
    }

    let numberOfPreceedingConsecutiveSameWidthModeItems = index - backwardTraversingIndex
    let rowStartIndex = index - (numberOfPreceedingConsecutiveSameWidthModeItems % Int(rowWidthMode.widthDivisor))

    // Find row end
    var forwardTraversingIndex = index
    while
      forwardTraversingIndex + 1 < rowStartIndex + Int(rowWidthMode.widthDivisor) &&
      forwardTraversingIndex + 1 < itemModels.count &&
      itemModels[forwardTraversingIndex + 1].sizeMode.widthMode == rowWidthMode
    {
      forwardTraversingIndex += 1
    }

    return rowStartIndex...forwardTraversingIndex
  }

  private func frameForItem(atIndex itemIndex: Int) -> CGRect {
    let itemModel = itemModels[itemIndex]

    return CGRect(
      origin: CGPoint(
        x: itemModel.originInSection.x,
        y: itemModel.originInSection.y),
      size: itemModel.size)
  }

  private mutating func recomputeItemPositionsIfNecessary() {
    guard let startingIndex = indexOfFirstInvalidatedItem else { return }
    indexOfFirstInvalidatedItem = nil

    guard startingIndex >= 0 && startingIndex <= itemModels.count else {
      assertionFailure("Invalid `startingIndex` / `indexOfFirstInvalidatedItem` (\(startingIndex)).")
      return
    }

    var currentY = CGFloat(0)

    // Section header calculation if rebuilding entire section
    if var newHeaderItemModel = headerModel, startingIndex == 0 {
      newHeaderItemModel.originInSection = .zero
      newHeaderItemModel.size.width = metrics.width
      newHeaderItemModel.size.height = newHeaderItemModel.preferredHeight ?? newHeaderItemModel.size.height
      headerModel = newHeaderItemModel
      currentY += newHeaderItemModel.size.height
    }

    // Apply top item inset now that we're laying out items
    currentY += metrics.itemInsets.top

    var indexInCurrentRow = 0
    var stretchToTallestItemInRowItemIndicesInCurrentRow = Set<Int>()
    var heightOfTallestItemInCurrentRow = CGFloat(0)
    var previousWidthMode: MagazineLayoutItemWidthMode?

    // Initial calculations for rebuilding from a `startingIndex` > 0
    // This is where we find the item preceding `startingIndex` that sets our `currentY`.
    if startingIndex > 0 {
      let itemModelsBeforeStartingIndex = itemModels.prefix(startingIndex).reversed()

      let startingItemWidthMode = itemModels[startingIndex].sizeMode.widthMode
      previousWidthMode = itemModels[startingIndex - 1].sizeMode.widthMode

      var consecutiveSameItemWidthModes = 0
      for itemModel in itemModelsBeforeStartingIndex {
        guard itemModel.sizeMode.widthMode == startingItemWidthMode else { break }
        consecutiveSameItemWidthModes += 1
      }

      indexInCurrentRow = consecutiveSameItemWidthModes % Int(startingItemWidthMode.widthDivisor) - 1
      if indexInCurrentRow + 1 > 0 {
        // This is an item added to an existing row, so our `currentY` is just the preceding item's
        // `minY`.
        currentY = frameForItem(atIndex: startingIndex - 1).minY
      }
      else {
        // This is the start of a new row, so our `currentY` is the `maxY` of the items in the
        // preceding row. Vertical row padding is added in later.
        let widthModeForItemsInPreviousRow = itemModels[startingIndex - 1].sizeMode.widthMode

        let numberOfItemsToConsiderInPreviousRow = min(
          Int(widthModeForItemsInPreviousRow.widthDivisor),
          itemModelsBeforeStartingIndex.count)

        let itemsToConsiderInPreviousRow = itemModelsBeforeStartingIndex.prefix(
          numberOfItemsToConsiderInPreviousRow)

        for itemModel in itemsToConsiderInPreviousRow {
          let precedingItemMaxY = itemModel.originInSection.y + itemModel.size.height
          currentY = max(currentY, precedingItemMaxY)
        }
      }
    }

    var currentHeight = currentY

    // Item calculations
    for itemIndex in startingIndex..<itemModels.count {
      let itemModel = itemModels[itemIndex]

      // Keep adding to the same row if we're the same width mode as the previous item and we're
      // not at the end of a row
      if
        indexInCurrentRow >= 0,
        let previousWidthMode = previousWidthMode,
        itemModel.sizeMode.widthMode == previousWidthMode &&
        indexInCurrentRow < Int(itemModel.sizeMode.widthMode.widthDivisor - 1)
      {
        indexInCurrentRow += 1
      }
      else {
        indexInCurrentRow = 0
        currentY = currentHeight
        heightOfTallestItemInCurrentRow = 0

        stretchToTallestItemInRowItemIndicesInCurrentRow.removeAll()

        // If this isn't the first row, then add row spacing to our y offset
        if itemIndex > 0 {
          currentY += metrics.verticalSpacing
        }
      }

      let currentLeadingMargin: CGFloat
      let availableWidth: CGFloat
      if itemModel.sizeMode.widthMode == .fullWidth(respectsHorizontalInsets: false) {
        currentLeadingMargin = 0
        availableWidth = metrics.width
      } else {
        currentLeadingMargin = metrics.itemInsets.left
        availableWidth = metrics.width - metrics.itemInsets.left - metrics.itemInsets.right
      }

      let totalSpacing = metrics.horizontalSpacing * (itemModel.sizeMode.widthMode.widthDivisor - 1)
      let itemWidth = ((availableWidth - totalSpacing) / itemModel.sizeMode.widthMode.widthDivisor).rounded()

      let itemX = CGFloat(indexInCurrentRow) * itemWidth +
        CGFloat(indexInCurrentRow) * metrics.horizontalSpacing +
        currentLeadingMargin
      let itemY = currentY

      // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
      // and Swift retain / releases calls.
      let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
      let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(
        to: ItemModel.self)

      directlyMutableItemModels[itemIndex].originInSection = CGPoint(x: itemX, y: itemY)
      directlyMutableItemModels[itemIndex].size.width = itemWidth
      directlyMutableItemModels[itemIndex].size.height = itemModel.preferredHeight ?? itemModel.size.height

      // Handle stretch to tallest item in row height mode for current row
      if itemModel.sizeMode.heightMode == .dynamicAndStretchToTallestItemInRow {
        stretchToTallestItemInRowItemIndicesInCurrentRow.insert(itemIndex)
      }

      heightOfTallestItemInCurrentRow = max(
        heightOfTallestItemInCurrentRow,
        itemModels[itemIndex].size.height)

      for stretchToTallestItemInRowItemIndex in stretchToTallestItemInRowItemIndicesInCurrentRow {
        directlyMutableItemModels[stretchToTallestItemInRowItemIndex].size.height = heightOfTallestItemInCurrentRow
      }

      // Update previous width mode
      previousWidthMode = itemModel.sizeMode.widthMode

      // Update current height
      currentHeight = max(currentHeight, itemY + heightOfTallestItemInCurrentRow)
    }

    // Update the current caluclated height
    let totalHeight = currentHeight + metrics.itemInsets.bottom
    calculatedHeight = totalHeight

    // Update the background item
    backgroundModel?.originInSection = .zero
    backgroundModel?.size.width = metrics.width
    backgroundModel?.size.height = totalHeight
  }

}
