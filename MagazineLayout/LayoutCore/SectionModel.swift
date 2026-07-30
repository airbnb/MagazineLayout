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

/// Represents the layout information for a section.
struct SectionModel {

  // MARK: Lifecycle

  init(
    idGenerator: IDGenerator,
    itemModels: [ItemModel],
    headerModel: HeaderModel?,
    footerModel: FooterModel?,
    backgroundModel: BackgroundModel?,
    metrics: MagazineLayoutSectionMetrics)
  {
    id = idGenerator.next()
    self.itemModels = itemModels
    self.headerModel = headerModel
    self.footerModel = footerModel
    self.backgroundModel = backgroundModel
    self.metrics = metrics
    calculatedHeight = 0
    numberOfRows = 0

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: 0)
  }

  // MARK: Internal

  let id: UInt64

  private(set) var headerModel: HeaderModel?
  private(set) var footerModel: FooterModel?
  private(set) var backgroundModel: BackgroundModel?

  var numberOfItems: Int {
    return itemModels.count
  }

  func idForItemModel(atIndex index: Int) -> UInt64 {
    return itemModels[index].id
  }

  func indexForItemModel(withID id: UInt64) -> Int? {
    return itemModels.firstIndex { $0.id == id }
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

    let rowIndex = rowIndicesForItemIndices[safe: index] ?? nil

    var origin = itemModels[index].originInSection
    if let rowIndex {
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
  mutating func updateItemModel(atIndex indexOfUpdate: Int, to itemModel: ItemModel) -> ItemModel {
    updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: indexOfUpdate)
    let oldItemModel = itemModels[indexOfUpdate]
    itemModels[indexOfUpdate] = itemModel
    return oldItemModel
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

  @discardableResult
  mutating func updateMetrics(to metrics: MagazineLayoutSectionMetrics) -> Bool {
    guard self.metrics != metrics else { return false }

    self.metrics = metrics

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: 0)

    return true
  }

  mutating func updateItemSizeModes(
    _ sizeModeProvider: (_ itemIndex: Int) -> MagazineLayoutItemSizeMode)
  {
    guard numberOfItems > 0 else { return }

    var indexOfFirstInvalidatedItem: Int?
    itemModels.withUnsafeMutableBufferPointer { itemModels in
      for index in 0..<itemModels.count {
        let sizeMode = sizeModeProvider(index)
        let itemModel = itemModels[index]
        if itemModel.sizeMode != sizeMode {
          itemModels[index].sizeMode = sizeMode
          indexOfFirstInvalidatedItem = min(indexOfFirstInvalidatedItem ?? index, index)
        }

        if
          case let .static(staticHeight) = sizeMode.heightMode,
          itemModel.size.height != staticHeight
        {
          itemModels[index].size.height = staticHeight
          indexOfFirstInvalidatedItem = min(indexOfFirstInvalidatedItem ?? index, index)
        }
      }
    }

    if let indexOfFirstInvalidatedItem {
      updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex: indexOfFirstInvalidatedItem)
    }
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

  mutating func removeHeader() -> Bool {
    guard let indexOfHeader = indexOfHeaderRow() else {
      return false
    }
    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfHeader)
    headerModel = nil
    return true
  }

  mutating func removeFooter() -> Bool {
    guard footerModel != nil else {
      return false
    }
    // `indexOfFooterRow()` is `nil` if the section hasn't been laid out yet (deferred layout
    // calculation). In that case the whole section is already invalidated from row 0, so there's no
    // additional row to invalidate.
    if let indexOfFooter = indexOfFooterRow() {
      updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfFooter)
    }
    footerModel = nil
    return true
  }

  mutating func updateItemHeight(toPreferredHeight preferredHeight: CGFloat, atIndex index: Int) {
    calculateElementFramesIfNecessary()

    // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
    // and Swift retain / release calls.
    itemModels.withUnsafeMutableBufferPointer { directlyMutableItemModels in
      directlyMutableItemModels[index].preferredHeight = preferredHeight
    }

    let rowIndex = rowIndicesForItemIndices[safe: index] ?? nil
    let rowHeight = rowIndex.flatMap { itemRowHeightsForRowIndices[safe: $0] }

    if let rowIndex, let rowHeight {
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
    calculateElementFramesIfNecessary()

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
    calculateElementFramesIfNecessary()

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

  mutating func removeBackground() -> Bool {
    guard backgroundModel != nil else {
      return false
    }
    self.backgroundModel = nil
    // No need to invalidate since the background doesn't affect the layout.
    return true
  }

  // MARK: Private

  private var numberOfRows: Int
  private var itemModels: [ItemModel]
  private var metrics: MagazineLayoutSectionMetrics
  private var calculatedHeight: CGFloat

  private var indexOfFirstInvalidatedRow: Int? {
    didSet {
      guard let indexOfFirstInvalidatedRow else { return }
      applyRowOffsets(upToInvalidatedRow: indexOfFirstInvalidatedRow)
    }
  }

  private var itemIndicesForRowIndices = [ClosedRange<Int>?]()
  private var rowIndicesForItemIndices = [Int?]()
  private var itemRowHeightsForRowIndices = [CGFloat]()

  private var rowOffsetTracker: RowOffsetTracker?

  private func maxYForItemsRow(atIndex rowIndex: Int) -> CGFloat? {
    guard
      let itemIndices = itemIndicesForRowIndices[safe: rowIndex] ?? nil,
      let itemY = itemModels[safe: itemIndices.lowerBound]?.originInSection.y
    else {
      return nil
    }

    var maxItemHeight: CGFloat = 0
    for itemIndex in itemIndices {
      maxItemHeight = max(maxItemHeight, itemModels[safe: itemIndex]?.size.height ?? maxItemHeight)
    }

    return itemY + maxItemHeight
  }

  private func indexOfHeaderRow() -> Int? {
    guard headerModel != nil else { return nil }
    return 0
  }

  private func indexOfLastItemsRow() -> Int? {
    guard numberOfItems > 0 else { return nil }
    return rowIndicesForItemIndices[numberOfItems - 1]
  }

  private func indexOfFooterRow() -> Int? {
    // `numberOfRows` is 0 until the section's element frames have been calculated. With deferred
    // layout calculation, the footer's row index isn't known yet in that state, so we return `nil`
    // rather than a bogus `numberOfRows - 1` (which would be -1).
    guard footerModel != nil, numberOfRows > 0 else { return nil }
    return numberOfRows - 1
  }
  
  private mutating func updateIndexOfFirstInvalidatedRow(forChangeToItemAtIndex changedIndex: Int) {
    guard
      let indexOfCurrentRow = rowIndicesForItemIndices[safe: changedIndex] ?? nil,
      indexOfCurrentRow > 0 else
    {
      indexOfFirstInvalidatedRow = rowIndicesForItemIndices[safe: 0] ?? 0
      return
    }

    updateIndexOfFirstInvalidatedRowIfNecessary(toProposedIndex: indexOfCurrentRow - 1)
  }
  
  private mutating func updateIndexOfFirstInvalidatedRowIfNecessary(
    toProposedIndex proposedIndex: Int)
  {
    indexOfFirstInvalidatedRow = min(proposedIndex, indexOfFirstInvalidatedRow ?? proposedIndex)
  }
  
  /// Bakes the row offset tracker's accumulated offsets into the stored element origins, then clears
  /// the tracker.
  private mutating func applyRowOffsets(upToInvalidatedRow invalidatedRow: Int) {
    guard let rowOffsetTracker = rowOffsetTracker else { return }

    let upperBound = min(invalidatedRow, numberOfRows)
    guard upperBound > 0 else {
      // Every row is about to be recomputed, so the tracker's offsets are irrelevant. Drop it.
      self.rowOffsetTracker = nil
      return
    }

    for rowIndex in 0..<upperBound {
      let rowOffset = rowOffsetTracker.offsetForRow(at: rowIndex)
      switch rowIndex {
      case indexOfHeaderRow(): headerModel?.originInSection.y += rowOffset
      case indexOfFooterRow(): footerModel?.originInSection.y += rowOffset
      default:
        if let itemIndices = itemIndicesForRowIndices[safe: rowIndex] ?? nil {
          for itemIndex in itemIndices {
            itemModels[itemIndex].originInSection.y += rowOffset
          }
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
    var lowestItemIndex: Int?
    var lowestRowIndexKey: Int?
    var lowestRowIndex: Int?
    for rowIndexKey in itemIndicesForRowIndices.indices {
      guard rowIndexKey >= rowIndex else { continue }

      if let itemIndices = itemIndicesForRowIndices[safe: rowIndexKey] ?? nil {
        lowestItemIndex = min(lowestItemIndex ?? itemIndices.lowerBound, itemIndices.lowerBound)
      }

      lowestRowIndexKey = min(lowestRowIndexKey ?? rowIndexKey, rowIndexKey)
      lowestRowIndex = min(lowestRowIndex ?? rowIndex, rowIndex)
    }

    if let lowestItemIndex {
      rowIndicesForItemIndices.removeSubrange(lowestItemIndex...)
    }
    if let lowestRowIndexKey {
      itemIndicesForRowIndices.removeSubrange(lowestRowIndexKey...)
    }
    if let lowestRowIndex {
      itemRowHeightsForRowIndices.removeSubrange(lowestRowIndex...)
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

    let previousRowIndex = rowIndex - 1
    let indexOfLastItemInPreviousRow = itemIndicesForRowIndices[safe: previousRowIndex]??.upperBound

    let startingItemIndex: Int
    if
      let indexOfLastItemInPreviousRow,
      indexOfLastItemInPreviousRow + 1 < numberOfItems,
      let maxYForPreviousRow = maxYForItemsRow(atIndex: previousRowIndex)
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
    for itemIndex in startingItemIndex..<numberOfItems {
      // Create item / row index mappings
      itemIndicesForRowIndices.grow(toInclude: rowIndex, fillingWith: nil)
      if let range = itemIndicesForRowIndices[rowIndex] {
        itemIndicesForRowIndices[rowIndex] = range.lowerBound...itemIndex
      } else {
        itemIndicesForRowIndices[rowIndex] = itemIndex...itemIndex
      }
      rowIndicesForItemIndices.grow(toInclude: itemIndex, fillingWith: nil)
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
      let itemWidth = ((availableWidthForItems - totalSpacing) / itemModel.sizeMode.widthMode.widthDivisor)
        .alignedToPixel(forScreenWithScale: metrics.scale)
      let itemX = CGFloat(indexInCurrentRow) *
        itemWidth + CGFloat(indexInCurrentRow) *
        metrics.horizontalSpacing + currentLeadingMargin
      let itemY = currentY

      // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
      // and Swift retain / release calls.
      itemModels.withUnsafeMutableBufferPointer { directlyMutableItemModels in
        directlyMutableItemModels[itemIndex].originInSection = CGPoint(x: itemX, y: itemY)
        directlyMutableItemModels[itemIndex].size.width = itemWidth
      }

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
    guard let indicesForItemsInRow = itemIndicesForRowIndices[safe: rowIndex] ?? nil else {
      assertionFailure("Expected item indices for row \(rowIndex).")
      return 0
    }

    var heightOfTallestItem = CGFloat(0)
    var stretchToTallestItemInRowItemIndices = Set<Int>()

    for itemIndex in indicesForItemsInRow {
      let preferredHeight = itemModels[itemIndex].preferredHeight
      let height = itemModels[itemIndex].size.height

      // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
      // and Swift retain / release calls.
      itemModels.withUnsafeMutableBufferPointer { directlyMutableItemModels in
        directlyMutableItemModels[itemIndex].size.height = preferredHeight ?? height
      }

      // Handle stretch to tallest item in row height mode for current row

      if itemModels[itemIndex].sizeMode.heightMode == .dynamicAndStretchToTallestItemInRow {
        stretchToTallestItemInRowItemIndices.insert(itemIndex)
      }

      heightOfTallestItem = max(heightOfTallestItem, itemModels[itemIndex].size.height)
    }

    for stretchToTallestItemInRowItemIndex in stretchToTallestItemInRowItemIndices{
      // Accessing this array using an unsafe, untyped (raw) pointer avoids expensive copy-on-writes
      // and Swift retain / release calls.
      itemModels.withUnsafeMutableBufferPointer { directlyMutableItemModels in
        directlyMutableItemModels[stretchToTallestItemInRowItemIndex].size.height = heightOfTallestItem
      }
    }

    itemRowHeightsForRowIndices.grow(toInclude: rowIndex, fillingWith: 0)
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
