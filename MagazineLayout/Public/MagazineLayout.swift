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

  // MARK: Lifecycle

  /// - Parameters:
  ///   - flipsHorizontallyInOppositeLayoutDirection: Indicates whether the horizontal coordinate
  ///     system is automatically flipped at appropriate times. In practice, this is used to support
  ///     right-to-left layout.
  public init(flipsHorizontallyInOppositeLayoutDirection: Bool = true) {
    _flipsHorizontallyInOppositeLayoutDirection = flipsHorizontallyInOppositeLayoutDirection
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    _flipsHorizontallyInOppositeLayoutDirection = true
    super.init(coder: aDecoder)
  }

  // MARK: Public
  
  /// The vertical layout direction of items in the collection view. This property changes the behavior of
  /// scroll-position-preservation when performing batch updates or when the collection view's bounds changes.
  public var verticalLayoutDirection = MagazineLayoutVerticalLayoutDirection.topToBottom

  override public class var layoutAttributesClass: AnyClass {
    return MagazineLayoutCollectionViewLayoutAttributes.self
  }

  override public class var invalidationContextClass: AnyClass {
    return MagazineLayoutInvalidationContext.self
  }

  override public var flipsHorizontallyInOppositeLayoutDirection: Bool {
    return _flipsHorizontallyInOppositeLayoutDirection
  }

  override public var collectionViewContentSize: CGSize {
    guard collectionView != nil else { return .zero }
    return layoutState.contentSize
  }

  override public func prepare() {
    super.prepare()

    // Save the previous collection view width if necessary
    if prepareActions.contains(.cachePreviousWidth) {
      cachedCollectionViewWidth = currentCollectionView.bounds.width
    }

    if
      prepareActions.contains(.updateLayoutMetrics) ||
      prepareActions.contains(.recreateSectionModels)
    {
      hasPinnedHeaderOrFooter = false
    }

    // Update layout metrics if necessary
    if prepareActions.contains(.updateLayoutMetrics) {
      for sectionIndex in 0..<modelState.numberOfSections {
        let sectionMetrics = metricsForSection(atIndex: sectionIndex)
        modelState.updateMetrics(to: sectionMetrics, forSectionAtIndex: sectionIndex)

        if let headerModel = headerModelForHeader(inSectionAtIndex: sectionIndex) {
          modelState.setHeader(headerModel, forSectionAtIndex: sectionIndex)
        } else {
          modelState.removeHeader(forSectionAtIndex: sectionIndex)
        }

        if let footerModel = footerModelForFooter(inSectionAtIndex: sectionIndex) {
          modelState.setFooter(footerModel, forSectionAtIndex: sectionIndex)
        } else {
          modelState.removeFooter(forSectionAtIndex: sectionIndex)
        }

        if let backgroundModel = backgroundModelForBackground(inSectionAtIndex: sectionIndex) {
          modelState.setBackground(backgroundModel, forSectionAtIndex: sectionIndex)
        } else {
          modelState.removeBackground(forSectionAtIndex: sectionIndex)
        }

        let numberOfItems = modelState.numberOfItems(inSectionAtIndex: sectionIndex)
        for itemIndex in 0..<numberOfItems {
          let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
          modelState.updateItemSizeMode(to: sizeModeForItem(at: indexPath), forItemAt: indexPath)
        }
      }
    }

    // Recreate section models from scratch if necessary
    if prepareActions.contains(.recreateSectionModels) {
      layoutStateBeforeRecreateSectionModels = LayoutState(
        modelState: layoutState.modelState.copy(),
        bounds: currentCollectionView.bounds,
        contentInset: contentInset,
        scale: scale,
        verticalLayoutDirection: verticalLayoutDirection)

      var sections = [SectionModel]()
      for sectionIndex in 0..<currentCollectionView.numberOfSections {
        let sectionModel = sectionModelForSection(atIndex: sectionIndex)
        sections.append(sectionModel)
      }

      modelState.setSections(sections)
    }

    prepareActions = []
  }

  override public func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    let layoutStateBeforeCollectionViewUpdates = LayoutState(
      modelState: layoutState.modelState.copy(),
      bounds: currentCollectionView.bounds,
      contentInset: contentInset,
      scale: scale,
      verticalLayoutDirection: verticalLayoutDirection)
    self.layoutStateBeforeCollectionViewUpdates = layoutStateBeforeCollectionViewUpdates

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

    modelState.applyUpdates(
      updates,
      modelStateBeforeBatchUpdates: layoutStateBeforeCollectionViewUpdates.modelState)
    hasDataSourceCountInvalidationBeforeReceivingUpdateItems = false

    super.prepare(forCollectionViewUpdates: updateItems)
  }

  override public func finalizeCollectionViewUpdates() {
    modelState.clearInProgressBatchUpdateState()

    itemLayoutAttributesForPendingAnimations.removeAll()
    supplementaryViewLayoutAttributesForPendingAnimations.removeAll()

    if let layoutStateBeforeCollectionViewUpdates{
      let targetContentOffsetAnchor = layoutStateBeforeCollectionViewUpdates.targetContentOffsetAnchor
      let targetYOffset = layoutState.yOffset(
        for: targetContentOffsetAnchor,
        isPerformingBatchUpdates: true)
      let context = MagazineLayoutInvalidationContext()
      context.invalidateLayoutMetrics = false
      context.contentOffsetAdjustment.y = targetYOffset - layoutState.bounds.minY
      invalidateLayout(with: context)
    }

    targetContentOffsetCompensatingYOffsetForAppearingItem = nil

    layoutStateBeforeCollectionViewUpdates = nil

    super.finalizeCollectionViewUpdates()
  }

  override public func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
    super.prepare(forAnimatedBoundsChange: oldBounds)

    if currentCollectionView.bounds.size != oldBounds.size {
      layoutStateBeforeAnimatedBoundsChange = LayoutState(
        modelState: layoutState.modelState.copy(),
        bounds: oldBounds,
        contentInset: contentInset,
        scale: scale,
        verticalLayoutDirection: verticalLayoutDirection)
    }
  }

  override public func finalizeAnimatedBoundsChange() {
    layoutStateBeforeAnimatedBoundsChange = nil

    super.finalizeAnimatedBoundsChange()
  }

  override public func layoutAttributesForElements(
    in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]?
  {
    // This early return prevents an issue that causes overlapping / misplaced elements after an
    // off-screen batch update occurs. The root cause of this issue is that `UICollectionView`
    // expects `layoutAttributesForElementsInRect:` to return post-batch-update layout attributes
    // immediately after an update is sent to the collection view via the insert/delete/reload/move
    // functions. Unfortunately, this is impossible - when batch updates occur, `invalidateLayout:`
    // is invoked immediately with a context that has `invalidateDataSourceCounts` set to `true`.
    // At this time, `MagazineLayout` has no way of knowing the details of this data source count
    // change (where the insert/delete/move took place). `MagazineLayout` only gets this additional
    // information once `prepareForCollectionViewUpdates:` is invoked. At that time, we're able to
    // update our layout's source of truth, the `ModelState`, which allows us to resolve the
    // post-batch-update layout and return post-batch-update layout attributes from this function.
    // Between the time that `invalidateLayout:` is invoked with `invalidateDataSourceCounts` set to
    // `true`, and when `prepareForCollectionViewUpdates:` is invoked with details of the updates,
    // `layoutAttributesForElementsInRect:` is invoked with the expectation that we already have a
    // fully resolved layout. If we return incorrect layout attributes at that time, then we'll have
    // overlapping elements / visual defects. To prevent this, we can return `nil` in this
    // situation, which works around the bug.
    // `UICollectionViewCompositionalLayout`, in classic UIKit fashion, avoids this bug / feature by
    // implementing the private function
    // `_prepareForCollectionViewUpdates:withDataSourceTranslator:`, which provides the layout with
    // details about the updates to the collection view before `layoutAttributesForElementsInRect:`
    // is invoked, enabling them to resolve their layout in time.
    guard !hasDataSourceCountInvalidationBeforeReceivingUpdateItems else { return nil }

    var layoutAttributesInRect = [UICollectionViewLayoutAttributes]()

    let headerLocationFramePairs = modelState.headerLocationFramePairs(forHeadersIn: rect)
    for headerLocationFramePair in headerLocationFramePairs {
      let headerLocation = headerLocationFramePair.elementLocation
      let headerFrame = headerLocationFramePair.frame

      if let layoutAttributes = headerLayoutAttributes(for: headerLocation, frame: headerFrame) {
        layoutAttributesInRect.append(layoutAttributes)
      }
    }

    let footerLocationFramePairs = modelState.footerLocationFramePairs(forFootersIn: rect)
    for footerLocationFramePair in footerLocationFramePairs {
      let footerLocation = footerLocationFramePair.elementLocation
      let footerFrame = footerLocationFramePair.frame

      if let layoutAttributes = footerLayoutAttributes(for: footerLocation, frame: footerFrame) {
        layoutAttributesInRect.append(layoutAttributes)
      }
    }

    let backgroundLocationFramePairs = modelState.backgroundLocationFramePairs(
      forBackgroundsIn: rect)
    for backgroundLocationFramePair in backgroundLocationFramePairs {
      let backgroundLocation = backgroundLocationFramePair.elementLocation
      let backgroundFrame = backgroundLocationFramePair.frame

      if
        let layoutAttributes = backgroundLayoutAttributes(
          for: backgroundLocation,
          frame: backgroundFrame)
      {
        layoutAttributesInRect.append(layoutAttributes)
      }
    }

    let itemLocationFramePairs = modelState.itemLocationFramePairs(forItemsIn: rect)
    for itemLocationFramePair in itemLocationFramePairs {
      let itemLocation = itemLocationFramePair.elementLocation
      let itemFrame = itemLocationFramePair.frame

      if let layoutAttributes = itemLayoutAttributes(for: itemLocation, frame: itemFrame) {
        layoutAttributesInRect.append(layoutAttributes)
      }
    }

    return layoutAttributesInRect
  }

  override public func layoutAttributesForItem(
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    // See comment in `layoutAttributesForElementsInRect:` for more details.
    guard !hasDataSourceCountInvalidationBeforeReceivingUpdateItems else { return nil }

    let itemLocation = ElementLocation(indexPath: indexPath)

    guard
      itemLocation.sectionIndex < modelState.numberOfSections,
      itemLocation.elementIndex < modelState.numberOfItems(inSectionAtIndex: itemLocation.sectionIndex)
    else
    {
      // On iOS 9, `layoutAttributesForItem(at:)` can be invoked for an index path of a new item
      // before the layout is notified of this new item (through either `prepare` or
      // `prepare(forCollectionViewUpdates:)`). This seems to be fixed in iOS 10 and higher.
      assertionFailure("`{\(itemLocation.sectionIndex), \(itemLocation.elementIndex)}` is out of bounds of the section models / item models array.")

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollectionView`, which is why we don't return `nil` here.
      return itemLayoutAttributes(for: itemLocation, frame: .zero)
    }

    let itemFrame = modelState.frameForItem(at: itemLocation)
    return itemLayoutAttributes(for: itemLocation, frame: itemFrame)
  }

  override public func layoutAttributesForSupplementaryView(
    ofKind elementKind: String,
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    // See comment in `layoutAttributesForElementsInRect:` for more details.
    guard !hasDataSourceCountInvalidationBeforeReceivingUpdateItems else { return nil }

    let elementLocation = ElementLocation(indexPath: indexPath)
    if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionHeader,
      let headerFrame = modelState.frameForHeader(
        inSectionAtIndex: elementLocation.sectionIndex)
    {
      return headerLayoutAttributes(for: elementLocation, frame: headerFrame)
    } else if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionFooter,
      let footerFrame = modelState.frameForFooter(
        inSectionAtIndex: elementLocation.sectionIndex)
    {
      return footerLayoutAttributes(for: elementLocation, frame: footerFrame)
    } else if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionBackground,
      let backgroundFrame = modelState.frameForBackground(
        inSectionAtIndex: elementLocation.sectionIndex)
    {
      return backgroundLayoutAttributes(for: elementLocation, frame: backgroundFrame)
    } else {
      return nil
    }
  }

  override public func initialLayoutAttributesForAppearingItem(
    at itemIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    attributes?.frame = modelState.frameForItem(at: ElementLocation(indexPath: itemIndexPath))

    if
      modelState.itemIndexPathsToInsert.contains(itemIndexPath) ||
      modelState.sectionIndicesToInsert.contains(itemIndexPath.section)
    {
      attributes.map {
        delegateMagazineLayout?.collectionView(
          currentCollectionView,
          layout: self,
          initialLayoutAttributesForInsertedItemAt: itemIndexPath,
          byModifying: $0)
      }

      attributes?.transform = CGAffineTransform(
        translationX: 0,
        y: targetContentOffsetCompensatingYOffsetForAppearingItem ?? 0,
      )

      itemLayoutAttributesForPendingAnimations[itemIndexPath] = attributes
    } else if
      let movedItemID = modelState.idForItemModel(at: itemIndexPath),
      let initialIndexPath = layoutStateBeforeCollectionViewUpdates?.modelState.indexPathForItemModel(
        withID: movedItemID),
      let frame = layoutStateBeforeCollectionViewUpdates?.modelState.frameForItem(at: ElementLocation(indexPath: initialIndexPath))
    {
      attributes?.frame = frame
    }

    return attributes
  }

  override public func finalLayoutAttributesForDisappearingItem(
    at itemIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    if
      modelState.itemIndexPathsToDelete.contains(itemIndexPath) ||
      modelState.sectionIndicesToDelete.contains(itemIndexPath.section)
    {
      let attributes = previousLayoutAttributesForItem(at: itemIndexPath)
      attributes.map {
        delegateMagazineLayout?.collectionView(
          currentCollectionView,
          layout: self,
          finalLayoutAttributesForRemovedItemAt: itemIndexPath,
          byModifying: $0)
      }
      return attributes
    } else if
      let movedItemID = layoutStateBeforeCollectionViewUpdates?.modelState.idForItemModel(
        at: itemIndexPath),
      let finalIndexPath = modelState.indexPathForItemModel(
        withID: movedItemID)
    {
      let attributes = layoutAttributesForItem(at: finalIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      itemLayoutAttributesForPendingAnimations[finalIndexPath] = attributes
      return attributes
    } else {
      return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
  }

  override public func initialLayoutAttributesForAppearingSupplementaryElement(
    ofKind elementKind: String,
    at elementIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    // If a supplementary view's visibility changes to `.hidden` due to a data source change, this
    // function will get invoked with an `elementIndexPath` that crashes when its `section` is
    // accessed.
    guard !elementIndexPath.isEmpty else {
      return super.initialLayoutAttributesForAppearingSupplementaryElement(
        ofKind: elementKind,
        at: elementIndexPath)
    }

    if modelState.sectionIndicesToInsert.contains(elementIndexPath.section) {
      let attributes = layoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      attributes.map {
        modifySupplementaryViewLayoutAttributesForInsertAnimation(
          $0,
          ofKind: elementKind,
          at: elementIndexPath)
      }
      supplementaryViewLayoutAttributesForPendingAnimations[elementIndexPath] = attributes
      return attributes
    } else if
      let movedSectionID = modelState.idForSectionModel(
        atIndex: elementIndexPath.section),
      let initialSectionIndex = layoutStateBeforeCollectionViewUpdates?.modelState.indexForSectionModel(
        withID: movedSectionID)
    {
      let initialIndexPath = IndexPath(item: 0, section: initialSectionIndex)
      return previousLayoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: initialIndexPath)
    } else {
      return super.initialLayoutAttributesForAppearingSupplementaryElement(
        ofKind: elementKind,
        at: elementIndexPath)
    }
  }

  override public func finalLayoutAttributesForDisappearingSupplementaryElement(
    ofKind elementKind: String,
    at elementIndexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    // If a supplementary view's visibility changes to `.hidden` due to a data source change, this
    // function will get invoked with an `elementIndexPath` that crashes when its `section` is
    // accessed.
    guard !elementIndexPath.isEmpty else {
      return super.finalLayoutAttributesForDisappearingSupplementaryElement(
        ofKind: elementKind,
        at: elementIndexPath)
    }

    if modelState.sectionIndicesToDelete.contains(elementIndexPath.section) {
      let attributes = previousLayoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: elementIndexPath)
      attributes.map {
        modifySupplementaryViewLayoutAttributesForDeleteAnimation(
          $0,
          ofKind: elementKind,
          at: elementIndexPath)
      }
      return attributes
    } else if
      let movedSectionID = layoutStateBeforeCollectionViewUpdates?.modelState.idForSectionModel(
        atIndex: elementIndexPath.section),
      let finalSectionIndex = modelState.indexForSectionModel(
        withID: movedSectionID)
    {
      let finalIndexPath = IndexPath(item: 0, section: finalSectionIndex)
      let attributes = layoutAttributesForSupplementaryView(
        ofKind: elementKind,
        at: finalIndexPath)?.copy() as? UICollectionViewLayoutAttributes
      supplementaryViewLayoutAttributesForPendingAnimations[finalIndexPath] = attributes
      return attributes
    }  else {
      return super.finalLayoutAttributesForDisappearingSupplementaryElement(
        ofKind: elementKind,
        at: elementIndexPath)
    }
  }

  override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    let isSameWidth = currentCollectionView.bounds.size.width.isEqual(
      to: newBounds.size.width,
      screenScale: scale)
    let shouldInvalidateDueToSize: Bool
    switch verticalLayoutDirection {
    case .topToBottom:
      shouldInvalidateDueToSize = !isSameWidth
    case .bottomToTop:
      // When using the topToBottom layout direction, we only want to invalidate the layout when the
      // widths differ. When using the bottomToTop layout direction, we want to invalidate on any
      // size change due to the requirement of  needing to preserve scroll position from the bottom
      let isSameHeight = currentCollectionView.bounds.size.height.isEqual(
        to: newBounds.size.height,
        screenScale: scale)
      shouldInvalidateDueToSize = !isSameWidth || !isSameHeight
    }

    return shouldInvalidateDueToSize || hasPinnedHeaderOrFooter
  }

  override public func invalidationContext(
    forBoundsChange newBounds: CGRect)
    -> UICollectionViewLayoutInvalidationContext
  {
    let invalidationContext = super.invalidationContext(
      forBoundsChange: newBounds) as! MagazineLayoutInvalidationContext

    invalidationContext.invalidateLayoutMetrics = false

    // If our layout direction is `bottomToTop`, we need to handle the case of a non-animated bounds
    // change by using the invalidation context's `contentOffsetAdjustment`. The calculation to get
    // this right is odd, and is dependent on how close we were to the bottom of the collection view.
    if case .bottomToTop = verticalLayoutDirection {
      if newBounds.height < currentCollectionView.bounds.height {
        invalidationContext.contentOffsetAdjustment = CGPoint(
          x: 0.0,
          y: currentCollectionView.bounds.midY - newBounds.midY)
      } else if newBounds.height > currentCollectionView.bounds.height {
        let distanceFromBottom = currentCollectionView.contentSize.height - currentCollectionView.bounds.maxY
        let midYDelta = newBounds.midY - currentCollectionView.bounds.midY
        let heightDelta = newBounds.height - currentCollectionView.bounds.height
        invalidationContext.contentOffsetAdjustment = CGPoint(
          x: 0.0,
          y: midYDelta - min(distanceFromBottom, heightDelta))
      }
    }

    return invalidationContext
  }

  override public func shouldInvalidateLayout(
    forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
    withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes)
    -> Bool
  {
    guard !preferredAttributes.indexPath.isEmpty else {
      return super.shouldInvalidateLayout(
        forPreferredLayoutAttributes: preferredAttributes,
        withOriginalAttributes: originalAttributes)
    }

    let isSameHeight = preferredAttributes.size.height.isEqual(
      to: originalAttributes.size.height,
      screenScale: scale)
    let hasNewPreferredHeight = !isSameHeight

    switch (preferredAttributes.representedElementCategory, preferredAttributes.representedElementKind) {
    case (.cell, nil):
      let itemHeightMode = modelState.itemModelHeightMode(at: preferredAttributes.indexPath)
      switch itemHeightMode {
      case .some(.static):
        return false
      case .some(.dynamic):
        return hasNewPreferredHeight
      case .some(.dynamicAndStretchToTallestItemInRow):
        let currentPreferredHeight = modelState.itemModelPreferredHeight(
          at: preferredAttributes.indexPath)
        let isSameHeight = preferredAttributes.size.height.isEqual(
          to: currentPreferredHeight ?? -.greatestFiniteMagnitude,
          screenScale: scale)
        return hasNewPreferredHeight && !isSameHeight
      case nil:
        return false
      }

    case (.supplementaryView, MagazineLayout.SupplementaryViewKind.sectionHeader):
      let headerHeightMode = modelState.headerModelHeightMode(
        atSectionIndex: preferredAttributes.indexPath.section)
      return headerHeightMode == .dynamic

    case (.supplementaryView, MagazineLayout.SupplementaryViewKind.sectionFooter):
      let footerHeightMode = modelState.footerModelHeightMode(
        atSectionIndex: preferredAttributes.indexPath.section)
      return footerHeightMode == .dynamic

    case (.supplementaryView, MagazineLayout.SupplementaryViewKind.sectionBackground):
      return false

    default:
      assertionFailure("`MagazineLayout` only supports cells, headers, footers, and backgrounds")
      return false
    }
  }

  override public func invalidationContext(
    forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
    withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutInvalidationContext
  {
    let context = super.invalidationContext(
      forPreferredLayoutAttributes: preferredAttributes,
      withOriginalAttributes: originalAttributes) as! MagazineLayoutInvalidationContext
    context.invalidateLayoutMetrics = false

    switch preferredAttributes.representedElementCategory {
    case .cell:
      let targetContentOffsetAnchor = (
        layoutStateBeforeRecreateSectionModels ??
          layoutStateBeforeCollectionViewUpdates ??
          layoutStateBeforeAnimatedBoundsChange ??
          self.layoutState
      ).targetContentOffsetAnchor
      let targetYOffsetBefore = layoutState.yOffset(
        for: targetContentOffsetAnchor,
        isPerformingBatchUpdates: layoutStateBeforeCollectionViewUpdates != nil)

      modelState.updateItemHeight(
        toPreferredHeight: preferredAttributes.size.height,
        forItemAt: preferredAttributes.indexPath)

      switch targetContentOffsetAnchor {
      case .top(let overScrollDistance):
        context.contentOffsetAdjustment.y = layoutState.minContentOffset.y - overScrollDistance - layoutState.bounds.minY

      case .bottom(let overScrollDistance):
        context.contentOffsetAdjustment.y = layoutState.maxContentOffset.y + overScrollDistance - layoutState.bounds.minY

      case .topItem, .bottomItem:
        let targetYOffsetAfter = layoutState.yOffset(
          for: targetContentOffsetAnchor,
          isPerformingBatchUpdates: layoutStateBeforeCollectionViewUpdates != nil)
        context.contentOffsetAdjustment.y = targetYOffsetAfter - targetYOffsetBefore
      }

      if let attributes = itemLayoutAttributesForPendingAnimations[preferredAttributes.indexPath] {
        switch verticalLayoutDirection {
        case .topToBottom:
          attributes.frame = modelState.frameForItem(at: ElementLocation(indexPath: preferredAttributes.indexPath))

        case .bottomToTop:
          if case .bottom = targetContentOffsetAnchor {
            attributes.transform = .identity
            attributes.frame = modelState.frameForItem(at: ElementLocation(indexPath: preferredAttributes.indexPath))
          } else {
            let previousHeight = attributes.frame.height
            attributes.frame = modelState.frameForItem(at: ElementLocation(indexPath: preferredAttributes.indexPath))

            var targetContentOffsetCompensatingYOffsetForAppearingItem = targetContentOffsetCompensatingYOffsetForAppearingItem ?? 0
            targetContentOffsetCompensatingYOffsetForAppearingItem -= (attributes.frame.height - previousHeight)
            self.targetContentOffsetCompensatingYOffsetForAppearingItem = targetContentOffsetCompensatingYOffsetForAppearingItem
            attributes.transform = CGAffineTransform(translationX: 0, y: targetContentOffsetCompensatingYOffsetForAppearingItem)
          }
        }
      }

    case .supplementaryView:
      let layoutAttributesForPendingAnimation = supplementaryViewLayoutAttributesForPendingAnimations[preferredAttributes.indexPath]

      switch preferredAttributes.representedElementKind {
      case MagazineLayout.SupplementaryViewKind.sectionHeader?:
        modelState.updateHeaderHeight(
          toPreferredHeight: preferredAttributes.size.height,
          forSectionAtIndex: preferredAttributes.indexPath.section)

        layoutAttributesForPendingAnimation?.frame.size.height = modelState.frameForHeader(
          inSectionAtIndex: preferredAttributes.indexPath.section)?.height ?? preferredAttributes.size.height

      case MagazineLayout.SupplementaryViewKind.sectionFooter?:
        modelState.updateFooterHeight(
          toPreferredHeight: preferredAttributes.size.height,
          forSectionAtIndex: preferredAttributes.indexPath.section)

        layoutAttributesForPendingAnimation?.frame.size.height = modelState.frameForFooter(
          inSectionAtIndex: preferredAttributes.indexPath.section)?.height ?? preferredAttributes.size.height

      default:
        break
      }

    case .decorationView:
      assertionFailure("`MagazineLayout` does not support decoration views")

    @unknown default:
      assertionFailure("`MagazineLayout` does not support this kind of element category")
    }

    return context
  }

  override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    guard let context = context as? MagazineLayoutInvalidationContext else {
      assertionFailure("`context` must be an instance of `MagazineLayoutInvalidationContext`")
      super.invalidateLayout(with: context)
      return
    }

    // If our layout direction is `bottomToTop`, allow changes to the top and bottom content insets
    // to automatically adjust the content offset. `UICollectionView` behaves this way by default
    // when the top content inset changes, so this adds the same behavior.
    if
      case .bottomToTop = verticalLayoutDirection,
      let previousContentInset
    {
      if previousContentInset.top != contentInset.top {
        context.contentOffsetAdjustment.y += contentInset.top - previousContentInset.top
      }
      if previousContentInset.bottom != contentInset.bottom {
        context.contentOffsetAdjustment.y += contentInset.bottom - previousContentInset.bottom
      }
    }
    previousContentInset = contentInset

    let shouldInvalidateLayoutMetrics = !context.invalidateEverything &&
      !context.invalidateDataSourceCounts

    if context.invalidateEverything {
      prepareActions.formUnion([.recreateSectionModels])
    }

    // Checking `cachedCollectionViewWidth != collectionView?.bounds.size.width` is necessary
    // because the collection view's width can change without a `contentSizeAdjustment` occurring.
    let isSameWidth = collectionView?.bounds.size.width.isEqual(
      to: cachedCollectionViewWidth ?? -.greatestFiniteMagnitude,
      screenScale: scale)
      ?? false
    if !isSameWidth {
      prepareActions.formUnion([.updateLayoutMetrics, .cachePreviousWidth])
    }

    if context.invalidateLayoutMetrics && shouldInvalidateLayoutMetrics {
      prepareActions.formUnion([.updateLayoutMetrics])
    }

    hasDataSourceCountInvalidationBeforeReceivingUpdateItems = context.invalidateDataSourceCounts &&
      !context.invalidateEverything

    if context.invalidateDataSourceCounts {
      itemLayoutAttributes.removeAll()
      headerLayoutAttributes.removeAll()
      footerLayoutAttributes.removeAll()
      backgroundLayoutAttributes.removeAll()
    }

    layoutStateBeforeRecreateSectionModels = nil

    super.invalidateLayout(with: context)
  }

  override public func targetContentOffset(
    forProposedContentOffset proposedContentOffset: CGPoint)
    -> CGPoint
  {
    let layoutStateBefore = layoutStateBeforeCollectionViewUpdates ?? layoutStateBeforeAnimatedBoundsChange
    guard let layoutStateBefore else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }

    let yOffset = layoutState.yOffset(
      for: layoutStateBefore.targetContentOffsetAnchor,
      isPerformingBatchUpdates: layoutStateBeforeCollectionViewUpdates != nil)

    targetContentOffsetCompensatingYOffsetForAppearingItem = proposedContentOffset.y - yOffset

    return CGPoint(x: proposedContentOffset.x, y: yOffset)
  }

  // MARK: Private

  private let _flipsHorizontallyInOppositeLayoutDirection: Bool
  private let idGenerator = IDGenerator()

  private lazy var _layoutState = LayoutState(
    modelState: ModelState(currentVisibleBoundsProvider: { [weak self] in
      self?.currentVisibleBounds ?? .zero
    }),
    bounds: currentCollectionView.bounds,
    contentInset: contentInset,
    scale: scale,
    verticalLayoutDirection: verticalLayoutDirection)
  private var layoutStateBeforeRecreateSectionModels: LayoutState?
  private var layoutStateBeforeCollectionViewUpdates: LayoutState?
  private var layoutStateBeforeAnimatedBoundsChange: LayoutState?

  private var hasPinnedHeaderOrFooter: Bool = false

  // Cached layout attributes; lazily populated using information from the model state.
  private var itemLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var headerLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var footerLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()
  private var backgroundLayoutAttributes = [ElementLocation: MagazineLayoutCollectionViewLayoutAttributes]()

  // These properties are used to keep the layout attributes copies used for insert/delete
  // animations up-to-date as items are self-sized. If we don't keep these copies up-to-date, then
  // animations will start from the estimated height.
  private var itemLayoutAttributesForPendingAnimations = [IndexPath: UICollectionViewLayoutAttributes]()
  private var supplementaryViewLayoutAttributesForPendingAnimations = [IndexPath: UICollectionViewLayoutAttributes]()

  // We need to apply the target content offset to the initial y-offset of an appearing item.
  // Without this, the appearing item will be visually at the wrong spot, making it look like it
  // slides into place rather than appearing at its final position.
  private var targetContentOffsetCompensatingYOffsetForAppearingItem: CGFloat?

  private struct PrepareActions: OptionSet {
    let rawValue: UInt

    static let recreateSectionModels = PrepareActions(rawValue: 1 << 0)
    static let updateLayoutMetrics = PrepareActions(rawValue: 1 << 1)
    static let cachePreviousWidth = PrepareActions(rawValue: 1 << 2)
  }
  private var prepareActions: PrepareActions = []

  // Used to prevent a collection view bug / animation issue that occurs when off-screen batch
  // updates cause changes to the elements in the visible region. See comment in
  // `layoutAttributesForElementsInRect:` for more details.
  private var hasDataSourceCountInvalidationBeforeReceivingUpdateItems = false

  private var cachedCollectionViewWidth: CGFloat?
  private var previousContentInset: UIEdgeInsets?

  private var currentCollectionView: UICollectionView {
    guard let collectionView = collectionView else {
      preconditionFailure("`collectionView` should not be `nil`")
    }

    return collectionView
  }

  // Used to provide the model state with the current visible bounds for the sole purpose of
  // supporting pinned headers and footers.
  private var currentVisibleBounds: CGRect {
    let refreshControlHeight: CGFloat
    #if os(iOS)
    if
      let refreshControl = currentCollectionView.refreshControl,
      refreshControl.isRefreshing
    {
      refreshControlHeight = refreshControl.bounds.height
    } else {
      refreshControlHeight = 0
    }
    #else
    refreshControlHeight = 0
    #endif

    return CGRect(
      x: currentCollectionView.bounds.minX + contentInset.left,
      y: currentCollectionView.bounds.minY + contentInset.top - refreshControlHeight,
      width: currentCollectionView.bounds.width - contentInset.left - contentInset.right,
      height: currentCollectionView.bounds.height - contentInset.top - contentInset.bottom + refreshControlHeight)
  }

  private var delegateMagazineLayout: UICollectionViewDelegateMagazineLayout? {
    return currentCollectionView.delegate as? UICollectionViewDelegateMagazineLayout
  }

  private var scale: CGFloat {
    collectionView?.traitCollection.nonZeroDisplayScale ?? 1
  }

  private var contentInset: UIEdgeInsets {
    currentCollectionView.adjustedContentInset
  }

  private var layoutState: LayoutState {
    _layoutState.bounds = currentCollectionView.bounds
    _layoutState.contentInset = contentInset
    _layoutState.scale = scale
    _layoutState.verticalLayoutDirection = verticalLayoutDirection
    return _layoutState
  }

  private var modelState: ModelState {
    layoutState.modelState
  }

  private func metricsForSection(atIndex sectionIndex: Int) -> MagazineLayoutSectionMetrics {
    guard let delegateMagazineLayout = delegateMagazineLayout else {
      return MagazineLayoutSectionMetrics.defaultSectionMetrics(
        forCollectionViewWidth: currentCollectionView.bounds.width,
        scale: scale)
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
    case let .dynamic(estimatedHeight):
      return estimatedHeight
    case .dynamicAndStretchToTallestItemInRow:
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

  private func visibilityModeForFooter(
    inSectionAtIndex sectionIndex: Int)
    -> MagazineLayoutFooterVisibilityMode
  {
    guard let delegateMagazineLayout = delegateMagazineLayout else {
      return MagazineLayout.Default.FooterVisibilityMode
    }

    return delegateMagazineLayout.collectionView(
      currentCollectionView,
      layout: self,
      visibilityModeForFooterInSectionAtIndex: sectionIndex)
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

  private func headerHeight(
    from headerHeightMode: MagazineLayoutHeaderHeightMode)
    -> CGFloat
  {
    switch headerHeightMode {
    case let .static(staticHeight):
      return staticHeight
    case .dynamic:
      return MagazineLayout.Default.HeaderHeight
    }
  }

  private func footerHeight(
    from footerHeightMode: MagazineLayoutFooterHeightMode)
    -> CGFloat
  {
    switch footerHeightMode {
    case let .static(staticHeight):
      return staticHeight
    case .dynamic:
      return MagazineLayout.Default.FooterHeight
    }
  }

  private func sectionModelForSection(atIndex sectionIndex: Int) -> SectionModel {
    let itemModels = (0..<currentCollectionView.numberOfItems(inSection: sectionIndex)).map {
      itemModelForItem(at: IndexPath(item: $0, section: sectionIndex))
    }

    return SectionModel(
      idGenerator: idGenerator,
      itemModels: itemModels,
      headerModel: headerModelForHeader(inSectionAtIndex: sectionIndex),
      footerModel: footerModelForFooter(inSectionAtIndex: sectionIndex),
      backgroundModel: backgroundModelForBackground(inSectionAtIndex: sectionIndex),
      metrics: metricsForSection(atIndex: sectionIndex))
  }

  private func itemModelForItem(at indexPath: IndexPath) -> ItemModel {
    let itemSizeMode = sizeModeForItem(at: indexPath)
    return ItemModel(
      idGenerator: idGenerator,
      sizeMode: itemSizeMode,
      height: initialItemHeight(from: itemSizeMode))
  }

  private func headerModelForHeader(
    inSectionAtIndex sectionIndex: Int)
    -> HeaderModel?
  {
    let headerVisibilityMode = visibilityModeForHeader(inSectionAtIndex: sectionIndex)
    switch headerVisibilityMode {
    case let .visible(heightMode, pinToVisibleBounds):
      return HeaderModel(
        heightMode: heightMode,
        height: headerHeight(from: heightMode), pinToVisibleBounds: pinToVisibleBounds)
    case .hidden:
      return nil
    }
  }

  private func footerModelForFooter(
    inSectionAtIndex sectionIndex: Int)
    -> FooterModel?
  {
    let footerVisibilityMode = visibilityModeForFooter(inSectionAtIndex: sectionIndex)
    switch footerVisibilityMode {
    case let .visible(heightMode, pinToVisibleBounds):
      return FooterModel(
        heightMode: heightMode,
        height: footerHeight(from: heightMode), pinToVisibleBounds: pinToVisibleBounds)
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

  private func previousLayoutAttributesForItem(
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let layoutAttributes = MagazineLayoutCollectionViewLayoutAttributes(forCellWith: indexPath)

    guard let layoutStateBeforeCollectionViewUpdates else {
      // TODO(bryankeller): Look into whether this happens on iOS 10. It definitely does on iOS 9.

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollectionView`, which is why we don't return `nil` here.
      return layoutAttributes
    }

    guard
      indexPath.section < layoutStateBeforeCollectionViewUpdates.modelState.numberOfSections,
      indexPath.item < layoutStateBeforeCollectionViewUpdates.modelState.numberOfItems(
        inSectionAtIndex: indexPath.section)
    else {
      // On iOS 9, `layoutAttributesForItem(at:)` can be invoked for an index path of a new item
      // before the layout is notified of this new item (through either `prepare` or
      // `prepare(forCollectionViewUpdates:)`). This seems to be fixed in iOS 10 and higher.
      assertionFailure("`{\(indexPath.section), \(indexPath.item)}` is out of bounds of the section models / item models array.")

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollectionView`, which is why we don't return `nil` here.
      return layoutAttributes
    }

    layoutAttributes.frame = layoutStateBeforeCollectionViewUpdates.modelState.frameForItem(
      at: ElementLocation(indexPath: indexPath))

    return layoutAttributes
  }

  private func previousLayoutAttributesForSupplementaryView(
    ofKind elementKind: String,
    at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    let layoutAttributes = MagazineLayoutCollectionViewLayoutAttributes(
      forSupplementaryViewOfKind: elementKind,
      with: indexPath)

    guard let layoutStateBeforeCollectionViewUpdates else {
      // TODO(bryankeller): Look into whether this happens on iOS 10. It definitely does on iOS 9.

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollectionView`, which is why we don't return `nil` here.
      return layoutAttributes
    }

    guard indexPath.section < layoutStateBeforeCollectionViewUpdates.modelState.numberOfSections else {
      // On iOS 9, `layoutAttributesForItem(at:)` can be invoked for an index path of a new
      // supplementary view before the layout is notified of this new item (through either `prepare`
      // or `prepare(forCollectionViewUpdates:)`). This seems to be fixed in iOS 10 and higher.
      assertionFailure("`\(indexPath.section)` is out of bounds of the section models array.")

      // Returning `nil` rather than default/frameless layout attributes causes internal exceptions
      // within `UICollectionView`, which is why we don't return `nil` here.
      return layoutAttributes
    }

    if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionHeader,
      let headerFrame = layoutStateBeforeCollectionViewUpdates.modelState.frameForHeader(
        inSectionAtIndex: indexPath.section)
    {
      layoutAttributes.frame = headerFrame
    } else if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionFooter,
      let footerFrame = layoutStateBeforeCollectionViewUpdates.modelState.frameForFooter(
        inSectionAtIndex: indexPath.section)
    {
      layoutAttributes.frame = footerFrame
    } else if
      elementKind == MagazineLayout.SupplementaryViewKind.sectionBackground,
      let backgroundFrame = layoutStateBeforeCollectionViewUpdates.modelState.frameForBackground(
        inSectionAtIndex: indexPath.section)
    {
      layoutAttributes.frame = backgroundFrame
    } else {
      assertionFailure("\(elementKind) is not a valid supplementary view element kind.")
    }
    
    return layoutAttributes
  }

  private func modifySupplementaryViewLayoutAttributesForInsertAnimation(
    _ attributes: UICollectionViewLayoutAttributes,
    ofKind elementKind: String,
    at indexPath: IndexPath)
  {
    switch elementKind {
    case MagazineLayout.SupplementaryViewKind.sectionHeader:
      delegateMagazineLayout?.collectionView(
        currentCollectionView,
        layout: self,
        initialLayoutAttributesForInsertedHeaderInSectionAtIndex: indexPath.section,
        byModifying: attributes)
    case MagazineLayout.SupplementaryViewKind.sectionFooter:
      delegateMagazineLayout?.collectionView(
        currentCollectionView,
        layout: self,
        initialLayoutAttributesForInsertedFooterInSectionAtIndex: indexPath.section,
        byModifying: attributes)
    case MagazineLayout.SupplementaryViewKind.sectionBackground:
      delegateMagazineLayout?.collectionView(
        currentCollectionView,
        layout: self,
        initialLayoutAttributesForInsertedBackgroundInSectionAtIndex: indexPath.section,
        byModifying: attributes)
    default:
      assertionFailure("\(elementKind) is not a valid supplementary view element kind.")
    }
  }

  private func modifySupplementaryViewLayoutAttributesForDeleteAnimation(
    _ attributes: UICollectionViewLayoutAttributes,
    ofKind elementKind: String,
    at indexPath: IndexPath)
  {
    switch elementKind {
    case MagazineLayout.SupplementaryViewKind.sectionHeader:
      delegateMagazineLayout?.collectionView(
        currentCollectionView,
        layout: self,
        finalLayoutAttributesForRemovedHeaderInSectionAtIndex: indexPath.section,
        byModifying: attributes)
    case MagazineLayout.SupplementaryViewKind.sectionFooter:
      delegateMagazineLayout?.collectionView(
        currentCollectionView,
        layout: self,
        finalLayoutAttributesForRemovedFooterInSectionAtIndex: indexPath.section,
        byModifying: attributes)
    case MagazineLayout.SupplementaryViewKind.sectionBackground:
      delegateMagazineLayout?.collectionView(
        currentCollectionView,
        layout: self,
        finalLayoutAttributesForRemovedBackgroundInSectionAtIndex: indexPath.section,
        byModifying: attributes)
    default:
      assertionFailure("\(elementKind) is not a valid supplementary view element kind.")
    }
  }

}

// MARK: Layout Attributes Creation and Caching

private extension MagazineLayout {

  func headerLayoutAttributes(
    for headerLocation: ElementLocation,
    frame: CGRect)
    -> UICollectionViewLayoutAttributes?
  {
    guard headerLocation.sectionIndex < currentCollectionView.numberOfSections else { return nil }

    let layoutAttributes: MagazineLayoutCollectionViewLayoutAttributes
    if
      let cachedLayoutAttributes = headerLayoutAttributes[headerLocation],
      ElementLocation(indexPath: cachedLayoutAttributes.indexPath) == headerLocation
    {
      layoutAttributes = cachedLayoutAttributes
    } else {
      layoutAttributes = MagazineLayoutCollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionHeader,
        with: headerLocation.indexPath)
    }

    layoutAttributes.frame = frame

    let sectionIndex = headerLocation.sectionIndex
    if
      case let .visible(heightMode, pinToVisibleBounds) = visibilityModeForHeader(
        inSectionAtIndex: sectionIndex)
    {
      layoutAttributes.shouldVerticallySelfSize = heightMode == .dynamic
      hasPinnedHeaderOrFooter = hasPinnedHeaderOrFooter || pinToVisibleBounds
    }

    let numberOfItems = currentCollectionView.numberOfItems(inSection: headerLocation.sectionIndex)
    layoutAttributes.zIndex = numberOfItems + 1

    headerLayoutAttributes[headerLocation] = layoutAttributes

    return layoutAttributes
  }

  func footerLayoutAttributes(
    for footerLocation: ElementLocation,
    frame: CGRect)
    -> UICollectionViewLayoutAttributes?
  {
    guard footerLocation.sectionIndex < currentCollectionView.numberOfSections else { return nil }

    let layoutAttributes: MagazineLayoutCollectionViewLayoutAttributes
    if
      let cachedLayoutAttributes = footerLayoutAttributes[footerLocation],
      ElementLocation(indexPath: cachedLayoutAttributes.indexPath) == footerLocation
    {
      layoutAttributes = cachedLayoutAttributes
    } else {
      layoutAttributes = MagazineLayoutCollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionFooter,
        with: footerLocation.indexPath)
    }

    layoutAttributes.frame = frame

    let sectionIndex = footerLocation.sectionIndex
    if
      case let .visible(heightMode, pinToVisibleBounds) = visibilityModeForFooter(
        inSectionAtIndex: sectionIndex)
    {
      layoutAttributes.shouldVerticallySelfSize = heightMode == .dynamic
      hasPinnedHeaderOrFooter = hasPinnedHeaderOrFooter || pinToVisibleBounds
    }

    let numberOfItems = currentCollectionView.numberOfItems(inSection: sectionIndex)
    layoutAttributes.zIndex = numberOfItems + 1

    footerLayoutAttributes[footerLocation] = layoutAttributes

    return layoutAttributes
  }

  func backgroundLayoutAttributes(
    for backgroundLocation: ElementLocation,
    frame: CGRect)
    -> UICollectionViewLayoutAttributes?
  {
    guard backgroundLocation.sectionIndex < currentCollectionView.numberOfSections else {
      return nil
    }

    let layoutAttributes: MagazineLayoutCollectionViewLayoutAttributes
    if
      let cachedLayoutAttributes = backgroundLayoutAttributes[backgroundLocation],
      ElementLocation(indexPath: cachedLayoutAttributes.indexPath) == backgroundLocation
    {
      layoutAttributes = cachedLayoutAttributes
    } else {
      layoutAttributes = MagazineLayoutCollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionBackground,
        with: backgroundLocation.indexPath)
    }

    layoutAttributes.frame = frame

    layoutAttributes.shouldVerticallySelfSize = false
    layoutAttributes.zIndex = 0

    backgroundLayoutAttributes[backgroundLocation] = layoutAttributes

    return layoutAttributes
  }

  func itemLayoutAttributes(
    for itemLocation: ElementLocation,
    frame: CGRect)
    -> UICollectionViewLayoutAttributes?
  {
    guard itemLocation.sectionIndex < currentCollectionView.numberOfSections else { return nil }
    let numberOfItems = currentCollectionView.numberOfItems(inSection: itemLocation.sectionIndex)
    guard itemLocation.elementIndex < numberOfItems else { return nil }

    let layoutAttributes: MagazineLayoutCollectionViewLayoutAttributes
    if
      let cachedLayoutAttributes = itemLayoutAttributes[itemLocation],
      ElementLocation(indexPath: cachedLayoutAttributes.indexPath) == itemLocation
    {
      layoutAttributes = cachedLayoutAttributes
    } else {
      layoutAttributes = MagazineLayoutCollectionViewLayoutAttributes(
        forCellWith: itemLocation.indexPath)
    }

    layoutAttributes.frame = frame

    let itemHeightMode = sizeModeForItem(at: itemLocation.indexPath).heightMode
    if case .static = itemHeightMode {
      layoutAttributes.shouldVerticallySelfSize = false
    } else {
      layoutAttributes.shouldVerticallySelfSize = true
    }

    layoutAttributes.zIndex = numberOfItems - itemLocation.elementIndex

    itemLayoutAttributes[itemLocation] = layoutAttributes

    return layoutAttributes
  }

}
