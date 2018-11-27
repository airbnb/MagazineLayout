// Created by bryankeller on 7/24/17.
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

/// Encapsulates the vertical fitting priority for an element laid out by `MagazineLayout`.
///
/// Used by `UICollectionViewCell` and `UICollectionReusableView` subclasses to determine which
/// vertical fitting priority to pass into
/// `systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority)` via
/// `preferredLayoutAttributesFitting(_:)`.
public final class MagazineLayoutCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

  /// `MagazineLayout` supports self-sizing and static-sizing in the vertical direction. The value
  /// of this property will change the layout priority used for sizing.
  public var shouldVerticallySelfSize = true

  override public func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! MagazineLayoutCollectionViewLayoutAttributes
    copy.shouldVerticallySelfSize = shouldVerticallySelfSize
    return copy
  }

  override public func isEqual(_ object: Any?) -> Bool {
    return super.isEqual(object) &&
      shouldVerticallySelfSize == (object as? MagazineLayoutCollectionViewLayoutAttributes)?.shouldVerticallySelfSize
  }

}
