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
    numberOfRows = 0

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: 0)
    calculateElementFramesIfNecessary()
  }

  // MARK: Internal

  let id: String

  private(set) var headerModel: HeaderModel?
  private(set) var footerModel: FooterModel?
  private(set) var backgroundModel: BackgroundModel?

  var visibleBounds: CGRect?

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

  mutating func calculateFrameForItem(atIndex index: Int) -> CGRect {
    calculateElementFramesIfNecessary()

    var origin = itemModels[index].originInSection
    if let rowIndex = rowIndicesForItemIndices[index] {
      origin.y += rowOffsetTracker?.offsetForRow(at: rowIndex) ?? 0
    } else {
      assertionFailure("Expected a row and a row height for item at \(index).")
    }

    return CGRect(origin: origin, size: itemModels[index].size)
  }

  mutating func calculateFrameForHeader(
    inSectionVisibleBounds sectionVisibleBounds: CGRect)
    -> CGRect?
  {
    guard headerModel != nil else { return nil }

    calculateElementFramesIfNecessary()

    // `headerModel` is a value type that might be mutated in `calculateElementFramesIfNecessary`,
    // so we can't use a copy made before that code executes (for example, in a
    // `guard let headerModel = headerModel else { ... }` at the top of this function).
    if let headerModel = headerModel {
      let originY: CGFloat
      if headerModel.pinToVisibleBounds {
        originY = max(
          min(
            sectionVisibleBounds.minY,
            calculateHeight() -
              metrics.sectionInsets.bottom -
              (footerModel?.size.height ?? 0) -
              headerModel.size.height),
          headerModel.originInSection.y)
      } else {
        originY = headerModel.originInSection.y
      }

      return CGRect(
        origin: CGPoint(x: headerModel.originInSection.x, y: originY),
        size: headerModel.size)
    } else {
      return nil
    }
  }

  mutating func calculateFrameForFooter(
    inSectionVisibleBounds sectionVisibleBounds: CGRect)
    -> CGRect?
  {
    guard footerModel != nil else { return nil }

    calculateElementFramesIfNecessary()

    var origin = footerModel?.originInSection
    if let rowIndex = indexOfFooterRow() {
      origin?.y += rowOffsetTracker?.offsetForRow(at: rowIndex) ?? 0
    } else {
      assertionFailure("Expected a row and a corresponding section footer.")
    }

    // `footerModel` is a value type that might be mutated in `calculateElementFramesIfNecessary`,
    // so we can't use a copy made before that code executes (for example, in a
    // `guard let footerModel = footerModel else { ... }` at the top of this function).
    if let footerModel = footerModel, let origin = origin {
      let originY: CGFloat
      if footerModel.pinToVisibleBounds {
        originY = min(
          max(
            sectionVisibleBounds.maxY - footerModel.size.height,
             metrics.sectionInsets.top + (headerModel?.size.height ?? 0)),
          origin.y)
      } else {
        originY = origin.y
      }

      return CGRect(
        origin: CGPoint(x: footerModel.originInSection.x, y: originY),
        size: footerModel.size)
    } else {
      return nil
    }
  }

  mutating func calculateFrameForBackground() -> CGRect? {
    let calculatedHeight = calculateHeight()

    backgroundModel?.originInSection = CGPoint(
      x: metrics.sectionInsets.left,
      y: metrics.sectionInsets.top)
    backgroundModel?.size.width = metrics.width
    backgroundModel?.size.height = calculatedHeight -
      metrics.sectionInsets.top -
      metrics.sectionInsets.bottom

    if let backgroundModel = backgroundModel {
      return CGRect(
        origin: CGPoint(x: backgroundModel.originInSection.x, y: backgroundModel.originInSection.y),
        size: backgroundModel.size)
    } else {
      return nil
    }
  }

  @discardableResult
  mutating func deleteItemModel(atIndex indexOfDeletion: Int) -> ItemModel {
    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: indexOfDeletion)

    return itemModels.remove(at: indexOfDeletion)
  }

  mutating func insert(_ itemModel: ItemModel, atIndex indexOfInsertion: Int) {
    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: indexOfInsertion)
    
    itemModels.insert(itemModel, at: indexOfInsertion)
  }

  mutating func updateMetrics(to metrics: MagazineLayoutSectionMetrics) {
    guard self.metrics != metrics else { return }

    self.metrics = metrics

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: 0)
  }

  mutating func updateItemSizeMode(to sizeMode: MagazineLayoutItemSizeMode, atIndex index: Int) {
    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / release calls.
    let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
    let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(to: ItemModel.self)

    directlyMutableItemModels[index].sizeMode = sizeMode

    if case let .static(staticHeight) = sizeMode.heightMode {
      directlyMutableItemModels[index].size.height = staticHeight
    }

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

  mutating func updateItemHeight(toPreferredHeight preferredHeight: CGFloat, atIndex index: Int) {
    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / release calls.
    let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
    let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(to: ItemModel.self)

    directlyMutableItemModels[index].preferredHeight = preferredHeight

    if
      let rowIndex = rowIndicesForItemIndices[index],
      let rowHeight = itemRowHeightsForRowIndices[rowIndex]
    {
      let newRowHeight = updateHeightsForItemsInRow(at: rowIndex)
      let heightDelta = newRowHeight - rowHeight

      calculatedHeight += heightDelta

      let firstAffectedRowIndex = rowIndex + 1
      if firstAffectedRowIndex < numberOfRows {
        rowOffsetTracker?.addOffset(heightDelta, forRowsStartingAt: firstAffectedRowIndex)
      }
    } else {
      assertionFailure("Expected a row and a row height for item at \(index).")
      return
    }
  }

  mutating func updateHeaderHeight(toPreferredHeight preferredHeight: CGFloat) {
    headerModel?.preferredHeight = preferredHeight

    if let indexOfHeaderRow = indexOfHeaderRow(), let headerModel = headerModel {
      let rowHeight = headerModel.size.height
      let newRowHeight = updateHeaderHeight(withMetricsFrom: headerModel)
      let heightDelta = newRowHeight - rowHeight
      
      calculatedHeight += heightDelta
      
      let firstAffectedRowIndex = indexOfHeaderRow + 1
      if firstAffectedRowIndex < numberOfRows {
        rowOffsetTracker?.addOffset(heightDelta, forRowsStartingAt: firstAffectedRowIndex)
      }
    } else {
      assertionFailure("Expected a row, a row height, and a corresponding section header.")
      return
    }
  }

  mutating func updateFooterHeight(toPreferredHeight preferredHeight: CGFloat) {
    footerModel?.preferredHeight = preferredHeight

    if let indexOfFooterRow = indexOfFooterRow(), let footerModel = footerModel {
      let rowHeight = footerModel.size.height
      let newRowHeight = updateFooterHeight(withMetricsFrom: footerModel)
      let heightDelta = newRowHeight - rowHeight
    
      calculatedHeight += heightDelta
      
      let firstAffectedRowIndex = indexOfFooterRow + 1
      if firstAffectedRowIndex < numberOfRows {
        rowOffsetTracker?.addOffset(heightDelta, forRowsStartingAt: firstAffectedRowIndex)
      }
    } else {
      assertionFailure("Expected a row, a row height, and a corresponding section footer.")
      return
    }
  }
      
  mutating func setBackground(_ backgroundModel: BackgroundModel) {
    self.backgroundModel = backgroundModel
    // No need to invalidate since the background doesn't affect the layout.
  }

  mutating func removeBackground() {
    backgroundModel = nil
    // No need to invalidate since the background doesn't affect the layout.
  }

  // MARK: Private

  private var numberOfRows: Int
  private var itemModels: [ItemModel]
  private var metrics: MagazineLayoutSectionMetrics
  private var calculatedHeight: CGFloat

  private var indexOfFirstInvalidatedRow: Int? {
    didSet {
      guard indexOfFirstInvalidatedRow != nil else { return }
      applyRowOffsetsIfNecessary()
    }
  }

  private var itemIndicesForRowIndices = [Int: [Int]]()
  private var rowIndicesForItemIndices = [Int: Int]()
  private var itemRowHeightsForRowIndices = [Int: CGFloat]()

  private var rowOffsetTracker: RowOffsetTracker?

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
    return numberOfRows - 1
  }
  
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
  
  private mutating func applyRowOffsetsIfNecessary() {
    guard let rowOffsetTracker = rowOffsetTracker else { return }

    for rowIndex in 0..<numberOfRows {
      let rowOffset = rowOffsetTracker.offsetForRow(at: rowIndex)
      switch rowIndex {
      case indexOfHeaderRow(): headerModel?.originInSection.y += rowOffset
      case indexOfFooterRow(): footerModel?.originInSection.y += rowOffset
      default:
        for itemIndex in itemIndicesForRowIndices[rowIndex] ?? [] {
          itemModels[itemIndex].originInSection.y += rowOffset
        }
      }
    }

    self.rowOffsetTracker = nil
  }

  private mutating func calculateElementFramesIfNecessary() {
    guard var rowIndex = indexOfFirstInvalidatedRow else { return }
    guard rowIndex >= 0 else {
      assertionFailure("Invalid `rowIndex` / `indexOfFirstInvalidatedRow` (\(rowIndex)).")
      return
    }

    // Clean up item / row / height mappings starting at our `indexOfFirstInvalidatedRow`; we'll
    // make new mappings for those row indices as we do layout calculations below. Since all
    // item / row index mappings before `indexOfFirstInvalidatedRow` are still valid, we'll leave
    // those alone.
    for rowIndexKey in itemIndicesForRowIndices.keys {
      guard rowIndexKey >= rowIndex else { continue }

      if let itemIndex = itemIndicesForRowIndices[rowIndexKey]?.first {
        rowIndicesForItemIndices[itemIndex] = nil
      }

      itemIndicesForRowIndices[rowIndexKey] = nil
      itemRowHeightsForRowIndices[rowIndex] = nil
    }

    // Header frame calculation
    if rowIndex == indexOfHeaderRow(), let existingHeaderModel = headerModel {
      rowIndex = 1

      headerModel?.originInSection = CGPoint(
        x: metrics.sectionInsets.left,
        y: metrics.sectionInsets.top)
      headerModel?.size.width = metrics.width
      updateHeaderHeight(withMetricsFrom: existingHeaderModel)
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

    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / release calls.
    let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
    let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(to: ItemModel.self)

    var indexInCurrentRow = 0
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

      directlyMutableItemModels[itemIndex].originInSection = CGPoint(x: itemX, y: itemY)
      directlyMutableItemModels[itemIndex].size.width = itemWidth

      if
        (indexInCurrentRow == Int(itemModel.sizeMode.widthMode.widthDivisor) - 1) ||
          (itemIndex == numberOfItems - 1) ||
          (itemIndex < numberOfItems - 1 && itemModels[itemIndex + 1].sizeMode.widthMode != itemModel.sizeMode.widthMode)
      {
        // We've reached the end of the current row, or there are no more items to lay out, or we're
        // about to lay out an item with a different width mode. In all cases, we're done laying out
        // the current row of items.
        let heightOfTallestItemInCurrentRow = updateHeightsForItemsInRow(at: rowIndex)
        currentY += heightOfTallestItemInCurrentRow
        indexInCurrentRow = 0

        // If there are more items to layout, add vertical spacing and increment the row index
        if itemIndex < numberOfItems - 1 {
          currentY += metrics.verticalSpacing
          rowIndex += 1
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
    if let existingFooterModel = footerModel {
      rowIndex += 1

      footerModel?.originInSection = CGPoint(x: metrics.sectionInsets.left, y: currentY)
      footerModel?.size.width = metrics.width
      updateFooterHeight(withMetricsFrom: existingFooterModel)
    }

    numberOfRows = rowIndex + 1

    // Final height calculation
    calculatedHeight = currentY + (footerModel?.size.height ?? 0) + metrics.sectionInsets.bottom

    // The background frame is calculated just-in-time, since its value doesn't affect the layout.

    // Create a row offset tracker now that we know how many rows we have
    rowOffsetTracker = RowOffsetTracker(numberOfRows: numberOfRows)

    // Mark the layout as clean / no longer invalid
    indexOfFirstInvalidatedRow = nil
  }

  private mutating func updateHeightsForItemsInRow(at rowIndex: Int) -> CGFloat {
    guard let indicesForItemsInRow = itemIndicesForRowIndices[rowIndex] else {
      assertionFailure("Expected item indices for row \(rowIndex).")
      return 0
    }

    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / release calls.
    let itemModelsPointer = UnsafeMutableRawPointer(mutating: &itemModels)
    let directlyMutableItemModels = itemModelsPointer.assumingMemoryBound(to: ItemModel.self)

    var heightOfTallestItem = CGFloat(0)
    var stretchToTallestItemInRowItemIndices = Set<Int>()

    for itemIndex in indicesForItemsInRow {
      let preferredHeight = itemModels[itemIndex].preferredHeight
      let height = itemModels[itemIndex].size.height
      directlyMutableItemModels[itemIndex].size.height = preferredHeight ?? height

      // Handle stretch to tallest item in row height mode for current row

      if itemModels[itemIndex].sizeMode.heightMode == .dynamicAndStretchToTallestItemInRow {
        stretchToTallestItemInRowItemIndices.insert(itemIndex)
      }

      heightOfTallestItem = max(heightOfTallestItem, itemModels[itemIndex].size.height)
    }

    for stretchToTallestItemInRowItemIndex in stretchToTallestItemInRowItemIndices{
      directlyMutableItemModels[stretchToTallestItemInRowItemIndex].size.height = heightOfTallestItem
    }

    itemRowHeightsForRowIndices[rowIndex] = heightOfTallestItem
    return heightOfTallestItem
  }
  
  @discardableResult
  private mutating func updateHeaderHeight(withMetricsFrom headerModel: HeaderModel) -> CGFloat {
    let height = headerModel.preferredHeight ?? headerModel.size.height
    self.headerModel?.size.height = height
    return height
  }
  
  @discardableResult
  private mutating func updateFooterHeight(withMetricsFrom footerModel: FooterModel) -> CGFloat {
    let height = footerModel.preferredHeight ?? footerModel.size.height
    self.footerModel?.size.height = height
    return height
  }
  
}
