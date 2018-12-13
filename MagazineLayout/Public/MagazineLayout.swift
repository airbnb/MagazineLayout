// Created by bryankeller on 6/26/17.
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

/// A collection view layout that can display items in a grid and list arrangement.
///
/// Consumers should implement `UICollectionViewDelegateMagazineLayout`, which is used for all
/// `MagazineLayout` customizations.
///
/// Returning different `MagazineLayoutItemSizeMode`s from the delegate protocol implementation will
/// change how many items are displayed in a row and how each item sizes vertically.
public final class MagazineLayout: UICollectionViewLayout {

  // MARK: Public

  override public class  var layoutAttributesClass: AnyClass {
    return MagazineLayoutCollectionViewLayoutAttributes.self
  }

  override public class var invalidationContextClass: AnyClass {
    return MagazineLayoutInvalidationContext.self
  }

  override public var collectionViewContentSize: CGSize {
    let numberOfSections = modelState.numberOfSections(.afterUpdates)

    let width: CGFloat
    if let collectionView = collectionView {
      let contentInset = collectionView.contentInset
      width = collectionView.bounds.width - contentInset.left - contentInset.right
    } else {
      width = 0
    }

    let height: CGFloat
    if numberOfSections <= 0 {
      height = 0
    } else {
      height = modelState.sectionMaxY(forSectionAtIndex: numberOfSections - 1, .afterUpdates)
    }

    return CGSize(width: width, height: height)
  }

  override public func prepare() {
    super.prepare()

    guard !prepareActions.isEmpty else { return }

    // Save the previous collection view width if necessary
    if prepareActions.contains(.cachePreviousWidth) {
      cachedCollectionViewWidth = currentCollectionView.bounds.width
    }

    // Update layout metrics if necessary
    if
      prepareActions.contains(.updateLayoutMetrics) &&
      !prepareActions.contains(.recreateSectionModels) &&
      !prepareActions.contains(.lazilyCreateLayoutAttributes)
    {
      for sectionIndex in 0..<modelState.numberOfSections(.afterUpdates) {
        let sectionMetrics = metricsForSection(atIndex: sectionIndex)
        modelState.updateMetrics(to: sectionMetrics, forSectionAtIndex: sectionIndex)

        if let headerModel = headerModelForHeader(inSectionAtIndex: sectionIndex) {
          modelState.setHeader(headerModel, forSectionAtIndex: sectionIndex)
        } else {
          modelState.removeHeader(forSectionAtIndex: sectionIndex)
        }

        if let backgroundModel = backgroundModelForBackground(inSectionAtIndex: sectionIndex) {
          modelState.setBackground(backgroundModel, forSectionAtIndex: sectionIndex)
        } else {
          modelState.removeBackground(forSectionAtIndex: sectionIndex)
        }

        let numberOfItems = modelState.numberOfItems(inSectionAtIndex: sectionIndex, .afterUpdates)
        for itemIndex in 0..<numberOfItems {
          let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
          modelState.updateItemSizeMode(to: sizeModeForItem(at: indexPath), forItemAt: indexPath)
        }
      }
    }

    var newItemLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
    var newHeaderLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
    var newBackgroundLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()

    var sections = [SectionModel]()
    for sectionIndex in (0..<currentCollectionView.numberOfSections) {
      // Recreate section models from scratch if necessary
      if prepareActions.contains(.recreateSectionModels) {
        let sectionModel = sectionModelForSection(atIndex: sectionIndex)
        sections.append(sectionModel)
      }

      // Create header layout attributes if necessary
      if case let .visible(heightMode) = visibilityModeForHeader(inSectionAtIndex: sectionIndex) {
        let headerLocation = ElementLocation(elementIndex: 0, sectionIndex: sectionIndex)

        if let headerLayoutAttributes = headerLayoutAttributes[headerLocation] {
          newHeaderLayoutAttributes[headerLocation] = headerLayoutAttributes
        } else {
          newHeaderLayoutAttributes[headerLocation] = MagazineLayoutCollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionHeader,
            with: headerLocation.indexPath)
        }

        newHeaderLayoutAttributes[headerLocation]?.shouldVerticallySelfSize = heightMode == .dynamic
      }

      // Create background layout attributes if necessary
      if case .visible = visibilityModeForBackground(inSectionAtIndex: sectionIndex) {
        let backgroundLocation = ElementLocation(elementIndex: 0, sectionIndex: sectionIndex)

        if let attribute = backgroundLayoutAttributes[backgroundLocation] {
          newBackgroundLayoutAttributes[backgroundLocation] = attribute
        } else {
          newBackgroundLayoutAttributes[backgroundLocation] = MagazineLayoutCollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionBackground,
            with: backgroundLocation.indexPath)
        }

        newBackgroundLayoutAttributes[backgroundLocation]?.shouldVerticallySelfSize = false
      }

      // Create item layout attributes if necessary
      for itemIndex in (0..<currentCollectionView.numberOfItems(inSection: sectionIndex)) {
        let itemLocation = ElementLocation(elementIndex: itemIndex, sectionIndex: sectionIndex)

        if let itemLayoutAttributes = itemLayoutAttributes[itemLocation] {
          newItemLayoutAttributes[itemLocation] = itemLayoutAttributes
        } else {
          newItemLayoutAttributes[itemLocation] = MagazineLayoutCollectionViewLayoutAttributes(
            forCellWith: itemLocation.indexPath)
        }

        let itemHeightMode = sizeModeForItem(at: itemLocation.indexPath).heightMode
        if case .static = itemHeightMode {
          newItemLayoutAttributes[itemLocation]?.shouldVerticallySelfSize = false
        } else {
          newItemLayoutAttributes[itemLocation]?.shouldVerticallySelfSize = true
        }
      }
    }

    if prepareActions.contains(.recreateSectionModels) {
      modelState.setSections(sections)
    }

    if prepareActions.contains(.lazilyCreateLayoutAttributes) {
      headerLayoutAttributes = newHeaderLayoutAttributes
      backgroundLayoutAttributes = newBackgroundLayoutAttributes
      itemLayoutAttributes = newItemLayoutAttributes
    }

    prepareActions = []
  }

  override public func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    saveCurrentLayoutAttributesAsPreviousLayoutAttributes()

    var updates = [CollectionViewUpdate<SectionModel, ItemModel>]()

    for updateItem in updateItems {
      let updateAction = updateItem.updateAction
      let indexPathBeforeUpdate = updateItem.indexPathBeforeUpdate
      let indexPathAfterUpdate = updateItem.indexPathAfterUpdate

      if updateAction == .reload {
        guard let indexPath = indexPathBeforeUpdate else {
          assertionFailure("`indexPathBeforeUpdate` cannot be `nil` for a `.reload` update action")
          return
        }

        if indexPath.item == NSNotFound {
          let sectionModel = sectionModelForSection(atIndex: indexPath.section)
          updates.append(.sectionReload(sectionIndex: indexPath.section, newSection: sectionModel))
        } else {
          let itemModel = itemModelForItem(at: indexPath)
          updates.append(.itemReload(itemIndexPath: indexPath, newItem: itemModel))
        }
      }

      if updateAction == .delete {
        guard let indexPath = indexPathBeforeUpdate else {
          assertionFailure("`indexPathBeforeUpdate` cannot be `nil` for a `.delete` update action")
          return
        }

        if indexPath.item == NSNotFound {
          updates.append(.sectionDelete(sectionIndex: indexPath.section))
        } else {
          updates.append(.itemDelete(itemIndexPath: indexPath))
        }
      }

      if updateAction == .insert {
        guard let indexPath = indexPathAfterUpdate else {
          assertionFailure("`indexPathAfterUpdate` cannot be `nil` for an `.insert` update action")
          return
        }

        if indexPath.item == NSNotFound {
          let sectionModel = sectionModelForSection(atIndex: indexPath.section)
          updates.append(.sectionInsert(sectionIndex: indexPath.section, newSection: sectionModel))
        } else {
          let itemModel = itemModelForItem(at: indexPath)
          updates.append(.itemInsert(itemIndexPath: indexPath, newItem: itemModel))
        }
      }

      if updateAction == .move {
        guard
          let initialIndexPath = indexPathBeforeUpdate,
          let finalIndexPath = indexPathAfterUpdate else
        {
          assertionFailure("`indexPathBeforeUpdate` and `indexPathAfterUpdate` cannot be `nil` for a `.move` update action")
          return
        }

        if initialIndexPath.item == NSNotFound && finalIndexPath.item == NSNotFound {
          updates.append(.sectionMove(
            initialSectionIndex: initialIndexPath.section,
            finalSectionIndex: finalIndexPath.section))
        } else {
          updates.append(.itemMove(
            initialItemIndexPath: initialIndexPath,
            finalItemIndexPath: finalIndexPath))
        }
      }
    }

    modelState.applyUpdates(updates)

    super.prepare(forCollectionViewUpdates: updateItems)
  }

  override public func finalizeCollectionViewUpdates() {
    clearPreviousLayoutAttributes()
    modelState.clearInProgressBatchUpdateState()

    super.finalizeCollectionViewUpdates()
  }

  override public func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
    saveCurrentLayoutAttributesAsPreviousLayoutAttributes()

    super.prepare(forAnimatedBoundsChange: oldBounds)
  }

  override public func finalizeAnimatedBoundsChange() {
    clearPreviousLayoutAttributes()

    super.finalizeAnimatedBoundsChange()
  }

  override public func layoutAttributesForElements(
    in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]?
  {
    var layoutAttributesInRect = [UICollectionViewLayoutAttributes]()

    for headerLocationAndFramePair in modelState.headerFrameInfo(forHeadersIn: rect) {
      let headerLocation = headerLocationAndFramePair.elementLocation
      let headerFrame = headerLocationAndFramePair.frame

      guard let layoutAttributes = headerLayoutAttributes[headerLocation] else {
        continue
      }

      layoutAttributes.frame = headerFrame
      layoutAttributesInRect.append(layoutAttributes)
    }

    for backgroundLocationAndFramePair in modelState.backgroundFrameInfo(forBackgroundsIn: rect) {
      let backgroundLocation = backgroundLocationAndFramePair.elementLocation
      let backgroundFrame = backgroundLocationAndFramePair.frame

      guard let layoutAttributes = backgroundLayoutAttributes[backgroundLocation] else {
        continue
      }

      layoutAttributes.frame = backgroundFrame
      layoutAttributesInRect.append(layoutAttributes)
    }

    for itemLocationAndFramePair in modelState.itemFrameInfo(forItemsIn: rect) {
      let itemLocation = itemLocationAndFramePair.elementLocation
      let itemFrame = itemLocationAndFramePair.frame

      guard let layoutAttributes = itemLayoutAttributes[itemLocation] else {
        continue
      }

      layoutAttributes.frame = itemFrame
      layoutAttributesInRect.append(layoutAttributes)
    }

    return layoutAttributesInRect
  }

  override public func layoutAttributesForItem(
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let itemLocation = ElementLocation(indexPath: indexPath)
    let layoutAttributes = itemLayoutAttributes[itemLocation]

    guard
      indexPath.section < modelState.numberOfSections(.afterUpdates),
      indexPath.item < modelState.numberOfItems(inSectionAtIndex: indexPath.section, .afterUpdates) else
    {
      // On iOS 9, `layoutAttributesForItem(at:)` can be invoked for an index path of a new item
      // before the layout is notified of this new item (through either `prepare` or
      // `prepare(forCollectionViewUpdates:)`). This seems to be fixed in iOS 10 and higher.
      assertionFailure("`{\(indexPath.section), \(indexPath.item)}` is out of bounds of the section models / item models array.")

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollecionView`, which is why we don't return `nil` here.
      return layoutAttributes
    }

    layoutAttributes?.frame = modelState.frameForItem(at: itemLocation, .afterUpdates)

    return layoutAttributes
  }

  override public func layoutAttributesForSupplementaryView(
    ofKind elementKind: String,
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let elementLocation = ElementLocation(indexPath: indexPath)
    if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionHeader,
      let headerLayoutAttributes = headerLayoutAttributes[elementLocation],
      let headerFrame = modelState.frameForHeader(
        inSectionAtIndex: elementLocation.sectionIndex,
        .afterUpdates)
    {
      headerLayoutAttributes.frame = headerFrame
      return headerLayoutAttributes
    } else if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionBackground,
      let backgroundLayoutAttributes = backgroundLayoutAttributes[elementLocation],
      let backgroundFrame = modelState.frameForBackground(
        inSectionAtIndex: elementLocation.sectionIndex,
        .afterUpdates)
    {
      backgroundLayoutAttributes.frame = backgroundFrame
      return backgroundLayoutAttributes
    } else {
      return nil
    }
  }

  override public func initialLayoutAttributesForAppearingItem(
    at itemIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    if
      modelState.itemIndexPathsToInsert.contains(itemIndexPath) ||
      modelState.sectionIndicesToInsert.contains(itemIndexPath.section)
    {
      let attributes = layoutAttributesForItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      attributes?.alpha = 0
      return attributes
    } else if
      let movedItemID = modelState.idForItemModel(at: itemIndexPath, .afterUpdates),
      let initialIndexPath = modelState.indexPathForItemModel(
        withID: movedItemID,
        .beforeUpdates)
    {
      return previousLayoutAttributesForItem(at: initialIndexPath)?.copy() as? UICollectionViewLayoutAttributes
    } else {
      return nil
    }
  }

  override public func finalLayoutAttributesForDisappearingItem(
    at itemIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    if
      modelState.itemIndexPathsToDelete.contains(itemIndexPath) ||
      modelState.sectionIndicesToDelete.contains(itemIndexPath.section)
    {
      let attributes = previousLayoutAttributesForItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      attributes?.alpha = 0
      return attributes
    } else if
      let movedItemID = modelState.idForItemModel(at: itemIndexPath, .beforeUpdates),
      let finalIndexPath = modelState.indexPathForItemModel(
        withID: movedItemID,
        .afterUpdates)
    {
      return layoutAttributesForItem(at: finalIndexPath)?.copy() as? UICollectionViewLayoutAttributes
    } else {
      return nil
    }
  }

  override public func initialLayoutAttributesForAppearingSupplementaryElement(
    ofKind elementKind: String,
    at elementIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    if modelState.sectionIndicesToInsert.contains(elementIndexPath.section) {
      let attributes = layoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      attributes?.alpha = 0
      return attributes
    } else if
      let movedSectionID = modelState.idForSectionModel(
        atIndex: elementIndexPath.section,
        .afterUpdates),
      let initialSectionIndex = modelState.indexForSectionModel(
        withID: movedSectionID,
        .beforeUpdates)
    {
      let initialIndexPath = IndexPath(item: 0, section: initialSectionIndex)
      return previousLayoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: initialIndexPath)?.copy() as? UICollectionViewLayoutAttributes
    } else {
      return previousLayoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
    }
  }

  override public func finalLayoutAttributesForDisappearingSupplementaryElement(
    ofKind elementKind: String,
    at elementIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    if modelState.sectionIndicesToDelete.contains(elementIndexPath.section) {
      let attributes = previousLayoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      attributes?.alpha = 0
      return attributes
    } else if
      let movedSectionID = modelState.idForSectionModel(
        atIndex: elementIndexPath.section,
        .beforeUpdates),
      let finalSectionIndex = modelState.indexForSectionModel(
        withID: movedSectionID,
        .afterUpdates)
    {
      let finalIndexPath = IndexPath(item: 0, section: finalSectionIndex)
      return layoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: finalIndexPath)?.copy() as? UICollectionViewLayoutAttributes
    }  else {
      return layoutAttributesForSupplementaryView(
       ofKind: elementKind,
        at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
    }
  }

  override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return collectionView?.bounds.size.width != .some(newBounds.size.width)
  }

  override public func invalidationContext(
    forBoundsChange newBounds: CGRect)
    -> UICollectionViewLayoutInvalidationContext
  {
    let invalidationContext = super.invalidationContext(
      forBoundsChange: newBounds) as! MagazineLayoutInvalidationContext

    invalidationContext.contentSizeAdjustment = CGSize(
      width: newBounds.width - currentCollectionView.bounds.width,
      height: newBounds.height - currentCollectionView.bounds.height)
    invalidationContext.invalidateLayoutMetrics = false

    return invalidationContext
  }

  override public func shouldInvalidateLayout(
    forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
    withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes)
    -> Bool
  {
    let hasNewPreferredHeight = preferredAttributes.size.height.rounded() != originalAttributes.size.height.rounded()

    switch (preferredAttributes.representedElementCategory, preferredAttributes.representedElementKind) {
    case (.cell, nil):
      let itemHeightMode = modelState.itemModelHeightModeForPreferredAttributesCheck(
        at: preferredAttributes.indexPath)
      switch itemHeightMode {
      case .some(.static):
        return false
      case .some(.dynamic):
        return hasNewPreferredHeight
      case .some(.dynamicAndStretchToTallestItemInRow):
        let currentPreferredHeight = modelState.itemModelPreferredHeightDuringPreferredAttributesCheck(
          at: preferredAttributes.indexPath)
        let hasPreferredHeightChanged = preferredAttributes.size.height.rounded() != currentPreferredHeight?.rounded()
        return hasNewPreferredHeight && hasPreferredHeightChanged
      case nil:
        return false
      }

    case (.supplementaryView, MagazineLayout.SupplementaryViewKind.sectionHeader):
      let headerHeightMode = modelState.headerModelHeightModeDuringPreferredAttributesCheck(
        atSectionIndex: preferredAttributes.indexPath.section)
      return headerHeightMode == .dynamic

    case (.supplementaryView, MagazineLayout.SupplementaryViewKind.sectionBackground):
      return false

    default:
      assertionFailure("`MagazineLayout` only supports cells, headers, and backgrounds")
      return false
    }
  }

  override public func invalidationContext(
    forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
    withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutInvalidationContext
  {
    switch preferredAttributes.representedElementCategory {
    case .cell:
      modelState.updateItemHeight(
        toPreferredHeight: preferredAttributes.size.height,
        forItemAt: preferredAttributes.indexPath)
    case .supplementaryView:
      modelState.updateHeaderHeight(
        toPreferredHeight: preferredAttributes.size.height,
        forSectionAtIndex: preferredAttributes.indexPath.section)
    case .decorationView:
      assertionFailure("`MagazineLayout` does not support decoration views")
    }

    let context = super.invalidationContext(
      forPreferredLayoutAttributes: preferredAttributes,
      withOriginalAttributes: originalAttributes) as! MagazineLayoutInvalidationContext

    context.invalidateLayoutMetrics = false

    return context
  }

  override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    guard let context = context as? MagazineLayoutInvalidationContext else {
      assertionFailure("`context` must be an instance of `MagazineLayoutInvalidationContext`")
      return
    }

    if context.invalidateEverything {
      prepareActions.formUnion([.recreateSectionModels, .lazilyCreateLayoutAttributes])
    }

    if context.invalidateDataSourceCounts {
      prepareActions.formUnion(.lazilyCreateLayoutAttributes)
    }

    // Checking `cachedCollectionViewWidth != collectionView?.bounds.size.width` is necessary
    // because the collection view's width can change without a `contentSizeAdjustment` occuring.
    if
      context.contentSizeAdjustment.width != 0 ||
      cachedCollectionViewWidth != collectionView?.bounds.size.width
    {
      prepareActions.formUnion([.updateLayoutMetrics, .cachePreviousWidth])
    }

    if context.invalidateLayoutMetrics {
      prepareActions.formUnion([.updateLayoutMetrics])
    }

    super.invalidateLayout(with: context)
  }

  // MARK: Private

  private var currentCollectionView: UICollectionView {
    guard let collectionView = collectionView else {
      preconditionFailure("`collectionView` should not be `nil`")
    }

    return collectionView
  }

  private let modelState = ModelState()
  private var cachedCollectionViewWidth: CGFloat?

  // The current layout attributes after batch updates have started and after they finish
  private var headerLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var backgroundLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var itemLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()

  // The previous layout attributes from before batch updates started
  // Used in `initialLayoutAttributesForAppearing*` and `finalLayoutAttributesForDisappearing*`
  private var previousItemLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var previousHeaderLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var previousBackgroundLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()

  private struct PrepareActions: OptionSet {
    let rawValue: UInt

    static let recreateSectionModels = PrepareActions(rawValue: 1 << 0)
    static let lazilyCreateLayoutAttributes = PrepareActions(rawValue: 1 << 1)
    static let updateLayoutMetrics = PrepareActions(rawValue: 1 << 2)
    static let cachePreviousWidth = PrepareActions(rawValue: 1 << 3)
  }
  private var prepareActions: PrepareActions = []

  private var delegateMagazineLayout: UICollectionViewDelegateMagazineLayout? {
    return currentCollectionView.delegate as? UICollectionViewDelegateMagazineLayout
  }

  private func metricsForSection(atIndex sectionIndex: Int) -> MagazineLayoutSectionMetrics {
    guard let delegateMagazineLayout = delegateMagazineLayout else {
      return MagazineLayoutSectionMetrics.defaultSectionMetrics(
        forCollectionViewWidth: currentCollectionView.bounds.width)
    }

    return MagazineLayoutSectionMetrics(
      forSectionAtIndex: sectionIndex,
      in: currentCollectionView,
      layout: self,
      delegate: delegateMagazineLayout)
  }

  private func sizeModeForItem(at indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
    guard let delegateMagazineLayout = delegateMagazineLayout else {
      return MagazineLayoutItemSizeMode(
        widthMode: MagazineLayout.Default.ItemSizeMode.widthMode,
        heightMode: .static(height: MagazineLayout.Default.ItemHeight))
    }

    return delegateMagazineLayout.collectionView(
      currentCollectionView,
      layout: self,
      sizeModeForItemAt: indexPath)
  }

  private func initialItemHeight(from itemSizeMode: MagazineLayoutItemSizeMode) -> CGFloat {
    switch itemSizeMode.heightMode {
    case let .static(staticHeight):
      return staticHeight
    case .dynamic, .dynamicAndStretchToTallestItemInRow:
      return MagazineLayout.Default.ItemHeight
    }
  }

  private func visibilityModeForHeader(
    inSectionAtIndex sectionIndex: Int)
    -> MagazineLayoutHeaderVisibilityMode
  {
    guard let delegateMagazineLayout = delegateMagazineLayout else {
      return MagazineLayout.Default.HeaderVisibilityMode
    }

    return delegateMagazineLayout.collectionView(
      currentCollectionView,
      layout: self,
      visibilityModeForHeaderInSectionAtIndex: sectionIndex)
  }

  private func visibilityModeForBackground(
    inSectionAtIndex sectionIndex: Int)
    -> MagazineLayoutBackgroundVisibilityMode
  {
    guard let delegateMagazineLayout = delegateMagazineLayout else {
      return MagazineLayout.Default.BackgroundVisibilityMode
    }

    return delegateMagazineLayout.collectionView(
      currentCollectionView,
      layout: self,
      visibilityModeForBackgroundInSectionAtIndex: sectionIndex)
  }

  private func headerHeight(from headerHeightMode: MagazineLayoutHeaderHeightMode) -> CGFloat {
    switch headerHeightMode {
    case let .static(staticHeight):
      return staticHeight
    case .dynamic:
      return MagazineLayout.Default.HeaderHeight
    }
  }

  private func sectionModelForSection(atIndex sectionIndex: Int) -> SectionModel {
    let itemModels = (0..<currentCollectionView.numberOfItems(inSection: sectionIndex)).map {
      itemModelForItem(at: IndexPath(item: $0, section: sectionIndex))
    }

    return SectionModel(
      itemModels: itemModels,
      headerModel: headerModelForHeader(inSectionAtIndex: sectionIndex),
      backgroundModel: backgroundModelForBackground(inSectionAtIndex: sectionIndex),
      metrics: metricsForSection(atIndex: sectionIndex))
  }

  private func itemModelForItem(at indexPath: IndexPath) -> ItemModel {
    let itemSizeMode = sizeModeForItem(at: indexPath)
    return ItemModel(
      sizeMode: itemSizeMode,
      height: initialItemHeight(from: itemSizeMode))
  }

  private func headerModelForHeader(
    inSectionAtIndex sectionIndex: Int)
    -> HeaderModel?
  {
    let headerVisibilityMode = visibilityModeForHeader(inSectionAtIndex: sectionIndex)
    switch headerVisibilityMode {
    case let .visible(heightMode):
      return HeaderModel(
        heightMode: heightMode,
        height: headerHeight(from: heightMode))
    case .hidden:
      return nil
    }
  }

  private func backgroundModelForBackground(
    inSectionAtIndex sectionIndex: Int)
    -> BackgroundModel?
  {
    let backgroundVisibilityMode = visibilityModeForBackground(inSectionAtIndex: sectionIndex)
    switch backgroundVisibilityMode {
    case .visible:
      return BackgroundModel()
    case .hidden:
      return nil
    }
  }

  private func saveCurrentLayoutAttributesAsPreviousLayoutAttributes() {
    for (itemLocation, layoutAttributes) in itemLayoutAttributes {
      let copiedLayoutAttributes = layoutAttributes.copy() as? MagazineLayoutCollectionViewLayoutAttributes
      previousItemLayoutAttributes[itemLocation] = copiedLayoutAttributes
    }

    for (headerLocation, layoutAttributes) in headerLayoutAttributes {
      let copiedLayoutAttributes = layoutAttributes.copy() as? MagazineLayoutCollectionViewLayoutAttributes
      previousHeaderLayoutAttributes[headerLocation] = copiedLayoutAttributes
    }

    for (backgroundLocation, layoutAttributes) in backgroundLayoutAttributes {
      let copiedLayoutAttributes = layoutAttributes.copy() as? MagazineLayoutCollectionViewLayoutAttributes
      previousBackgroundLayoutAttributes[backgroundLocation] = copiedLayoutAttributes
    }
  }

  private func clearPreviousLayoutAttributes() {
    previousHeaderLayoutAttributes.removeAll()
    previousBackgroundLayoutAttributes.removeAll()
    previousItemLayoutAttributes.removeAll()
  }

  private func previousLayoutAttributesForItem(
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    guard modelState.isPerformingBatchUpdates else {
      // TODO(bryankeller): Look into whether this happens on iOS 10. It definitely does on iOS 9.
      return nil
    }

    let itemLocation = ElementLocation(indexPath: indexPath)
    let layoutAttributes = previousItemLayoutAttributes[itemLocation]

    guard
      indexPath.section < modelState.numberOfSections(.beforeUpdates),
      indexPath.item < modelState.numberOfItems(inSectionAtIndex: indexPath.section, .beforeUpdates) else
    {
      // On iOS 9, `layoutAttributesForItem(at:)` can be invoked for an index path of a new item
      // before the layout is notified of this new item (through either `prepare` or
      // `prepare(forCollectionViewUpdates:)`). This seems to be fixed in iOS 10 and higher.
      assertionFailure("`{\(indexPath.section), \(indexPath.item)}` is out of bounds of the section models / item models array.")

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollecionView`, which is why we don't return `nil` here.
      return layoutAttributes
    }

    layoutAttributes?.frame = modelState.frameForItem(at: itemLocation, .beforeUpdates)

    return layoutAttributes
  }

  private func previousLayoutAttributesForSupplementaryView(
    ofKind elementKind: String,
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    guard modelState.isPerformingBatchUpdates else {
      // TODO(bryankeller): Look into whether this happens on iOS 10. It definitely does on iOS 9.
      return nil
    }

    let elementLocation = ElementLocation(indexPath: indexPath)

    if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionHeader,
      let headerLayoutAttributes = previousHeaderLayoutAttributes[elementLocation],
      let headerFrame = modelState.frameForHeader(
        inSectionAtIndex: elementLocation.sectionIndex,
        .beforeUpdates)
    {
      headerLayoutAttributes.frame = headerFrame
      return headerLayoutAttributes
    } else if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionBackground,
      let backgroundLayoutAttributes = previousBackgroundLayoutAttributes[elementLocation],
      let backgroundFrame = modelState.frameForBackground(
        inSectionAtIndex: elementLocation.sectionIndex,
        .beforeUpdates)
    {
      backgroundLayoutAttributes.frame = backgroundFrame
      return backgroundLayoutAttributes
    } else {
      return nil
    }
  }

}
