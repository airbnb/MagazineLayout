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

// MARK: - MagazineLayoutHeaderVisibilityMode

/// Represents the visibility mode for a header.
public enum MagazineLayoutHeaderVisibilityMode: Hashable {

  /// This visibility mode will cause the header to be displayed using the specified height mode in
  /// its respective section. If `pinToVisibleBounds` is true, the header will pin to the visible
  /// bounds of the collection view while its containing section is visible.
  case visible(heightMode: MagazineLayoutHeaderHeightMode, pinToVisibleBounds: Bool)

  /// This visibility mode will cause the header to not be visibile in its respective section.
  case hidden

  /// This visibility mode will cause the header to be displayed using the specified height mode in
  /// its respective section.
  public static func visible(
    heightMode: MagazineLayoutHeaderHeightMode)
    -> MagazineLayoutHeaderVisibilityMode
  {
    return .visible(heightMode: heightMode, pinToVisibleBounds: false)
  }

}

// MARK: - MagazineLayoutHeaderHeightMode

/// Represents the vertical sizing mode for a header.
public enum MagazineLayoutHeaderHeightMode: Hashable {

  /// This height mode will force the header to be displayed with a height equal to `height`.
  ///
  /// To properly support multiline labels, dynamic type, and other technologies that could affect
  /// the height of your headers dynamically, consider using the `dynamic` height mode.
  case `static`(height: CGFloat)

  /// This height mode will cause the header to self-size in the vertical direction.
  ///
  /// In practice, self-sizing in the vertical direction means that the header will get its height
  /// from the Auto Layout engine. Use this height mode for headers whose height is not known
  /// upfront. For example, if you support multiline labels or dynamic type, your height is likely
  /// not known until the Auto Layout engine resolves the layout at runtime.
  case dynamic

}
