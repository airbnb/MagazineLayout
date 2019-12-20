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

  func itemModelHeightModeDuringPreferredAttributesCheck(
    at indexPath: IndexPath)
    -> MagazineLayoutItemHeightMode?
  {
    func itemModelHeightModeDuringPreferredAttributesCheck(
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

    switch updateContextForItemPreferredHeightUpdate(at: indexPath) {
    case .updatePreviousModels, .updatePreviousAndCurrentModels:
      return itemModelHeightModeDuringPreferredAttributesCheck(
        at: indexPath,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      return itemModelHeightModeDuringPreferredAttributesCheck(
        at: indexPath,
        sectionModels: &currentSectionModels)
    }
  }

  func headerModelHeightModeDuringPreferredAttributesCheck(
    atSectionIndex sectionIndex: Int)
    -> MagazineLayoutHeaderHeightMode?
  {
    func headerModelHeightModeDuringPreferredAttributesCheck(
      atSectionIndex sectionIndex: Int,
      sectionModels: inout [SectionModel])
      -> MagazineLayoutHeaderHeightMode?
    {
      guard sectionIndex < sectionModels.count else {
        assertionFailure("Height mode for header at section index \(sectionIndex) is out of bounds")
        return nil
      }

      return sectionModels[sectionIndex].headerModel?.heightMode
    }

    switch updateContextForSupplementaryViewPreferredHeightUpdate(inSectionAtIndex: sectionIndex) {
    case .updatePreviousModels, .updatePreviousAndCurrentModels:
      return headerModelHeightModeDuringPreferredAttributesCheck(
        atSectionIndex: sectionIndex,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      return headerModelHeightModeDuringPreferredAttributesCheck(
        atSectionIndex: sectionIndex,
        sectionModels: &currentSectionModels)
    }
  }

  func footerModelHeightModeDuringPreferredAttributesCheck(
    atSectionIndex sectionIndex: Int)
    -> MagazineLayoutFooterHeightMode?
  {
    func footerModelHeightModeDuringPreferredAttributesCheck(
      atSectionIndex sectionIndex: Int,
      sectionModels: inout [SectionModel])
      -> MagazineLayoutFooterHeightMode?
    {
      guard sectionIndex < sectionModels.count else {
        assertionFailure("Height mode for footer at section index \(sectionIndex) is out of bounds")
        return nil
      }

      return sectionModels[sectionIndex].footerModel?.heightMode
    }

    switch updateContextForSupplementaryViewPreferredHeightUpdate(inSectionAtIndex: sectionIndex) {
    case .updatePreviousModels, .updatePreviousAndCurrentModels:
      return footerModelHeightModeDuringPreferredAttributesCheck(
        atSectionIndex: sectionIndex,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      return footerModelHeightModeDuringPreferredAttributesCheck(
        atSectionIndex: sectionIndex,
        sectionModels: &currentSectionModels)
    }
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

    switch updateContextForItemPreferredHeightUpdate(at: indexPath) {
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

  func itemLocationFramePairs(forItemsIn rect: CGRect) -> ElementLocationFramePairs {
    return elementLocationFramePairsForElements(
      in: rect,
      withElementLocationsForFlattenedIndices: itemLocationsForFlattenedIndices,
      andFramesProvidedBy: { itemLocation -> CGRect in
        return frameForItem(at: itemLocation, .afterUpdates)
      })
  }

  func headerLocationFramePairs(forHeadersIn rect: CGRect) -> ElementLocationFramePairs {
    return elementLocationFramePairsForElements(
      in: rect,
      withElementLocationsForFlattenedIndices: headerLocationsForFlattenedIndices,
      andFramesProvidedBy: { headerLocation -> CGRect in
        guard
          let headerFrame = frameForHeader(
            inSectionAtIndex: headerLocation.sectionIndex,
            .afterUpdates) else
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
            inSectionAtIndex: footerLocation.sectionIndex,
            .afterUpdates) else
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
            inSectionAtIndex: backgroundLocation.sectionIndex,
            .afterUpdates) else
        {
          assertionFailure("Expected a frame for background in section at \(backgroundLocation.sectionIndex)")
          return .zero
        }

        return backgroundFrame
      })
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

      let sectionModels = sectionModelsPointer.assumingMemoryBound(to: SectionModel.self)

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
    let sectionModels = sectionModelsPointer.assumingMemoryBound(to: SectionModel.self)

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
    let sectionModels = sectionModelsPointer.assumingMemoryBound(to: SectionModel.self)

    let currentVisibleBounds = currentVisibleBoundsProvider()
    var headerFrame = sectionModels[sectionIndex].calculateFrameForHeader(
      inSectionVisibleBounds: CGRect(
        x: currentVisibleBounds.minX,
        y: currentVisibleBounds.minY - sectionMinY,
        width: currentVisibleBounds.width,
        height: currentVisibleBounds.height))
    headerFrame?.origin.y += sectionMinY
    return headerFrame
  }

  func frameForFooter(
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
    let sectionModels = sectionModelsPointer.assumingMemoryBound(to: SectionModel.self)

    let currentVisibleBounds = currentVisibleBoundsProvider()
    var footerFrame = sectionModels[sectionIndex].calculateFrameForFooter(
      inSectionVisibleBounds: CGRect(
        x: currentVisibleBounds.minX,
        y: currentVisibleBounds.minY - sectionMinY,
        width: currentVisibleBounds.width,
        height: currentVisibleBounds.height))
    footerFrame?.origin.y += sectionMinY
    return footerFrame
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
    let sectionModels = sectionModelsPointer.assumingMemoryBound(to: SectionModel.self)

    var backgroundFrame = sectionModels[sectionIndex].calculateFrameForBackground()
    backgroundFrame?.origin.y += sectionMinY
    return backgroundFrame
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
    }

    switch updateContextForItemPreferredHeightUpdate(at: indexPath) {
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
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: indexPath.section)
    case let .updatePreviousAndCurrentModels(previousIndexPath, currentIndexPath):
      updateItemHeight(
        toPreferredHeight: preferredHeight,
        forItemAt: previousIndexPath,
        sectionModels: &sectionModelsBeforeBatchUpdates)
      updateItemHeight(
        toPreferredHeight: preferredHeight,
        forItemAt: currentIndexPath,
        sectionModels: &currentSectionModels)
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: currentIndexPath.section)
    }
  }

  func updateHeaderHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forSectionAtIndex sectionIndex: Int)
  {
    func updateHeaderHeight(
      toPreferredHeight preferredHeight: CGFloat,
      forSectionAtIndex sectionIndex: Int,
      sectionModels: inout [SectionModel])
    {
      guard sectionIndex < sectionModels.count else {
        assertionFailure("Updating the preferred height for a header model at section index \(sectionIndex) is out of bounds")
        return
      }

      sectionModels[sectionIndex].updateHeaderHeight(toPreferredHeight: preferredHeight)
    }

    switch updateContextForSupplementaryViewPreferredHeightUpdate(inSectionAtIndex: sectionIndex) {
    case .updatePreviousModels:
      updateHeaderHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: sectionIndex,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      updateHeaderHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: sectionIndex,
        sectionModels: &currentSectionModels)
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
    case let .updatePreviousAndCurrentModels(previousSectionIndex, currentSectionIndex):
      updateHeaderHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: previousSectionIndex,
        sectionModels: &sectionModelsBeforeBatchUpdates)
      updateHeaderHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: currentSectionIndex,
        sectionModels: &currentSectionModels)
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: currentSectionIndex)
    }
  }

  func updateFooterHeight(
    toPreferredHeight preferredHeight: CGFloat,
    forSectionAtIndex sectionIndex: Int)
  {
    func updateFooterHeight(
      toPreferredHeight preferredHeight: CGFloat,
      forSectionAtIndex sectionIndex: Int,
      sectionModels: inout [SectionModel])
    {
      guard sectionIndex < sectionModels.count else {
        assertionFailure("Updating the preferred height for a footer model at section index \(sectionIndex) is out of bounds")
        return
      }

      sectionModels[sectionIndex].updateFooterHeight(toPreferredHeight: preferredHeight)
    }

    switch updateContextForSupplementaryViewPreferredHeightUpdate(inSectionAtIndex: sectionIndex) {
    case .updatePreviousModels:
      updateFooterHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: sectionIndex,
        sectionModels: &sectionModelsBeforeBatchUpdates)
    case .updateCurrentModels:
      updateFooterHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: sectionIndex,
        sectionModels: &currentSectionModels)
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)
    case let .updatePreviousAndCurrentModels(previousSectionIndex, currentSectionIndex):
      updateFooterHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: previousSectionIndex,
        sectionModels: &sectionModelsBeforeBatchUpdates)
      updateFooterHeight(
        toPreferredHeight: preferredHeight,
        forSectionAtIndex: currentSectionIndex,
        sectionModels: &currentSectionModels)
      invalidateSectionMaxYsCacheForSectionIndices(startingAt: currentSectionIndex)
    }
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

  func setHeader(_ headerModel: HeaderModel, forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].setHeader(headerModel)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)

    prepareElementLocationsForFlattenedIndices()
  }

  func removeHeader(forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].removeHeader()

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)

    prepareElementLocationsForFlattenedIndices()
  }

  func setFooter(_ footerModel: FooterModel, forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].setFooter(footerModel)

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)

    prepareElementLocationsForFlattenedIndices()
  }

  func removeFooter(forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].removeFooter()

    invalidateSectionMaxYsCacheForSectionIndices(startingAt: sectionIndex)

    prepareElementLocationsForFlattenedIndices()
  }

  func setBackground(
    _ backgroundModel: BackgroundModel,
    forSectionAtIndex sectionIndex: Int)
  {
    currentSectionModels[sectionIndex].setBackground(backgroundModel)

    prepareElementLocationsForFlattenedIndices()
  }

  func removeBackground(forSectionAtIndex sectionIndex: Int) {
    currentSectionModels[sectionIndex].removeBackground()

    prepareElementLocationsForFlattenedIndices()
  }

  func setSections(_ sectionModels: [SectionModel]) {
    currentSectionModels = sectionModels

    invalidateEntireSectionMaxYsCache()
    allocateMemoryForSectionMaxYsCache()

    prepareElementLocationsForFlattenedIndices()
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

    prepareElementLocationsForFlattenedIndices()
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

  private enum ItemPreferredHeightUpdateContext {
    case updatePreviousModels
    case updateCurrentModels
    case updatePreviousAndCurrentModels(previousIndexPath: IndexPath, currentIndexPath: IndexPath)
  }

  private enum SupplementaryViewPreferredHeightUpdateContext {
    case updatePreviousModels
    case updateCurrentModels
    case updatePreviousAndCurrentModels(previousSectionIndex: Int, currentSectionIndex: Int)
  }

  private let currentVisibleBoundsProvider: () -> CGRect

  private var currentSectionModels = [SectionModel]()
  private var sectionModelsBeforeBatchUpdates = [SectionModel]()

  private var sectionMaxYsCache = [CGFloat?]()

  private var headerLocationsForFlattenedIndices = [Int: ElementLocation]()
  private var footerLocationsForFlattenedIndices = [Int: ElementLocation]()
  private var backgroundLocationsForFlattenedIndices = [Int: ElementLocation]()
  private var itemLocationsForFlattenedIndices = [Int: ElementLocation]()

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
    // avoids expensive copy-on-writes and Swift retain / release calls.
    switch batchUpdateStage {
    case .beforeUpdates: return UnsafeMutableRawPointer(mutating: &sectionModelsBeforeBatchUpdates)
    case .afterUpdates: return UnsafeMutableRawPointer(mutating: &currentSectionModels)
    }
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
    for sectionIndex in 0..<currentSectionModels.count {
      if currentSectionModels[sectionIndex].headerModel != nil {
        headerLocationsForFlattenedIndices[flattenedHeaderIndex] = ElementLocation(
          elementIndex: 0,
          sectionIndex: sectionIndex)
        flattenedHeaderIndex += 1
      }

      if currentSectionModels[sectionIndex].footerModel != nil {
        footerLocationsForFlattenedIndices[flattenedFooterIndex] = ElementLocation(
          elementIndex: 0,
          sectionIndex: sectionIndex)
        flattenedFooterIndex += 1
      }

      if currentSectionModels[sectionIndex].backgroundModel != nil {
        backgroundLocationsForFlattenedIndices[flattenedBackgroundIndex] = ElementLocation(
          elementIndex: 0,
          sectionIndex: sectionIndex)
        flattenedBackgroundIndex += 1
      }

      for itemIndex in 0..<currentSectionModels[sectionIndex].numberOfItems {
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

  private func updateContextForItemPreferredHeightUpdate(
    at indexPath: IndexPath)
    -> ItemPreferredHeightUpdateContext
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
        let currentIndexPath = indexPathForItemModel(withID: previousItemModelID, .afterUpdates)
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

  private func updateContextForSupplementaryViewPreferredHeightUpdate(
    inSectionAtIndex sectionIndex: Int)
    -> SupplementaryViewPreferredHeightUpdateContext
  {
    // An issue exists that causes `UICollectionView` to provide preferred attributes for old,
    // invalid supplementary view index paths. This happens when a section is deleted, causing an
    // off-screen, unsized supplementary view to slide up into view. At this point,
    // `UICollectionView` sizes that supplementary view since it's now visible, but it provides the
    // preferred attributes for the supplementary view's index path *before* the delete batch
    // update.
    // https://openradar.appspot.com/radar?id=5023315789873152
    if !isPerformingBatchUpdates {
      return .updateCurrentModels
    } else {
      if sectionIndicesToInsert.contains(sectionIndex) {
        // If a section is being inserted, update the supplementary view's height in the section
        // models after batch updates, since it won't exist in the previous section models.
        return .updateCurrentModels
      } else if sectionIndicesToDelete.contains(sectionIndex) {
        // If a section is being deleted, update the supplementary view's height in the section
        // models before batch updates, since it won't exist in the current section models.
        return .updatePreviousModels
      } else if
        sectionIndex < sectionModelsBeforeBatchUpdates.count,
        let previousSectionModelID = idForSectionModel(atIndex: sectionIndex, .beforeUpdates),
        let currentSectionIndex = indexForSectionModel(
          withID: previousSectionModelID,
          .afterUpdates)
      {
        // If a supplementary view was moved, then it will have an ID in the section models before
        // batch updates, and that ID will match a section index in the current section models. In
        // this scenario, we want to update the section models from before and after batch updates.
        return .updatePreviousAndCurrentModels(
          previousSectionIndex: sectionIndex,
          currentSectionIndex: currentSectionIndex)
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
