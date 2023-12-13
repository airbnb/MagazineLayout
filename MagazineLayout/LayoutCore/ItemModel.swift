// Created by bryankeller on 7/9/17.
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
import Foundation

/// Represents the layout information for an item in a section.
struct ItemModel {

  // MARK: Lifecycle

  init(sizeMode: MagazineLayoutItemSizeMode, height: CGFloat) {
    id = UUID()
    self.sizeMode = sizeMode
    originInSection = .zero
    size = CGSize(width: 0, height: height)
  }

  // MARK: Internal

  let id: UUID

  var sizeMode: MagazineLayoutItemSizeMode
  var originInSection: CGPoint
  var size: CGSize
  var preferredHeight: CGFloat?

}
