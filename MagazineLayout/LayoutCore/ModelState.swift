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

  // MARK: Internal

  enum BatchUpdateStage {
    case beforeUpdates
    case afterUpdates
  }

  private(set) var isPerformingBatchUpdates: Bool = false

  private(set) var sectionIndicesToInsert = Set<Int>()
  private(set) var sectionIndicesToDelete = Set<Int>()
  private(set) var itemIndexPathsToInsert = Set<IndexPath>()
  private(set) var itemIndexPathsToDelete = Set<IndexPath>()

  func numberOfSections(_ batchUpdateStage: BatchUpdateStage) -> Int {
    return sectionModels(batchUpdateStage).count
  }

  func numberOfItems(
    inSectionAtIndex sectionIndex: Int,
    _ batchUpdateStage: BatchUpdateStage)
    -> Int
  {
    let sectionModels = self.sectionModels(batchUpdateStage)
    return sectionModels[sectionIndex].numberOfItems
  }

  func idForItemModel(at indexPath: IndexPath, _ batchUpdateStage: BatchUpdateStage) -> String? {
    let sectionModels = self.sectionModels(batchUpdateStage)

    guard
      indexPath.section < sectionModels.count,
      indexPath.item < sectionModels[indexPath.section].numberOfItems else
    {
      // This occurs when getting layout attributes for initial / final animations
      return nil
    }

    return sectionModels[indexPath.section].idForItemModel(atIndex: indexPath.item)
  }

  func indexPathForItemModel(
    withID id: String,
    _ batchUpdateStage: BatchUpdateStage)
    -> IndexPath?
  {
    let sectionModels = self.sectionModels(batchUpdateStage)

    for sectionIndex in 0..<sectionModels.count {
      guard let index = sectionModels[sectionIndex].indexForItemModel(withID: id) else {
        continue
      }
      return IndexPath(item: index, section: sectionIndex)
    }

    return nil
  }

  func idForSectionModel(atIndex index: Int, _ batchUpdateStage: BatchUpdateStage) -> String? {
    let sectionModels = self.sectionModels(batchUpdateStage)

    guard index < sectionModels.count else {
      // This occurs when getting layout attributes for initial / final animations
      return nil
    }

    return sectionModels[index].id
  }

  func indexForSectionModel(withID id: String, _ batchUpdateStage: BatchUpdateStage) -> Int? {
    let sectionModels = self.sectionModels(batchUpdateStage)

    for sectionIndex in 0..<sectionModels.count {
      guard sectionModels[sectionIndex].id == id else { continue }
      return sectionIndex
    }

    return nil
  }

  func itemModelHeightModeForPreferredAttributesCheck(
    at indexPath: IndexPath)
    -> MagazineLayoutItemHeightMode?
  {
    func itemModelHeightModeForPreferredAttributesCheck(
      at indexPath: IndexPath,
      sectionModels: inout [SectionModel])
      -> MagazineLayoutItemHeightMode?
    {
      guard
        indexPath.section < sectionModels.count,
        indexPath.item < sectionModels[indexPath.section].numberOfItems else
      {
        assertionFailure("Height mode for item at \(indexPath) is out of bounds")
        return nil
      }

      return sectionModels[indexPath.section].itemModel(atIndex: indexPath.item).sizeMode.heightMode
    }

    switch preferredHeightUpdateContext(forPreferredHeightUpdateToItemAt: indexPath) {
    case .updatePreviousModels, .updatePreviousAndCurrentModels:
      return itemModelHeightModeForPreferredAttributesCheck(
        at: indexPath,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      return itemModelHeightModeForPreferredAttributesCheck(
        at: indexPath,
        sectionModels: &currentSectionModels)
    }
  }

  func headerModelHeightModeDuringPreferredAttributesCheck(
    atSectionIndex sectionIndex: Int)
    -> MagazineLayoutHeaderHeightMode?
  {
    guard sectionIndex < currentSectionModels.count else {
      assertionFailure("Height mode for header at section index \(sectionIndex) is out of bounds")
      return nil
    }

    return currentSectionModels[sectionIndex].headerModel?.heightMode
  }

  func itemModelPreferredHeightDuringPreferredAttributesCheck(at indexPath: IndexPath) -> CGFloat? {
    func itemModelPreferredHeightDuringPreferredAttributesCheck(
      at indexPath: IndexPath,
      sectionModels: inout [SectionModel])
      -> CGFloat?
    {
      guard
        indexPath.section < sectionModels.count,
        indexPath.item < sectionModels[indexPath.section].numberOfItems else
      {
        assertionFailure("Height mode for item at \(indexPath) is out of bounds")
        return nil
      }

      return sectionModels[indexPath.section].preferredHeightForItemModel(atIndex: indexPath.item)
    }

    switch preferredHeightUpdateContext(forPreferredHeightUpdateToItemAt: indexPath) {
    case .updatePreviousModels, .updatePreviousAndCurrentModels:
      return itemModelPreferredHeightDuringPreferredAttributesCheck(
        at: indexPath,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      return itemModelPreferredHeightDuringPreferredAttributesCheck(
        at: indexPath,
        sectionModels: &currentSectionModels)
    }
  }

  func itemFrameInfo(forItemsIn visibleRect: CGRect) -> ElementLocationFramePairs {
    var itemLocationFramePairs = ElementLocationFramePairs()

    for sectionIndex in 0..<currentSectionModels.count {
      for itemIndex in 0..<currentSectionModels[sectionIndex].numberOfItems {
        let itemLocation = ElementLocation(
          elementIndex: itemIndex,
          sectionIndex: sectionIndex)

        let frame = frameForItem(at: itemLocation, .afterUpdates)
        guard frame.intersects(visibleRect) else { continue }

        itemLocationFramePairs.append(
          ElementLocationFramePair(elementLocation: itemLocation, frame: frame))
      }
    }

    return itemLocationFramePairs
  }

  func headerFrameInfo(forHeadersIn visibleRect: CGRect) -> ElementLocationFramePairs {
    var headerLocationFramePairs = ElementLocationFramePairs()

    for sectionIndex in 0..<currentSectionModels.count {
      guard
        let frame = frameForHeader(inSectionAtIndex: sectionIndex, .afterUpdates),
        frame.intersects(visibleRect) else
      {
        continue
      }

      let headerLocation = ElementLocation(elementIndex: 0, sectionIndex: sectionIndex)
      headerLocationFramePairs.append(
        ElementLocationFramePair(elementLocation: headerLocation, frame: frame))
    }

    return headerLocationFramePairs
  }

  func backgroundFrameInfo(forBackgroundsIn visibleRect: CGRect) -> ElementLocationFramePairs {
    var backgroundLocationFramePairs = ElementLocationFramePairs()

    for sectionIndex in 0..<currentSectionModels.count {
      guard
        let frame = frameForBackground(inSectionAtIndex: sectionIndex, .afterUpdates),
        frame.intersects(visibleRect) else
      {
        continue
      }

      let backgroundLocation = ElementLocation(elementIndex: 0, sectionIndex: sectionIndex)
      backgroundLocationFramePairs.append(
        ElementLocationFramePair(elementLocation: backgroundLocation, frame: frame))
    }

    return backgroundLocationFramePairs
  }

  func sectionMaxY(
    forSectionAtIndex targetSectionIndex: Int,
    _ batchUpdateStage: BatchUpdateStage)
    -> CGFloat
  {
    func sectionMaxY(
      forSectionAtIndex targetSectionIndex: Int,
      sectionModelsPointer: UnsafeMutableRawPointer,
      numberOfSectionModels: Int)
      -> CGFloat
    {
      guard targetSectionIndex >= 0 && targetSectionIndex < numberOfSectionModels else {
        assertionFailure("`targetSectionIndex` is not within the bounds of the section models array")
        return 0
      }

      let sectionModels = sectionModelsPointer.assumingMemoryBound(
        to: SectionModel.self)

      var totalHeight: CGFloat = 0
      for sectionIndex in 0...targetSectionIndex {
        totalHeight += sectionModels[sectionIndex].calculateHeight()
      }

      return totalHeight
    }

    switch batchUpdateStage {
    case .beforeUpdates:
      return sectionMaxY(
        forSectionAtIndex: targetSectionIndex,
        sectionModelsPointer: &sectionModelsBeforeBatchUpdates,
        numberOfSectionModels: sectionModelsBeforeBatchUpdates.count)
    case .afterUpdates:
      let maxY = cachedMaxYForSection(atIndex: targetSectionIndex) ?? sectionMaxY(
        forSectionAtIndex: targetSectionIndex,
        sectionModelsPointer: &currentSectionModels,
        numberOfSectionModels: currentSectionModels.count)
      cacheMaxY(maxY, forSectionAtIndex: targetSectionIndex)
      return maxY
    }
  }

  func frameForItem(
    at itemLocation: ElementLocation,
    _ batchUpdateStage: BatchUpdateStage)
    -> CGRect
  {
    let sectionMinY: CGFloat
    if itemLocation.sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(
        forSectionAtIndex: itemLocation.sectionIndex - 1,
        batchUpdateStage)
    }

    let sectionModelsPointer = self.sectionModelsPointer(batchUpdateStage)
    let sectionModels = sectionModelsPointer.assumingMemoryBound(
      to: SectionModel.self)

    var itemFrame = sectionModels[itemLocation.sectionIndex].calculateFrameForItem(
      atIndex: itemLocation.elementIndex)
    itemFrame.origin.y += sectionMinY
    return itemFrame

  }

  func frameForHeader(
    inSectionAtIndex sectionIndex: Int,
    _ batchUpdateStage: BatchUpdateStage)
    -> CGRect?
  {
    let sectionMinY: CGFloat
    if sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(forSectionAtIndex: sectionIndex - 1, batchUpdateStage)
    }

    let sectionModelsPointer = self.sectionModelsPointer(batchUpdateStage)
    let sectionModels = sectionModelsPointer.assumingMemoryBound(
      to: SectionModel.self)

    var headerFrame = sectionModels[sectionIndex].calculateFrameForHeader()
    headerFrame?.origin.y += sectionMinY
    return headerFrame
  }

  func frameForBackground(
    inSectionAtIndex sectionIndex: Int,
    _ batchUpdateStage: BatchUpdateStage)
    -> CGRect?
  {
    let sectionMinY: CGFloat
    if sectionIndex == 0 {
      sectionMinY = 0
    } else {
      sectionMinY = sectionMaxY(forSectionAtIndex: sectionIndex - 1, batchUpdateStage)
    }

    let sectionModelsPointer = self.sectionModelsPointer(batchUpdateStage)
    let sectionModels = sectionModelsPointer.assumingMemoryBound(
      to: SectionModel.self)

    var backgroundFrame = sectionModels[sectionIndex].calculateFrameForBackground()
    backgroundFrame?.origin.y += sectionMinY
    return backgroundFrame
  }

  func updateMetrics(
    to sectionMetrics: MagazineLayoutSectionMetrics,
    forSectionAtIndex sectionIndex: Int)
  {
    currentSectionModels[sectionIndex].updateMetrics(to: sectionMetrics)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func updateItemSizeMode(to sizeMode: MagazineLayoutItemSizeMode, forItemAt indexPath: IndexPath) {
    currentSectionModels[indexPath.section].updateItemSizeMode(
      to: sizeMode,
      atIndex: indexPath.item)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: indexPath.section)
  }

  func updateItemHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forItemAt indexPath: IndexPath)
  {
    func updateItemHeight(
      toPreferredHeight preferredHeight: CGFloat,
      forItemAt indexPath: IndexPath,
      sectionModels: inout [SectionModel])
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

    switch preferredHeightUpdateContext(forPreferredHeightUpdateToItemAt: indexPath) {
    case .updatePreviousModels:
      updateItemHeight(
        toPreferredHeight: preferredHeight,
        forItemAt: indexPath,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      updateItemHeight(
        toPreferredHeight: preferredHeight,
        forItemAt: indexPath,
        sectionModels: &currentSectionModels)
    case let .updatePreviousAndCurrentModels(previousIndexPath, currentIndexPath):
      updateItemHeight(
        toPreferredHeight: preferredHeight,
        forItemAt: previousIndexPath,
        sectionModels: &sectionModelsBeforeBatchUpdates)
      updateItemHeight(
        toPreferredHeight: preferredHeight,
        forItemAt: currentIndexPath,
        sectionModels: &currentSectionModels)
    }
  }

  func setHeader(_ headerModel: HeaderModel, forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].setHeader(headerModel)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func removeHeader(forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].removeHeader()

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func updateHeaderHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forSectionAtIndex sectionIndex: Int)
  {
    guard sectionIndex < currentSectionModels.count else {
      assertionFailure("Updating the preferred height for a header model at section index \(sectionIndex) is out of bounds")
      return
    }

    currentSectionModels[sectionIndex].updateHeaderHeight(toPreferredHeight: preferredHeight)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
  }

  func setBackground(
    _ backgroundModel: BackgroundModel,
    forSectionAtIndex sectionIndex: Int)
  {
    currentSectionModels[sectionIndex].setBackground(backgroundModel)
  }

  func removeBackground(forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].removeBackground()
  }

  func setSections(_ sectionModels: [SectionModel]) {
    currentSectionModels = sectionModels

    invalidateEntireSectionMaxYsCache()

    allocateMemoryForSectionMaxYsCache()
  }

  func applyUpdates(
    _ updates: [CollectionViewUpdate<SectionModel, ItemModel>])
  {
    isPerformingBatchUpdates = true

    sectionModelsBeforeBatchUpdates = currentSectionModels

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
  }

  func clearInProgressBatchUpdateState() {
    sectionModelsBeforeBatchUpdates.removeAll()

    sectionIndicesToInsert.removeAll()
    sectionIndicesToDelete.removeAll()
    itemIndexPathsToInsert.removeAll()
    itemIndexPathsToDelete.removeAll()

    isPerformingBatchUpdates = false
  }

  // MARK: Private

  private enum PreferredHeightUpdateContext {
    case updatePreviousModels
    case updateCurrentModels
    case updatePreviousAndCurrentModels(previousIndexPath: IndexPath, currentIndexPath: IndexPath)
  }

  private var currentSectionModels = [SectionModel]()
  private var sectionModelsBeforeBatchUpdates = [SectionModel]()

  private var sectionMaxYsCache = [CGFloat?]()

  private func sectionModels(_ batchUpdateStage: BatchUpdateStage) -> [SectionModel] {
    switch batchUpdateStage {
    case .beforeUpdates: return sectionModelsBeforeBatchUpdates
    case .afterUpdates: return currentSectionModels
    }
  }

  private func sectionModelsPointer(
    _ batchUpdateStage: BatchUpdateStage)
    -> UnsafeMutableRawPointer
  {
    // Accessing these arrays using unsafe, untyped (raw) pointers
    // avoids expensive copy-on-writes and Swift retain / releases calls.
    switch batchUpdateStage {
    case .beforeUpdates: return UnsafeMutableRawPointer(mutating: &sectionModelsBeforeBatchUpdates)
    case .afterUpdates: return UnsafeMutableRawPointer(mutating: &currentSectionModels)
    }
  }

  private func preferredHeightUpdateContext(
    forPreferredHeightUpdateToItemAt indexPath: IndexPath)
    -> PreferredHeightUpdateContext
  {
    // iOS 12 fixes an issue that causes `UICollectionView` to provide preferred attributes for old,
    // invalid item index paths. This happens when an item is deleted, causing an off-screen,
    // unsized item to slide up into view. At this point, `UICollectionView` sizes that item since
    // it's now visible, but it provides the preferred attributes for the item's index path *before*
    // the delete batch update.
    // This issue actually causes `UICollectionViewFlowLayout` to crash on iOS 11 and earlier.
    // https://openradar.appspot.com/radar?id=5006149438930944
    // Related animation issue ticket: https://openradar.appspot.com/radar?id=4929660190195712
    // Once we drop support for iOS 11, we can delete everything outside of the
    // `#available(iOS 12.0, *)` check.
    if #available(iOS 12.0, *) {
      return .updateCurrentModels
    } else if !isPerformingBatchUpdates {
      return .updateCurrentModels
    } else {
      if
        itemIndexPathsToInsert.contains(indexPath) ||
        sectionIndicesToInsert.contains(indexPath.section)
      {
        // If an item is being inserted, or it's in a section that's being inserted, update its
        // height in the section models after batch updates, since it won't exist in the previous
        // section models.
        return .updateCurrentModels
      } else if
        itemIndexPathsToDelete.contains(indexPath) ||
        sectionIndicesToDelete.contains(indexPath.section)
      {
        // If an item is being deleted, or it's in a section that's being deleted, update its height
        // in the section models before batch updates, since it won't exist in the current section
        // models.
        return .updatePreviousModels
      } else if
        indexPath.section < sectionModelsBeforeBatchUpdates.count,
        indexPath.item < sectionModelsBeforeBatchUpdates[indexPath.section].numberOfItems,
        let previousItemModelID = idForItemModel(at: indexPath, .beforeUpdates),
        let currentIndexPath = indexPathForItemModel(
          withID: previousItemModelID,
          .afterUpdates)
      {
        // If an item was moved, then it will have an ID in the section models before batch updates,
        // and that ID will match an index path in the current section models. In this scenario, we
        // want to update the section models from before and after batch updates.
        return .updatePreviousAndCurrentModels(
          previousIndexPath: indexPath,
          currentIndexPath: currentIndexPath)
      }
    }

    return .updateCurrentModels
  }

  private func allocateMemoryForSectionMaxYsCache() {
    let arraySizeDelta = currentSectionModels.count - sectionMaxYsCache.count

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

  private func invalidateSectionMaxYsCacheForSectionIndices(startingAt sectionIndex: Int) {
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
      currentSectionModels.remove(at: reloadIndex)
      currentSectionModels.insert(sectionModel, at: reloadIndex)
    }
  }

  private func reloadItemModels(
    itemModelReloadIndexPathPairs: [(itemModel: ItemModel, reloadIndexPath: IndexPath)])
  {
    for (itemModel, reloadIndexPath) in itemModelReloadIndexPathPairs {
      currentSectionModels[reloadIndexPath.section].deleteItemModel(
        atIndex: reloadIndexPath.item)
      currentSectionModels[reloadIndexPath.section].insert(
        itemModel, atIndex:
        reloadIndexPath.item)
    }
  }

  private func deleteSectionModels(atIndices indicesOfSectionModelsToDelete: [Int]) {
    // Always delete in descending order
    for indexOfSectionModelToDelete in (indicesOfSectionModelsToDelete.sorted { $0 > $1 }) {
      currentSectionModels.remove(at: indexOfSectionModelToDelete)
    }
  }

  private func deleteItemModels(atIndexPaths indexPathsOfItemModelsToDelete: [IndexPath]) {
    // Always delete in descending order
    for indexPathOfItemModelToDelete in (indexPathsOfItemModelsToDelete.sorted { $0 > $1 }) {
      currentSectionModels[indexPathOfItemModelToDelete.section].deleteItemModel(
        atIndex: indexPathOfItemModelToDelete.item)
    }
  }

  private func insertSectionModels(
    sectionModelInsertIndexPairs: [(sectionModel: SectionModel, insertIndex: Int)])
  {
    // Always insert in ascending order
    for (sectionModel, insertIndex) in (sectionModelInsertIndexPairs.sorted { $0.insertIndex < $1.insertIndex }) {
      currentSectionModels.insert(sectionModel, at: insertIndex)
    }
  }

  private func insertItemModels(
    itemModelInsertIndexPathPairs: [(itemModel: ItemModel, insertIndexPath: IndexPath)])
  {
    // Always insert in ascending order
    for (itemModel, insertIndexPath) in (itemModelInsertIndexPathPairs.sorted { $0.insertIndexPath < $1.insertIndexPath }) {
      currentSectionModels[insertIndexPath.section].insert(itemModel, atIndex: insertIndexPath.item)
    }
  }

}
