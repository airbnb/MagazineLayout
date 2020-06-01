// Created by bryankeller on 8/13/18.
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

import Foundation

/// Represents the location of an item in a section.
///
/// Initializing a `ElementLocation` is measurably faster than initializing an `IndexPath`.
/// On an iPhone X, compiled with -Os optimizations, it's about 35x faster to initialize this struct
/// compared to an `IndexPath`.
struct ElementLocation: Hashable {

  // MARK: Lifecycle

  init(elementIndex: Int, sectionIndex: Int) {
    self.elementIndex = elementIndex
    self.sectionIndex = sectionIndex
  }

  init(indexPath: IndexPath) {
    if indexPath.count == 2 {
      elementIndex = indexPath.item
      sectionIndex = indexPath.section
    } else {
      // `UICollectionViewFlowLayout` is able to work with empty index paths (`IndexPath()`). Per
      // the `IndexPath` documntation, an index path that uses `section` or `item` must have exactly
      // 2 elements. If not, we default to {0, 0} to prevent crashes.
      elementIndex = 0
      sectionIndex = 0
    }
  }

  // MARK: Internal

  let elementIndex: Int
  let sectionIndex: Int

  var indexPath: IndexPath {
    return IndexPath(item: elementIndex, section: sectionIndex)
  }

}
