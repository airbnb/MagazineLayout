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

/// A cell that coordinates with `MagazineLayoutCollectionViewLayoutAttributes` to determine how to
/// size itself: with self-sizing, or without self-sizing. Use this class (or subclasses) for
/// displaying cells with `MagazineLayout`.
///
/// Note that this class is very similar to `MagazineLayoutCollectionReusableView`.
///
/// `UIKit` invokes `preferredLayoutAttributesFitting(_:)` with an initial set of layout attributes,
/// giving this cell subclass a chance to modify the `size` property of the attributes based on
/// whether or not we want to self-size.
///
/// Subclassing and/or adding additional protocol conformances is encouraged, although modifying
/// the behavior of `preferredLayoutAttributesFitting(_:)` is not recommended.
///
/// This class exists because `MagazineLayout` supports self-sizing in just the vertical dimension -
/// a use case that `UICollectionViewCell` does not support out-of-the-box.
///
/// As of iOS 12, `UICollectionReusableView` is tightly coupled with `UICollectionViewFlowLayout`'s
/// private `_estimatesSizes` property, which is used to determine how to size cells displayed in a
/// `UICollectionViewFlowLayout`. If `_estimatesSizes` is `true`, then `UICollectionReusableView`
/// will self-size in both the horizontal and vertical dimensions. If it is `false`, no self-sizing
/// will occur. In short, `UICollectionReusableView` is only optimized to work correctly with
/// Apple's own layout.
open class MagazineLayoutCollectionViewCell: UICollectionViewCell {

  public override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      rightAnchor.constraint(equalTo: contentView.rightAnchor),
    ])
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override open func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes
  {
    guard let attributes = layoutAttributes as? MagazineLayoutCollectionViewLayoutAttributes else {
      assertionFailure("`layoutAttributes` must be an instance of `MagazineLayoutCollectionViewLayoutAttributes`")
      return super.preferredLayoutAttributesFitting(layoutAttributes)
    }

    // In some cases, `contentView`'s required width and height constraints
    // (created from its auto-resizing mask) will not have the correct constants before invoking
    // `systemLayoutSizeFitting(...)`, causing the cell to size incorrectly. This seems to be a
    // UIKit bug.
    // https://openradar.appspot.com/radar?id=5025850143539200
    // The issue seems most common when the collection view's bounds change (on rotation).
    // We correct for this by updating `contentView.bounds`, which updates the constants used by the
    // width and height constraints created by the `contentView`'s auto-resizing mask.

    if contentView.bounds.width != layoutAttributes.size.width {
      contentView.bounds.size.width = layoutAttributes.size.width
    }

    if
      !attributes.shouldVerticallySelfSize &&
      contentView.bounds.height != layoutAttributes.size.height
    {
      contentView.bounds.size.height = layoutAttributes.size.height
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
