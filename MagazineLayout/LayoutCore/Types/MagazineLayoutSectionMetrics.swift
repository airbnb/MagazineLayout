// Created by bryankeller on 10/26/18.
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

/// Encapsulates all layout-affecting metrics relating to a section
struct MagazineLayoutSectionMetrics: Equatable {

  // MARK: Lifecycle

  init(
    forSectionAtIndex sectionIndex: Int,
    in collectionView: UICollectionView,
    layout: UICollectionViewLayout,
    delegate: UICollectionViewDelegateMagazineLayout)
  {
    width = collectionView.bounds.width -
      collectionView.contentInset.left -
      collectionView.contentInset.right
    verticalSpacing = delegate.collectionView(
      collectionView,
      layout: layout,
      verticalSpacingForElementsInSectionAtIndex: sectionIndex)
    horizontalSpacing = delegate.collectionView(
      collectionView,
      layout: layout,
      horizontalSpacingForItemsInSectionAtIndex: sectionIndex)
    itemInsets = delegate.collectionView(
      collectionView,
      layout: layout,
      insetsForItemsInSectionAtIndex: sectionIndex)
  }

  private init(
    width: CGFloat,
    verticalSpacing: CGFloat,
    horizontalSpacing: CGFloat,
    itemInsets: UIEdgeInsets)
  {
    self.width = width
    self.verticalSpacing = verticalSpacing
    self.horizontalSpacing = horizontalSpacing
    self.itemInsets = itemInsets
  }

  // MARK: Internal

  var width: CGFloat
  var verticalSpacing: CGFloat
  var horizontalSpacing: CGFloat
  var itemInsets: UIEdgeInsets

  static func defaultSectionMetrics(
    forCollectionViewWidth width: CGFloat)
    -> MagazineLayoutSectionMetrics
  {
    return MagazineLayoutSectionMetrics(
      width: width,
      verticalSpacing: MagazineLayout.Default.VerticalSpacing,
      horizontalSpacing: MagazineLayout.Default.HorizontalSpacing,
      itemInsets: MagazineLayout.Default.ItemInsets)
  }

}
