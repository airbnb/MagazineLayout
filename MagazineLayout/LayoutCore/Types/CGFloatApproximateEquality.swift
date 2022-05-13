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

  /// Tests `self` for approximate equality using the threshold value. For example, 1.48 equals 1.52 if the threshold is 0.05.
  /// `threshold` will be treated as a positive value by taking its absolute value.
  func isEqual(to rhs: CGFloat, threshold: CGFloat) -> Bool {
    abs(self - rhs) <= abs(threshold)
  }

}
