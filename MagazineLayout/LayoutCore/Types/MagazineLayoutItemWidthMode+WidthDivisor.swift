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

extension MagazineLayoutItemWidthMode {

  /// Returns the divisor for a given item width mode.
  ///
  /// When divided into the width of the collection view, the result equals the width of the item
  /// before taking into account horizontal insets.
  var widthDivisor: CGFloat {
    switch self {
    case .fullWidth: return 1
    case let .fractionalWidth(divisor): return CGFloat(divisor)
    }
  }

}
