// Created by bryankeller on 7/17/17.
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

// MARK: - UICollectionViewDelegateMagazineLayout

public protocol UICollectionViewDelegateMagazineLayout: UICollectionViewDelegate {

  ///   Asks the delegate for the size mode of the specified item.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - indexPath: The index path of the item.
  ///
  ///   - Returns: The size mode of the specified item.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode

  ///   Asks the delegate for the visibility mode of the header in the specified section.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the header.
  ///
  ///   - Returns: The visibility mode of the header in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForHeaderInSectionAtIndex index: Int)
    -> MagazineLayoutHeaderVisibilityMode

  ///   Asks the delegate for the visibility mode of the footer in the specified section.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the footer.
  ///
  ///   - Returns: The visibility mode of the footer in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode

  ///   Asks the delegate for the visibility mode of the background in the specified section.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the background.
  ///
  ///   - Returns: The visibility mode of the background in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForBackgroundInSectionAtIndex index: Int)
    -> MagazineLayoutBackgroundVisibilityMode

  ///   Asks the delegate for the horizontal spacing for items in the specified section.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section whose horizontal item spacing is needed.
  ///
  ///   - Returns: The horizontal spacing for items in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    horizontalSpacingForItemsInSectionAtIndex index: Int)
    -> CGFloat

  ///   Asks the delegate for the vertical spacing for items in the specified section.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section whose vertical item spacing is needed.
  ///
  ///   - Returns: The vertical spacing for items in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat

  ///   Asks the delegate for the amount by which to inset elements in the specified section.
  ///
  ///   Section insets are relative to the content's bounds, which is impacted by the collection
  ///   view's content inset.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section whose element insets are needed.
  ///
  ///   - Returns: The amount by which to inset elements in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets

  ///   Asks the delegate for the amount by which to inset items in the specified section.
  ///
  ///   Item insets are relative to the section's bounds, which is impacted by the section's insets
  ///   and, transitively, the collection view's content inset.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section whose item insets are needed.
  ///
  ///   - Returns: The amount by which to inset items in the specified section.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets

  ///   Asks the delegate to modify a layout attributes instance so that it represents the initial visual state of an item being inserted via
  ///   `UICollectionView.insertItems(at:)`.
  ///
  ///   The `initialLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the item will be inserted with no animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - indexPath: The index path of the item.
  ///      - initialLayoutAttributes: The unmodified layout attributes representing the final visual state of the inserted
  ///      item. Modify properties on this instance to create an item insert animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedItemAt indexPath: IndexPath,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the initial visual state of a header being inserted
  ///   via `UICollectionView.insertSections(_:)`.
  ///
  ///   The `initialLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the header will be inserted with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the header.
  ///      - initialLayoutAttributes: The unmodified layout attributes representing the final visual state of the inserted
  ///      header. Modify properties on this instance to create a header insert animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedHeaderInSectionAtIndex index: Int,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the initial visual state of a footer being inserted
  ///   via `UICollectionView.insertSections(_:)`.
  ///
  ///   The `initialLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the footer will be inserted with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the footer.
  ///      - initialLayoutAttributes: The unmodified layout attributes representing the final visual state of the inserted
  ///      footer. Modify properties on this instance to create a footer insert animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedFooterInSectionAtIndex index: Int,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the initial visual state of a background being
  ///   inserted via `UICollectionView.insertSections(_:)`.
  ///
  ///   The `initialLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the background will be inserted with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the background.
  ///      - initialLayoutAttributes: The unmodified layout attributes representing the final visual state of the inserted
  ///      background. Modify properties on this instance to create a background insert animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedBackgroundInSectionAtIndex index: Int,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the final visual state of an item being removed via
  ///   `UICollectionView.deleteItems(at:)`.
  ///
  ///   The `finalLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the item will be removed with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - indexPath: The index path of the item.
  ///      - finalLayoutAttributes: The unmodified layout attributes representing the final visual state of the removed item.
  ///      Modify properties on this instance to create an item delete animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the final visual state of a header being removed
  ///   via `UICollectionView.deleteSections(_:)`.
  ///
  ///   The `finalLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the header will be removed with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the header.
  ///      - finalLayoutAttributes: The unmodified layout attributes representing the final visual state of the removed
  ///      header. Modify properties on this instance to create a header delete animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedHeaderInSectionAtIndex index: Int,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the final visual state of a footer being removed
  ///   via `UICollectionView.deleteSections(_:)`.
  ///
  ///   The `finalLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the footer will be removed with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the footer.
  ///      - finalLayoutAttributes: The unmodified layout attributes representing the final visual state of the removed
  ///      footer. Modify properties on this instance to create a footer delete animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedFooterInSectionAtIndex index: Int,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)

  ///   Asks the delegate to modify a layout attributes instance so that it represents the final visual state of a background being
  ///   removed via `UICollectionView.deleteSections(_:)`.
  ///
  ///   The `finalLayoutAttributes` instance is a reference type, and therefore can be modified directly. If the provided
  ///   layout attributes instance is not changed in the implementation of this function, then the background will be removed with no
  ///   animation.
  ///
  ///   - Parameters:
  ///      - collectionView: The collection view using the layout.
  ///      - collectionViewLayout: The layout requesting the information.
  ///      - index: The index of the section containing the background.
  ///      - finalLayoutAttributes: The unmodified layout attributes representing the final visual state of the removed
  ///      background. Modify properties on this instance to create a background delete animation.
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedBackgroundInSectionAtIndex index: Int,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)

}

// MARK: Default Insert Animations

public extension UICollectionViewDelegateMagazineLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedItemAt indexPath: IndexPath,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultInsertAnimation(byModifying: initialLayoutAttributes)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedHeaderInSectionAtIndex index: Int,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultInsertAnimation(byModifying: initialLayoutAttributes)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedFooterInSectionAtIndex index: Int,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultInsertAnimation(byModifying: initialLayoutAttributes)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    initialLayoutAttributesForInsertedBackgroundInSectionAtIndex index: Int,
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultInsertAnimation(byModifying: initialLayoutAttributes)
  }

  private func defaultInsertAnimation(
    byModifying initialLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    // The default insert animation is a simple fade-in.
    initialLayoutAttributes.alpha = 0
  }

}

// MARK: Default Delete Animations

public extension UICollectionViewDelegateMagazineLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultDeleteAnimation(byModifying: finalLayoutAttributes)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedHeaderInSectionAtIndex index: Int,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultDeleteAnimation(byModifying: finalLayoutAttributes)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedFooterInSectionAtIndex index: Int,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultDeleteAnimation(byModifying: finalLayoutAttributes)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedBackgroundInSectionAtIndex index: Int,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    defaultDeleteAnimation(byModifying: finalLayoutAttributes)
  }

  private func defaultDeleteAnimation(
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    // The default delete animation is a simple fade-out.
    finalLayoutAttributes.alpha = 0
  }

}
