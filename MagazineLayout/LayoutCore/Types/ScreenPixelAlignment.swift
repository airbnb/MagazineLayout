// Created by Bryan Keller on 5/12/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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

extension CGFloat {

  /// Rounds `self` so that it's aligned on a pixel boundary for a screen with the provided scale.
  func alignedToPixel(forScreenWithScale scale: CGFloat) -> CGFloat {
    (self * scale).rounded() / scale
  }

  /// Tests `self` for approximate equality, first rounding the operands to be pixel-aligned for a screen with the given
  /// `screenScale`. For example, 1.48 equals 1.52 if the `screenScale` is `2`.
  func isEqual(to rhs: CGFloat, screenScale: CGFloat) -> Bool {
    let lhs = alignedToPixel(forScreenWithScale: screenScale)
    let rhs = rhs.alignedToPixel(forScreenWithScale: screenScale)
    return lhs == rhs
  }

}
