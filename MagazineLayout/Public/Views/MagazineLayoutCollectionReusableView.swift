// Created by bryankeller on 11/29/18.
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

/// A collection reusable view that coordinates with `MagazineLayoutCollectionViewLayoutAttributes`
/// to determine how to size itself: with self-sizing, or without self-sizing. Use this class
/// (or subclasses) for displaying header and background supplementary views with `MagazineLayout`.
///
/// Note that this class is very similar to `MagazineLayoutCollectionViewCell`.
///
/// `UIKit` invokes `preferredLayoutAttributesFitting(_:)` with an initial set of layout attributes,
/// giving this reusable view subclass a chance to modify the `size` property of the attributes
/// based on whether or not we want to self-size.
///
/// Subclassing and/or adding additional protocol conformances is encouraged, although modifying
/// the behavior of `preferredLayoutAttributesFitting(_:)` is not recommended.
///
/// This class exists because `MagazineLayout` supports self-sizing supplementary views in just the
/// vertical dimension - a use case that `UICollectionReusableView` does not support out-of-the-box.
open class MagazineLayoutCollectionReusableView: UICollectionReusableView {

  override open func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes
  {
    guard let attributes = layoutAttributes as? MagazineLayoutCollectionViewLayoutAttributes else {
      assertionFailure("`layoutAttributes` must be an instance of `MagazineLayoutCollectionViewLayoutAttributes`")
      return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    let size: CGSize
    if attributes.shouldVerticallySelfSize {
      // Self-sizing is required in the vertical dimension.
      size = super.systemLayoutSizeFitting(
        layoutAttributes.size,
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel)
    } else {
      // No self-sizing is required; respect whatever size the layout determined.
      size = layoutAttributes.size
    }

    layoutAttributes.size = size

    return layoutAttributes
  }

}
