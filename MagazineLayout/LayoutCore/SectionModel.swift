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
    footerModel: FooterModel?,
    backgroundModel: BackgroundModel?,
    metrics: MagazineLayoutSectionMetrics)
  {
    id = NSUUID().uuidString
    self.itemModels = itemModels
    self.headerModel = headerModel
    self.footerModel = footerModel
    self.backgroundModel = backgroundModel
    self.metrics = metrics
    calculatedHeight = 0

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: 0)
    calculateElementFramesIfNecessary()
  }

  // MARK: Internal

  let id: String

  private(set) var headerModel: HeaderModel?
  private(set) var footerModel: FooterModel?
  private(set) var backgroundModel: BackgroundModel?

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
    calculateElementFramesIfNecessary()
    return calculatedHeight
  }

  mutating func calculateFrameForHeader() -> CGRect? {
    guard headerModel != nil else { return nil }

    calculateElementFramesIfNecessary()

    // `headerModel` is a value type that might be mutated in `recomputeItemPositionsIfNecessary`,
    // so we can't use a copy made before that code executes (for example, in a
    // `guard let headerModel = headerModel else { ... }` at the top of this function).
    if let headerModel = headerModel {
      return CGRect(
        origin: CGPoint(x: headerModel.originInSection.x, y: headerModel.originInSection.y),
        size: headerModel.size)
    } else {
      return nil
    }
  }

  mutating func calculateFrameForFooter() -> CGRect? {
    guard footerModel != nil else { return nil }

    calculateElementFramesIfNecessary()

    // `footerModel` is a value type that might be mutated in `recomputeItemPositionsIfNecessary`,
    // so we can't use a copy made before that code executes (for example, in a
    // `guard let footerModel = footerModel else { ... }` at the top of this function).
    if let footerModel = footerModel {
      return CGRect(
        origin: CGPoint(x: footerModel.originInSection.x, y: footerModel.originInSection.y),
        size: footerModel.size)
    } else {
      return nil
    }
  }

  mutating func calculateFrameForBackground() -> CGRect? {
    guard backgroundModel != nil else { return nil }

    calculateElementFramesIfNecessary()

    // `backgroundModel` is a value type that might be mutated in
    // `recomputeItemPositionsIfNecessary`, so we can't use a copy made before that code executes
    // (for example, in a `guard let backgroundModel = backgroundModel else { ... }` at the top of
    // this function).
    if let backgroundModel = backgroundModel {
      return CGRect(
        origin: CGPoint(x: backgroundModel.originInSection.x, y: backgroundModel.originInSection.y),
        size: backgroundModel.size)
    } else {
      return nil
    }
  }

  mutating func calculateFrameForItem(atIndex itemIndex: Int) -> CGRect {
    calculateElementFramesIfNecessary()

    return frameForItem(atIndex: itemIndex)
  }

  @discardableResult
  mutating func deleteItemModel(atIndex indexOfDeletion: Int) -> ItemModel {
    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: indexOfDeletion)

    return itemModels.remove(at: indexOfDeletion)
  }

  mutating func insert(_ itemModel: ItemModel, atIndex indexOfInsertion: Int) {
    itemModels.insert(itemModel, at: indexOfInsertion)

    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: indexOfInsertion)
  }

  mutating func updateMetrics(to metrics: MagazineLayoutSectionMetrics) {
    guard self.metrics != metrics else { return }

    self.metrics = metrics

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: 0)
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

    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: index)
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

    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: index)
  }

  mutating func setHeader(_ headerModel: HeaderModel) {
    let oldPreferredHeight = self.headerModel?.preferredHeight
    self.headerModel = headerModel

    if case let .static(staticHeight) = headerModel.heightMode {
      self.headerModel?.size.height = staticHeight
    } else if case .dynamic = headerModel.heightMode {
      self.headerModel?.preferredHeight = oldPreferredHeight
    }

    if let indexOfHeader = indexOfHeaderRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfHeader)
    }
  }

  mutating func setFooter(_ footerModel: FooterModel) {
    let oldPreferredHeight = self.footerModel?.preferredHeight
    self.footerModel = footerModel

    if case let .static(staticHeight) = footerModel.heightMode {
      self.footerModel?.size.height = staticHeight
    } else if case .dynamic = footerModel.heightMode {
      self.footerModel?.preferredHeight = oldPreferredHeight
    }

    if let indexOfFooter = indexOfFooterRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfFooter)
    }
  }

  mutating func removeHeader() {
    if let indexOfHeader = indexOfHeaderRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfHeader)
    }

    headerModel = nil
  }

  mutating func removeFooter() {
    if let indexOfFooter = indexOfFooterRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfFooter)
    }

    footerModel = nil
  }

  mutating func updateHeaderHeight(toPreferredHeight preferredHeight: CGFloat) {
    headerModel?.preferredHeight = preferredHeight

    if let indexOfHeader = indexOfHeaderRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfHeader)
    }
  }

  mutating func updateFooterHeight(toPreferredHeight preferredHeight: CGFloat) {
    footerModel?.preferredHeight = preferredHeight

    if let indexOfFooter = indexOfFooterRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfFooter)
    }
  }

  mutating func setBackground(_ backgroundModel: BackgroundModel) {
    self.backgroundModel = backgroundModel

    let indexOfLastRow = indexOfFooterRow() ?? indexOfLastItemsRow() ?? indexOfHeaderRow() ?? -1
    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfLastRow + 1)
  }

  mutating func removeBackground() {
    backgroundModel = nil
    // No need to invalidate since no frames will be adjusted
  }

  // MARK: Private

  private var itemModels: [ItemModel]
  private var metrics: MagazineLayoutSectionMetrics
  private var calculatedHeight: CGFloat

  private var indexOfFirstInvalidatedRow: Int?
  private var itemIndicesForRowIndices = [Int: [Int]]()
  private var rowIndicesForItemIndices = [Int: Int]()

  private mutating func updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex changedIndex: Int) {
    guard
      let indexOfCurrentRow = rowIndicesForItemIndices[changedIndex],
      indexOfCurrentRow > 0 else
    {
      indexOfFirstInvalidatedRow = rowIndicesForItemIndices[0] ?? 0
      return
    }

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfCurrentRow - 1)
  }

  private mutating func updateIndexOfFirstInvalidatedRowIfNecessary(
    toProposedIndex proposedIndex: Int)
  {
    indexOfFirstInvalidatedRow = min(proposedIndex, indexOfFirstInvalidatedRow ?? proposedIndex)
  }

  private func maxYForItemsRow(atIndex rowIndex: Int) -> CGFloat? {
    guard
      let itemIndices = itemIndicesForRowIndices[rowIndex],
      let itemY = itemIndices.first.flatMap({ itemModels[$0].originInSection.y }),
      let itemHeight = itemIndices.map({ itemModels[$0].size.height }).max() else
    {
      return nil
    }

    return itemY + itemHeight
  }

  private func indexOfHeaderRow() -> Int? {
    guard headerModel != nil else { return nil }
    return 0
  }

  private func indexOfFirstItemsRow() -> Int? {
    guard numberOfItems > 0 else { return nil }
    return headerModel == nil ? 0 : 1
  }

  private func indexOfLastItemsRow() -> Int? {
    guard numberOfItems > 0 else { return nil }
    return rowIndicesForItemIndices[numberOfItems - 1]
  }

  private func indexOfFooterRow() -> Int? {
    guard footerModel != nil else { return nil }
    return (indexOfLastItemsRow() ?? indexOfHeaderRow() ?? -1) + 1
  }

  private func frameForItem(atIndex itemIndex: Int) -> CGRect {
    let itemModel = itemModels[itemIndex]

    return CGRect(
      origin: CGPoint(
        x: itemModel.originInSection.x,
        y: itemModel.originInSection.y),
      size: itemModel.size)
  }

  private mutating func calculateElementFramesIfNecessary() {
    guard var rowIndex = indexOfFirstInvalidatedRow else { return }
    guard rowIndex >= 0 else {
      assertionFailure("Invalid `rowIndex` / `indexOfFirstInvalidatedRow` (\(rowIndex)).")
      return
    }

    // Clean up item / row index mappings starting at our `indexOfFirstInvalidatedRow`; we'll make
    // new mappings for those row indices as we do layout calculations below. Since all item / row
    // index mappings before `indexOfFirstInvalidatedRow` are still valid, we'll leave those alone.
    for rowIndexKey in itemIndicesForRowIndices.keys {
      guard rowIndexKey >= rowIndex else { continue }

      if let itemIndex = itemIndicesForRowIndices[rowIndexKey]?.first {
        rowIndicesForItemIndices[itemIndex] = nil
      }

      itemIndicesForRowIndices[rowIndexKey] = nil
    }

    // Header frame calculation
    if rowIndex == indexOfHeaderRow(), var newHeaderItemModel = headerModel {
      newHeaderItemModel.originInSection = CGPoint(
        x: metrics.sectionInsets.left,
        y: metrics.sectionInsets.top)
      newHeaderItemModel.size.width = metrics.width
      newHeaderItemModel.size.height = newHeaderItemModel.preferredHeight ?? newHeaderItemModel.size.height
      headerModel = newHeaderItemModel

      rowIndex = 1
    }

    var currentY: CGFloat

    // Item frame calculations

    let startingItemIndex: Int
    if
      let indexOfLastItemInPreviousRow = itemIndicesForRowIndices[rowIndex - 1]?.last,
      indexOfLastItemInPreviousRow + 1 < numberOfItems,
      let maxYForPreviousRow = maxYForItemsRow(atIndex: rowIndex - 1)
    {
      // There's a previous row of items, so we'll use the max Y of that row as the starting place
      // for the current row of items.
      startingItemIndex = indexOfLastItemInPreviousRow + 1
      currentY = maxYForPreviousRow + metrics.verticalSpacing
    } else if (headerModel == nil && rowIndex == 0) || (headerModel != nil && rowIndex == 1) {
      // Our starting row doesn't exist yet, so we'll lay out our first row of items.
      startingItemIndex = 0
      currentY = (headerModel?.originInSection.y ?? metrics.sectionInsets.top) +
        (headerModel?.size.height ?? 0)
    } else {
      // Our starting row is after the last row of items, so we'll skip item layout.
      startingItemIndex = numberOfItems
      if
        let lastRowIndex = indexOfLastItemsRow(),
        rowIndex > lastRowIndex,
        let maxYOfLastRowOfItems = maxYForItemsRow(atIndex: lastRowIndex)
      {
        currentY = maxYOfLastRowOfItems
      } else {
        currentY = (headerModel?.originInSection.y ?? metrics.sectionInsets.top) +
          (headerModel?.size.height ?? 0)
      }
    }

    var indexInCurrentRow = 0
    var heightOfTallestItemInCurrentRow = CGFloat(0)
    var stretchToTallestItemInRowItemIndicesInCurrentRow = Set<Int>()

    for itemIndex in startingItemIndex..<numberOfItems {
      // Create item / row index mappings
      itemIndicesForRowIndices[rowIndex] = itemIndicesForRowIndices[rowIndex] ?? []
      itemIndicesForRowIndices[rowIndex]?.append(itemIndex)
      rowIndicesForItemIndices[itemIndex] = rowIndex
      
      let itemModel = itemModels[itemIndex]

      if itemIndex == 0 {
        // Apply top item inset now that we're laying out items
        currentY += metrics.itemInsets.top
      }

      let currentLeadingMargin: CGFloat
      let availableWidthForItems: CGFloat
      if itemModel.sizeMode.widthMode == .fullWidth(respectsHorizontalInsets: false) {
        currentLeadingMargin = metrics.sectionInsets.left
        availableWidthForItems = metrics.width
      } else {
        currentLeadingMargin = metrics.sectionInsets.left + metrics.itemInsets.left
        availableWidthForItems = metrics.width - metrics.itemInsets.left - metrics.itemInsets.right
      }

      let totalSpacing = metrics.horizontalSpacing * (itemModel.sizeMode.widthMode.widthDivisor - 1)
      let itemWidth = round(
        (availableWidthForItems - totalSpacing) / itemModel.sizeMode.widthMode.widthDivisor)
      let itemX = CGFloat(indexInCurrentRow) *
        itemWidth + CGFloat(indexInCurrentRow) *
        metrics.horizontalSpacing + currentLeadingMargin
      let itemY = currentY

      // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
      // and Swift retain / release calls.
      let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
      let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(to: ItemModel.self)

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

      if
        (indexInCurrentRow == Int(itemModel.sizeMode.widthMode.widthDivisor) - 1) ||
        (itemIndex == numberOfItems - 1) ||
        (itemIndex < numberOfItems - 1 && itemModels[itemIndex + 1].sizeMode.widthMode != itemModel.sizeMode.widthMode)
      {
        // We've reached the end of the current row, or there are no more items to lay out, or we're
        // about to lay out an item with a different width mode. In all cases, we're done laying out
        // the current row of items.
        currentY += heightOfTallestItemInCurrentRow
        rowIndex += 1
        indexInCurrentRow = 0
        heightOfTallestItemInCurrentRow = 0
        stretchToTallestItemInRowItemIndicesInCurrentRow.removeAll()

        // If there are more items to layout, add vertical spacing
        if itemIndex < numberOfItems - 1 {
          currentY += metrics.verticalSpacing
        }
      } else {
        // We're still adding to the current row
        indexInCurrentRow += 1
      }
    }

    if numberOfItems > 0 {
      // Apply bottom item inset now that we're done laying out items
      currentY += metrics.itemInsets.bottom
    }

    // Footer frame calculations
    if rowIndex == indexOfFooterRow(), var newFooterModel = footerModel {
      newFooterModel.originInSection = CGPoint(x: metrics.sectionInsets.left, y: currentY)
      newFooterModel.size.width = metrics.width
      newFooterModel.size.height = newFooterModel.preferredHeight ?? newFooterModel.size.height
      footerModel = newFooterModel
    }

    // Final height calculation
    calculatedHeight = currentY + (footerModel?.size.height ?? 0) + metrics.sectionInsets.bottom

    // Background frame calculations
    backgroundModel?.originInSection = CGPoint(
      x: metrics.sectionInsets.left,
      y: metrics.sectionInsets.top)
    backgroundModel?.size.width = metrics.width
    backgroundModel?.size.height = calculatedHeight -
      metrics.sectionInsets.top -
      metrics.sectionInsets.bottom

    indexOfFirstInvalidatedRow = nil
  }

}
