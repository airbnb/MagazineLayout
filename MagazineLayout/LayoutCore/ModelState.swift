// Created by bryankeller on 2/25/18.
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

/// Manages the state of section and element models.
final class ModelState {

  // MARK: Lifecycle

  init(currentVisibleBoundsProvider: @escaping () -> CGRect) {
    self.currentVisibleBoundsProvider = currentVisibleBoundsProvider
  }

  // MARK: Internal

  private(set) var sectionIndicesToInsert = Set<Int>()
  private(set) var sectionIndicesToDelete = Set<Int>()
  private(set) var itemIndexPathsToInsert = Set<IndexPath>()
  private(set) var itemIndexPathsToDelete = Set<IndexPath>()

  var numberOfSections: Int {
    sectionModels.count
  }

  func numberOfItems(inSectionAtIndex sectionIndex: Int) -> Int {
    sectionModels[sectionIndex].numberOfItems
  }

  func idForItemModel(at indexPath: IndexPath) -> UInt64? {
    guard
      indexPath.section < sectionModels.count,
      indexPath.item < sectionModels[indexPath.section].numberOfItems else
    {
      // This occurs when getting layout attributes for initial / final animations
      return nil
    }

    return sectionModels[indexPath.section].idForItemModel(atIndex: indexPath.item)
  }

  func indexPathForItemModel(withID id: UInt64) -> IndexPath? {
    for sectionIndex in 0..<sectionModels.count {
      guard let index = sectionModels[sectionIndex].indexForItemModel(withID: id) else {
        continue
      }
      return IndexPath(item: index, section: sectionIndex)
    }

    return nil
  }

  func idForSectionModel(atIndex index: Int) -> UInt64? {
    guard index < sectionModels.count else {
      // This occurs when getting layout attributes for initial / final animations
      return nil
    }

    return sectionModels[index].id
  }

  func indexForSectionModel(withID id: UInt64) -> Int? {
    for sectionIndex in 0..<sectionModels.count {
      guard sectionModels[sectionIndex].id == id else { continue }
      return sectionIndex
    }

    return nil
  }

  func isItemHeightSettled(indexPath: IndexPath) -> Bool {
    let item = sectionModels[indexPath.section].itemModel(atIndex: indexPath.item)
    switch item.sizeMode.heightMode {
    case .static:
      return true
    case .dynamicAndStretchToTallestItemInRow, .dynamic(_):
      return item.preferredHeight != nil
    }
  }

  func itemModelHeightMode(at indexPath: IndexPath) -> MagazineLayoutItemHeightMode? {
    guard
      indexPath.section < sectionModels.count,
      indexPath.item < sectionModels[indexPath.section].numberOfItems else
    {
      assertionFailure("Height mode for item at \(indexPath) is out of bounds")
      return nil
    }

    return sectionModels[indexPath.section].itemModel(atIndex: indexPath.item).sizeMode.heightMode
  }

  func headerModelHeightMode(atSectionIndex sectionIndex: Int) -> MagazineLayoutHeaderHeightMode? {
    guard sectionIndex < sectionModels.count else {
      assertionFailure("Height mode for header at section index \(sectionIndex) is out of bounds")
      return nil
    }

    return sectionModels[sectionIndex].headerModel?.heightMode
  }

  func footerModelHeightMode(atSectionIndex sectionIndex: Int) -> MagazineLayoutFooterHeightMode? {
    guard sectionIndex < sectionModels.count else {
      assertionFailure("Height mode for footer at section index \(sectionIndex) is out of bounds")
      return nil
    }

    return sectionModels[sectionIndex].footerModel?.heightMode
  }

  func itemModelPreferredHeight(at indexPath: IndexPath) -> CGFloat? {
    guard
      indexPath.section < sectionModels.count,
      indexPath.item < sectionModels[indexPath.section].numberOfItems else
    {
      assertionFailure("Height mode for item at \(indexPath) is out of bounds")
      return nil
    }

    return sectionModels[indexPath.section].preferredHeightForItemModel(atIndex: indexPath.item)
  }

  func itemLocationFramePairs(forItemsIn rect: CGRect) -> ElementLocationFramePairs {
    return elementLocationFramePairsForElements(
      in: rect,
      withElementLocationsForFlattenedIndices: itemLocationsForFlattenedIndices,
      andFramesProvidedBy: { itemLocation -> CGRect in
        return frameForItem(at: itemLocation)
      })
  }

  func headerLocationFramePairs(forHeadersIn rect: CGRect) -> ElementLocationFramePairs {
    return elementLocationFramePairsForElements(
      in: rect,
      withElementLocationsForFlattenedIndices: headerLocationsForFlattenedIndices,
      andFramesProvidedBy: { headerLocation -> CGRect in
        guard
          let headerFrame = frameForHeader(
            inSectionAtIndex: headerLocation.sectionIndex) else
        {
          assertionFailure("Expected a frame for header in section at \(headerLocation.sectionIndex)")
          return .zero
        }

        return headerFrame
      })
  }

  func footerLocationFramePairs(forFootersIn rect: CGRect) -> ElementLocationFramePairs {
    return elementLocationFramePairsForElements(
      in: rect,
      withElementLocationsForFlattenedIndices: footerLocationsForFlattenedIndices,
      andFramesProvidedBy: { footerLocation -> CGRect in
        guard
          let footerFrame = frameForFooter(
            inSectionAtIndex: footerLocation.sectionIndex) else
        {
          assertionFailure("Expected a frame for footer in section at \(footerLocation.sectionIndex)")
          return .zero
        }

        return footerFrame
      })
  }

  func backgroundLocationFramePairs(forBackgroundsIn rect: CGRect) -> ElementLocationFramePairs {
    return elementLocationFramePairsForElements(
      in: rect,
      withElementLocationsForFlattenedIndices: backgroundLocationsForFlattenedIndices,
      andFramesProvidedBy: { backgroundLocation -> CGRect in
        guard
          let backgroundFrame = frameForBackground(
            inSectionAtIndex: backgroundLocation.sectionIndex) else
        {
          assertionFailure("Expected a frame for background in section at \(backgroundLocation.sectionIndex)")
          return .zero
        }

        return backgroundFrame
      })
  }

  func sectionMaxY(forSectionAtIndex targetSectionIndex: Int) -> CGFloat {
    var sectionMaxY: CGFloat {
      guard targetSectionIndex >= 0 && targetSectionIndex < numberOfSections else {
        assertionFailure("`targetSectionIndex` is not within the bounds of the section models array")
        return 0
      }

      var totalHeight: CGFloat = 0
      for sectionIndex in 0...targetSectionIndex {
        totalHeight += sectionModels[sectionIndex].calculateHeight()
      }

      return totalHeight
    }

    let maxY = cachedMaxYForSection(atIndex: targetSectionIndex) ?? sectionMaxY
    cacheMaxY(maxY, forSectionAtIndex: targetSectionIndex)
    return maxY
  }

  func frameForItem(at itemLocation: ElementLocation) -> CGRect {
    let sectionMinY: CGFloat
    if itemLocation.sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(
        forSectionAtIndex: itemLocation.sectionIndex - 1)
    }

    var itemFrame: CGRect!
    mutateSectionModels(
      withUnsafeMutableBufferPointer: { directlyMutableSectionModels in
        itemFrame = directlyMutableSectionModels[itemLocation.sectionIndex].calculateFrameForItem(
          atIndex: itemLocation.elementIndex)
      })

    itemFrame.origin.y += sectionMinY
    return itemFrame
  }

  func frameForHeader(inSectionAtIndex sectionIndex: Int) -> CGRect? {
    let sectionMinY: CGFloat
    if sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(forSectionAtIndex: sectionIndex - 1)
    }

    let currentVisibleBounds = currentVisibleBoundsProvider()
    var headerFrame: CGRect?
    mutateSectionModels(
      withUnsafeMutableBufferPointer: { directlyMutableSectionModels in
        headerFrame = directlyMutableSectionModels[sectionIndex].calculateFrameForHeader(
          inSectionVisibleBounds: CGRect(
            x: currentVisibleBounds.minX,
            y: currentVisibleBounds.minY - sectionMinY,
            width: currentVisibleBounds.width,
            height: currentVisibleBounds.height))
      })

    headerFrame?.origin.y += sectionMinY
    return headerFrame
  }

  func frameForFooter(inSectionAtIndex sectionIndex: Int) -> CGRect? {
    let sectionMinY: CGFloat
    if sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(forSectionAtIndex: sectionIndex - 1)
    }

    let currentVisibleBounds = currentVisibleBoundsProvider()
    var footerFrame: CGRect?
    mutateSectionModels(
      withUnsafeMutableBufferPointer: { directlyMutableSectionModels in
        footerFrame = directlyMutableSectionModels[sectionIndex].calculateFrameForFooter(
          inSectionVisibleBounds: CGRect(
            x: currentVisibleBounds.minX,
            y: currentVisibleBounds.minY - sectionMinY,
            width: currentVisibleBounds.width,
            height: currentVisibleBounds.height))
      })

    footerFrame?.origin.y += sectionMinY
    return footerFrame
  }

  func frameForBackground(inSectionAtIndex sectionIndex: Int) -> CGRect? {
    let sectionMinY: CGFloat
    if sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(forSectionAtIndex: sectionIndex - 1)
    }

    var backgroundFrame: CGRect?
    mutateSectionModels(
      withUnsafeMutableBufferPointer: { directlyMutableSectionModels in
        backgroundFrame = directlyMutableSectionModels[sectionIndex].calculateFrameForBackground()
      })

    backgroundFrame?.origin.y += sectionMinY
    return backgroundFrame
  }

  func copy() -> ModelState {
    let currentVisibleBounds = currentVisibleBoundsProvider()
    let newModelState = ModelState(currentVisibleBoundsProvider: { currentVisibleBounds })
    newModelState.sectionModels = sectionModels
    newModelState.headerLocationsForFlattenedIndices = headerLocationsForFlattenedIndices
    newModelState.footerLocationsForFlattenedIndices = footerLocationsForFlattenedIndices
    newModelState.backgroundLocationsForFlattenedIndices = backgroundLocationsForFlattenedIndices
    newModelState.itemLocationsForFlattenedIndices = itemLocationsForFlattenedIndices
    return newModelState
  }

  func updateItemHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forItemAt indexPath: IndexPath)
  {
    guard
      indexPath.section < sectionModels.count,
      indexPath.item < sectionModels[indexPath.section].numberOfItems else
    {
      assertionFailure("Updating the preferred height for an item model at \(indexPath) is out of bounds")
      return
    }

    sectionModels[indexPath.section].updateItemHeight(
      toPreferredHeight: preferredHeight,
      atIndex: indexPath.item)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: indexPath.section)
  }

  func updateHeaderHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forSectionAtIndex sectionIndex: Int)
  {
    guard sectionIndex < sectionModels.count else {
      assertionFailure("Updating the preferred height for a header model at section index \(sectionIndex) is out of bounds")
      return
    }

    sectionModels[sectionIndex].updateHeaderHeight(toPreferredHeight: preferredHeight)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func updateFooterHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forSectionAtIndex sectionIndex: Int)
  {
    guard sectionIndex < sectionModels.count else {
      assertionFailure("Updating the preferred height for a footer model at section index \(sectionIndex) is out of bounds")
      return
    }

    sectionModels[sectionIndex].updateFooterHeight(toPreferredHeight: preferredHeight)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func updateMetrics(
    to sectionMetrics: MagazineLayoutSectionMetrics,
    forSectionAtIndex sectionIndex: Int)
  {
    sectionModels[sectionIndex].updateMetrics(to: sectionMetrics)
    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func updateItemSizeMode(to sizeMode: MagazineLayoutItemSizeMode, forItemAt indexPath: IndexPath) {
    sectionModels[indexPath.section].updateItemSizeMode(to: sizeMode, atIndex: indexPath.item)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: indexPath.section)
  }

  func setHeader(_ headerModel: HeaderModel, forSectionAtIndex sectionIndex: Int) {
    sectionModels[sectionIndex].setHeader(headerModel)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)

    prepareElementLocationsForFlattenedIndices()
  }

  func removeHeader(forSectionAtIndex sectionIndex: Int) {
    if sectionModels[sectionIndex].removeHeader() {
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
      prepareElementLocationsForFlattenedIndices()
    }
  }

  func setFooter(_ footerModel: FooterModel, forSectionAtIndex sectionIndex: Int) {
    sectionModels[sectionIndex].setFooter(footerModel)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)

    prepareElementLocationsForFlattenedIndices()
  }

  func removeFooter(forSectionAtIndex sectionIndex: Int) {
    if sectionModels[sectionIndex].removeFooter() {
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
      prepareElementLocationsForFlattenedIndices()
    }
  }

  func setBackground(_ backgroundModel: BackgroundModel, forSectionAtIndex sectionIndex: Int) {
    sectionModels[sectionIndex].setBackground(backgroundModel)

    prepareElementLocationsForFlattenedIndices()
  }

  func removeBackground(forSectionAtIndex sectionIndex: Int) {
    if sectionModels[sectionIndex].removeBackground() {
      prepareElementLocationsForFlattenedIndices()
    }
  }

  func setSections(_ sectionModels: [SectionModel]) {
    self.sectionModels = sectionModels

    invalidateEntireSectionMaxYsCache()
    allocateMemoryForSectionMaxYsCache()

    prepareElementLocationsForFlattenedIndices()
  }

  func applyUpdates(
    _ updates: [CollectionViewUpdate<SectionModel, ItemModel>],
    modelStateBeforeBatchUpdates: ModelState)
  {
    let sectionModelsBeforeBatchUpdates = modelStateBeforeBatchUpdates.sectionModels
    invalidateEntireSectionMaxYsCache()

    var sectionModelReloadIndexPairs = [(sectionModel: SectionModel, reloadIndex: Int)]()
    var itemModelReloadIndexPathPairs = [(itemModel: ItemModel, reloadIndexPath: IndexPath)]()

    var sectionIndicesToDelete = [Int]()
    var itemIndexPathsToDelete = [IndexPath]()

    var sectionModelInsertIndexPairs = [(sectionModel: SectionModel, insertIndex: Int)]()
    var itemModelInsertIndexPathPairs = [(itemModel: ItemModel, insertIndexPath: IndexPath)]()

    for update in updates {
      switch update {
      case let .sectionReload(sectionIndex, newSection):
        sectionModelReloadIndexPairs.append((newSection, sectionIndex))

      case let .itemReload(itemIndexPath, newItem):
        itemModelReloadIndexPathPairs.append((newItem, itemIndexPath))

      case let .sectionDelete(sectionIndex):
        sectionIndicesToDelete.append(sectionIndex)
        self.sectionIndicesToDelete.insert(sectionIndex)

      case let .itemDelete(itemIndexPath):
        itemIndexPathsToDelete.append(itemIndexPath)
        self.itemIndexPathsToDelete.insert(itemIndexPath)

      case let .sectionMove(initialSectionIndex, finalSectionIndex):
        sectionIndicesToDelete.append(initialSectionIndex)
        let sectionModelToMove = sectionModelsBeforeBatchUpdates[initialSectionIndex]
        sectionModelInsertIndexPairs.append((sectionModelToMove, finalSectionIndex))

      case let .itemMove(initialItemIndexPath, finalItemIndexPath):
        itemIndexPathsToDelete.append(initialItemIndexPath)
        let sectionContainingItemModelToMove = sectionModelsBeforeBatchUpdates[initialItemIndexPath.section]
        let itemModelToMove = sectionContainingItemModelToMove.itemModel(
          atIndex: initialItemIndexPath.item)
        itemModelInsertIndexPathPairs.append((itemModelToMove, finalItemIndexPath))

      case let .sectionInsert(sectionIndex, newSection):
        sectionModelInsertIndexPairs.append((newSection, sectionIndex))
        sectionIndicesToInsert.insert(sectionIndex)

      case let .itemInsert(itemIndexPath, newItem):
        itemModelInsertIndexPathPairs.append((newItem, itemIndexPath))
        itemIndexPathsToInsert.insert(itemIndexPath)
      }
    }

    reloadItemModels(itemModelReloadIndexPathPairs: itemModelReloadIndexPathPairs)
    reloadSectionModels(sectionModelReloadIndexPairs: sectionModelReloadIndexPairs)

    deleteItemModels(atIndexPaths: itemIndexPathsToDelete)
    deleteSectionModels(atIndices: sectionIndicesToDelete)

    insertSectionModels(sectionModelInsertIndexPairs: sectionModelInsertIndexPairs)
    insertItemModels(itemModelInsertIndexPathPairs: itemModelInsertIndexPathPairs)

    allocateMemoryForSectionMaxYsCache()

    prepareElementLocationsForFlattenedIndices()
  }

  func clearInProgressBatchUpdateState() {
    sectionIndicesToInsert.removeAll()
    sectionIndicesToDelete.removeAll()
    itemIndexPathsToInsert.removeAll()
    itemIndexPathsToDelete.removeAll()
  }

  // MARK: Private

  private let currentVisibleBoundsProvider: () -> CGRect

  private var sectionModels = [SectionModel]()

  private var sectionMaxYsCache = [CGFloat?]()

  private var headerLocationsForFlattenedIndices = [Int: ElementLocation]()
  private var footerLocationsForFlattenedIndices = [Int: ElementLocation]()
  private var backgroundLocationsForFlattenedIndices = [Int: ElementLocation]()
  private var itemLocationsForFlattenedIndices = [Int: ElementLocation]()

  private func mutateSectionModels(
    withUnsafeMutableBufferPointer body: (inout UnsafeMutableBufferPointer<SectionModel>) -> Void)
  {
    // Accessing these arrays using unsafe, untyped (raw) pointers
    // avoids expensive copy-on-writes and Swift retain / release calls.
    sectionModels.withUnsafeMutableBufferPointer(body)
  }

  private func prepareElementLocationsForFlattenedIndices() {
    headerLocationsForFlattenedIndices.removeAll()
    footerLocationsForFlattenedIndices.removeAll()
    backgroundLocationsForFlattenedIndices.removeAll()
    itemLocationsForFlattenedIndices.removeAll()

    var flattenedHeaderIndex = 0
    var flattenedFooterIndex = 0
    var flattenedBackgroundIndex = 0
    var flattenedItemIndex = 0
    for sectionIndex in 0..<sectionModels.count {
      if sectionModels[sectionIndex].headerModel != nil {
        headerLocationsForFlattenedIndices[flattenedHeaderIndex] = ElementLocation(
          elementIndex: 0,
          sectionIndex: sectionIndex)
        flattenedHeaderIndex += 1
      }

      if sectionModels[sectionIndex].footerModel != nil {
        footerLocationsForFlattenedIndices[flattenedFooterIndex] = ElementLocation(
          elementIndex: 0,
          sectionIndex: sectionIndex)
        flattenedFooterIndex += 1
      }

      if sectionModels[sectionIndex].backgroundModel != nil {
        backgroundLocationsForFlattenedIndices[flattenedBackgroundIndex] = ElementLocation(
          elementIndex: 0,
          sectionIndex: sectionIndex)
        flattenedBackgroundIndex += 1
      }

      for itemIndex in 0..<sectionModels[sectionIndex].numberOfItems {
        itemLocationsForFlattenedIndices[flattenedItemIndex] = ElementLocation(
          elementIndex: itemIndex,
          sectionIndex: sectionIndex)
        flattenedItemIndex += 1
      }
    }
  }

  private func elementLocationFramePairsForElements(
    in rect: CGRect,
    withElementLocationsForFlattenedIndices elementLocationsForFlattenedIndices: [Int: ElementLocation],
    andFramesProvidedBy frameProvider: ((ElementLocation) -> CGRect))
    -> ElementLocationFramePairs
  {
    var elementLocationFramePairs = ElementLocationFramePairs()

    guard
      let indexOfFirstFoundElement = indexOfFirstFoundElement(
        in: rect,
        withElementLocationsForFlattenedIndices: elementLocationsForFlattenedIndices,
        andFramesProvidedBy: frameProvider) else
    {
      return elementLocationFramePairs
    }

    // Used to handle the case where we encounter an element that doesn't intersect the rect, but
    // previous elements in the same row might.
    var minYOfNonIntersectingElement: CGFloat?

    // Look backward to find visible elements
    for elementLocationIndex in (0..<indexOfFirstFoundElement).reversed() {
      let elementLocation = self.elementLocation(
        forFlattenedIndex: elementLocationIndex,
        in: elementLocationsForFlattenedIndices)
      let frame = frameProvider(elementLocation)

      guard frame.maxY > rect.minY else {
        if let minY = minYOfNonIntersectingElement, frame.minY < minY {
          // We're in a previous row, so we know we've captured all intersecting rects for the
          // subsequent row.
          break
        } else {
          // We've found a non-intersecting item, but still need to check other items in the same
          // row.
          minYOfNonIntersectingElement = frame.minY
          continue
        }
      }

      elementLocationFramePairs.append(
        ElementLocationFramePair(elementLocation: elementLocation, frame: frame))
    }

    // Look forward to find visible elements
    for elementLocationIndex in indexOfFirstFoundElement..<elementLocationsForFlattenedIndices.count {
      let elementLocation = self.elementLocation(
        forFlattenedIndex: elementLocationIndex,
        in: elementLocationsForFlattenedIndices)
      let frame = frameProvider(elementLocation)
      guard frame.minY < rect.maxY else { break }

      elementLocationFramePairs.append(
        ElementLocationFramePair(elementLocation: elementLocation, frame: frame))
    }

    return elementLocationFramePairs
  }

  private func indexOfFirstFoundElement(
    in rect: CGRect,
    withElementLocationsForFlattenedIndices elementLocationsForFlattenedIndices: [Int: ElementLocation],
    andFramesProvidedBy frameProvider: ((ElementLocation) -> CGRect))
    -> Int?
  {
    var lowerBound = 0
    var upperBound = elementLocationsForFlattenedIndices.count - 1

    while lowerBound <= upperBound {
      let index = (lowerBound + upperBound) / 2
      let elementLocation = self.elementLocation(
        forFlattenedIndex: index,
        in: elementLocationsForFlattenedIndices)
      let elementFrame = frameProvider(elementLocation)
      if elementFrame.maxY <= rect.minY {
        lowerBound = index + 1
      } else if elementFrame.minY >= rect.maxY {
        upperBound = index - 1
      } else {
        return index
      }
    }

    return nil
  }

  private func elementLocation(
    forFlattenedIndex index: Int,
    in elementLocationsForFlattenedIndices: [Int: ElementLocation])
    -> ElementLocation
  {
    guard let elementLocation = elementLocationsForFlattenedIndices[index] else {
      preconditionFailure("`elementLocationsForFlattenedIndices` must have a complete mapping of indices in 0..<\(elementLocationsForFlattenedIndices.count) to element locations")
    }

    return elementLocation
  }

  private func allocateMemoryForSectionMaxYsCache() {
    let arraySizeDelta = sectionModels.count - sectionMaxYsCache.count

    if arraySizeDelta > 0 { // Allocate more memory
      for _ in 0..<arraySizeDelta {
        sectionMaxYsCache.append(nil)
      }
    } else if arraySizeDelta < 0 { // Reclaim memory
      for _ in 0..<abs(arraySizeDelta) {
        sectionMaxYsCache.removeLast()
      }
    }
  }

  private func cachedMaxYForSection(atIndex sectionIndex: Int) -> CGFloat? {
    guard sectionIndex >= 0 && sectionIndex < sectionMaxYsCache.count else { return nil }

    return sectionMaxYsCache[sectionIndex]
  }

  private func cacheMaxY(_ sectionMaxY: CGFloat, forSectionAtIndex sectionIndex: Int) {
    guard sectionIndex >= 0 && sectionIndex < sectionMaxYsCache.count else { return }

    sectionMaxYsCache[sectionIndex] = sectionMaxY
  }

  private func invalidateEntireSectionMaxYsCache() {
    guard sectionMaxYsCache.count > 0 else { return }

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: 0)
  }

  func invalidateSectionMaxYsCacheForSectionIndices(startingAt sectionIndex: Int) {
    guard sectionIndex >= 0, sectionIndex < sectionMaxYsCache.count else {
      assertionFailure("Cannot invalidate `sectionMaxYsCache` starting at an invalid (negative or out-of-bounds) `sectionIndex` (\(sectionIndex)).")
      return
    }

    for sectionIndex in sectionIndex..<sectionMaxYsCache.count {
      sectionMaxYsCache[sectionIndex] = nil
    }
  }

  private func reloadSectionModels(
    sectionModelReloadIndexPairs: [(sectionModel: SectionModel, reloadIndex: Int)])
  {
    for (sectionModel, reloadIndex) in sectionModelReloadIndexPairs {
      sectionModels.remove(at: reloadIndex)
      sectionModels.insert(sectionModel, at: reloadIndex)
    }
  }

  private func reloadItemModels(
    itemModelReloadIndexPathPairs: [(itemModel: ItemModel, reloadIndexPath: IndexPath)])
  {
    for (itemModel, reloadIndexPath) in itemModelReloadIndexPathPairs {
      sectionModels[reloadIndexPath.section].deleteItemModel(
        atIndex: reloadIndexPath.item)
      sectionModels[reloadIndexPath.section].insert(
        itemModel, atIndex:
        reloadIndexPath.item)
    }
  }

  private func deleteSectionModels(atIndices indicesOfSectionModelsToDelete: [Int]) {
    // Always delete in descending order
    for indexOfSectionModelToDelete in (indicesOfSectionModelsToDelete.sorted { $0 > $1 }) {
      sectionModels.remove(at: indexOfSectionModelToDelete)
    }
  }

  private func deleteItemModels(atIndexPaths indexPathsOfItemModelsToDelete: [IndexPath]) {
    // Always delete in descending order
    for indexPathOfItemModelToDelete in (indexPathsOfItemModelsToDelete.sorted { $0 > $1 }) {
      sectionModels[indexPathOfItemModelToDelete.section].deleteItemModel(
        atIndex: indexPathOfItemModelToDelete.item)
    }
  }

  private func insertSectionModels(
    sectionModelInsertIndexPairs: [(sectionModel: SectionModel, insertIndex: Int)])
  {
    // Always insert in ascending order
    for (sectionModel, insertIndex) in (sectionModelInsertIndexPairs.sorted { $0.insertIndex < $1.insertIndex }) {
      sectionModels.insert(sectionModel, at: insertIndex)
    }
  }

  private func insertItemModels(
    itemModelInsertIndexPathPairs: [(itemModel: ItemModel, insertIndexPath: IndexPath)])
  {
    // Always insert in ascending order
    for (itemModel, insertIndexPath) in (itemModelInsertIndexPathPairs.sorted { $0.insertIndexPath < $1.insertIndexPath }) {
      let sectionIndex = insertIndexPath.section
      let itemIndex = insertIndexPath.item
      let section = sectionModels[sectionIndex]
      if itemIndex < section.numberOfItems, itemModel.id == section.idForItemModel(atIndex: itemIndex) {
        // If the `itemModel` to insert already exists at the destination index, then there's no need to insert it again. This
        // happens if item move updates are generated in addition to section move updates, which appears to be the case when using
        // `UICollectionViewDiffableDataSource`. Other diffing approaches, like Paul Heckel's, do not produce item moves when
        // their containing sections move.
        continue
      } else {
        sectionModels[insertIndexPath.section].insert(itemModel, atIndex: itemIndex)
      }
    }
  }

}
