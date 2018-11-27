// Created by bryankeller on 9/24/18.
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

/// `MagazineLayout`'s invalidation context type.
///
/// Used to indicate that collection view properties and/or delegate layout metrics changed.
public final class MagazineLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {

  /// Indicates whether to recompute the positions and sizes of elements based on the current
  /// collection view and delegate layout metrics.
  public var invalidateLayoutMetrics = true

}
