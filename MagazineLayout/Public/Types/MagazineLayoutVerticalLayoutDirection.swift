// Created by bryankeller on 12/8/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

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

/// The vertical layout direction of items in the collection view. This property changes the behavior of scroll-position-preservation when
/// performing batch updates or when the collection view's bounds changes.
public enum MagazineLayoutVerticalLayoutDirection {

  /// The vertical layout direction of items goes from top to bottom. Items inserted at the top push content down. When scrolled to the
  /// top, inserted items at the top will be visible without scrolling. On bounds change (like device rotation or window size change), the
  /// topmost visible item will remain visible while items at the bottom may change their position in relation to the bottom edge.
  ///
  /// Using this layout direction is essentially the default layout direction of all collection views.
  case topToBottom

  /// The vertical layout direction of items goes from bottom to top. Items inserted at the bottom push content up. When scrolled to the
  /// bottom, inserted items at the bottom will be visible without scrolling. On bounds change (like device rotation or window size
  /// change), the bottommost visible item will remain visible while items at the top may change their position in relation to the top
  /// edge.
  ///
  ///  You might consider using this layout direction when building a message thread UI.
  case bottomToTop
}
