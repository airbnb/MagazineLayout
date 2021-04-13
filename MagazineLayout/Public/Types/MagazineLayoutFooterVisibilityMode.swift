// Created by Roman Laitarenko on 2/4/19.

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

// MARK: - MagazineLayoutFooterVisibilityMode

/// Represents the visibility mode for a footer.
public enum MagazineLayoutFooterVisibilityMode: Hashable {

  /// This visibility mode will cause the footer to be displayed using the specified height mode in
  /// its respective section. If `pinToVisibleBounds` is true, the footer will pin to the visible
  /// bounds of the collection view while its containing section is visible.
  case visible(heightMode: MagazineLayoutFooterHeightMode, pinToVisibleBounds: Bool)

  /// This visibility mode will cause the footer to not be visibile in its respective section.
  case hidden

  /// This visibility mode will cause the footer to be displayed using the specified height mode in
  /// its respective section.
  public static func visible(
    heightMode: MagazineLayoutFooterHeightMode)
    -> MagazineLayoutFooterVisibilityMode
  {
    return .visible(heightMode: heightMode, pinToVisibleBounds: false)
  }

}

// MARK: - MagazineLayoutFooterHeightMode

/// Represents the vertical sizing mode for a footer.
public enum MagazineLayoutFooterHeightMode: Hashable {

  /// This height mode will force the footer to be displayed with a height equal to `height`.
  ///
  /// To properly support multiline labels, dynamic type, and other technologies that could affect
  /// the height of your footers dynamically, consider using the `dynamic` height mode.
  case `static`(height: CGFloat)

  /// This height mode will cause the footer to self-size in the vertical direction.
  ///
  /// In practice, self-sizing in the vertical direction means that the footer will get its height
  /// from the Auto Layout engine. Use this height mode for footers whose height is not known
  /// upfront. For example, if you support multiline labels or dynamic type, your height is likely
  /// not known until the Auto Layout engine resolves the layout at runtime.
  case dynamic

}
