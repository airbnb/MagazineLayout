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

}
