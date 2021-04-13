// Created by bryankeller on 10/15/18.
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

// MARK: - MagazineLayoutItemSizeMode

/// Represents the horizontal and vertical sizing mode for an item.
public struct MagazineLayoutItemSizeMode: Hashable {

  // MARK: Lifecycle

  public init(widthMode: MagazineLayoutItemWidthMode, heightMode: MagazineLayoutItemHeightMode) {
    self.widthMode = widthMode
    self.heightMode = heightMode
  }

  // MARK: Public

  /// The width mode for the item.
  public let widthMode: MagazineLayoutItemWidthMode

  /// The height mode for the item.
  public let heightMode: MagazineLayoutItemHeightMode

}

// MARK: - MagazineLayoutItemWidthMode

/// Represents the horizontal sizing mode for an item.
///
/// Consecutive items with the same width mode will display on the same row until there is no more
/// room.
public enum MagazineLayoutItemWidthMode: Hashable {

  /// Full width items will fill the available width in a section.
  ///
  /// Use this width mode to create lists of items.
  /// `respectsHorizontalInsets` specifies whether the item should be edge-to-edge in a section, or
  /// if it should be inset by the item insets specified for a section. `respectsHorizontalInsets`
  /// does not take into account section insets or the collection view's content inset.
  case fullWidth(respectsHorizontalInsets: Bool)

  /// Fractional width items will take up `1/divisor` of the available width for a given row of
  /// items.
  ///
  /// Use this width mode to create grids of items. Consider using `halfWidth`, `thirdWidth`,
  /// `fourthWidth`, or `fifthWidth`, which are equivalent to using `fractionalWidth` with a
  /// `divisor` of `2`, `3`, `4`, or `5`, respectively.
  ///
  /// Fractional width items respect `contentInset.left` and `contentInset.right`, and are affected
  /// by the horizontal spacing specified for the section in which they're contained. On iOS 11 and
  /// higher, they will also take the safe area insets into account if the collection view's
  /// `contentInsetAdjustmentBehavior` property is set to a value that respects the safe area.
  ///
  /// - Warning: `divisor` must be greater than `0`. Specifying `0` as the `divisor` is a programmer
  /// error and **will result in a runtime crash**.
  case fractionalWidth(divisor: UInt)

  /// Half width items will take up `1/2` of the available width for a given row of items.
  public static var halfWidth: MagazineLayoutItemWidthMode {
    return .fractionalWidth(divisor: 2)
  }

  /// Third width items will take up `1/3` of the available width for a given row of items.
  public static var thirdWidth: MagazineLayoutItemWidthMode {
    return .fractionalWidth(divisor: 3)
  }

  /// Fourth width items will take up `1/4` of the available width for a given row of items.
  public static var fourthWidth: MagazineLayoutItemWidthMode {
    return .fractionalWidth(divisor: 4)
  }

  /// Fifth width items will take up `1/5` of the available width for a given row of items.
  public static var fifthWidth: MagazineLayoutItemWidthMode {
    return .fractionalWidth(divisor: 5)
  }

}

// MARK: - MagazineLayoutItemHeightMode

/// Represents the vertical sizing mode for an item.
///
/// `MagazineLayout` supports vertically self-sizing and statically sized items. Since height modes
/// are specified for each item, you can mix vertically self-sizing and statically sized items in
/// the same sections, and even in the same rows.
public enum MagazineLayoutItemHeightMode: Hashable {

  /// This height mode mode will cause the item to be displayed with a height equal to `height`.
  ///
  /// To properly support multiline labels, dynamic type, and other technologies that could affect
  /// the height of your items dynamically, consider using one of the dynamic height modes.
  case `static`(height: CGFloat)

  /// This height mode will cause the item to self-size in the vertical direction.
  ///
  /// In practice, self-sizing in the vertical direction means that the item will get its height
  /// from the Auto Layout engine. Use this height mode for items whose height is not known upfront.
  /// For example, if you support multiline labels or dynamic type, your height is likely not known
  /// until the Auto Layout engine resolves the layout at runtime.
  case dynamic

  /// This height mode will cause the item to self-size in the vertical direction, then resize to
  /// match the height of the tallest item in the same row of items.
  ///
  /// If the item _is_ the tallest item in the row (after being self-sized), then it will stay
  /// at its self-sized height until it's no longer the tallest item in the row.
  ///
  /// Note that items with this height mode will resize to match the height of the tallest item in
  /// the same row of items, even if the tallest item has a `static` height mode.
  case dynamicAndStretchToTallestItemInRow

}
