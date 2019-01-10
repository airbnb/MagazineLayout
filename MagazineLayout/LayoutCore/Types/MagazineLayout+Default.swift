// Created by bryankeller on 10/18/18.
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

extension MagazineLayout {

  /// Constants for layout sizing and spacing defaults.
  public enum Default {

    static let ItemSizeMode = MagazineLayoutItemSizeMode(
      widthMode: .fullWidth(respectsHorizontalInsets: true),
      heightMode: MagazineLayoutItemHeightMode.static(height: ItemHeight))
    static let HeaderVisibilityMode = MagazineLayoutHeaderVisibilityMode.hidden
    static let BackgroundVisibilityMode = MagazineLayoutBackgroundVisibilityMode.hidden

    static let ItemHeight: CGFloat = 150
    static let HeaderHeight: CGFloat = 44
    static let VerticalSpacing: CGFloat = 0
    static let HorizontalSpacing: CGFloat = 0
    static let ItemInsets: UIEdgeInsets = .zero

  }

}
