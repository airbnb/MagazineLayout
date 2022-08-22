// Created by Bryan Keller on 8/22/22.
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

import UIKit

extension UITraitCollection {

  // The documentation mentions that 0 is a possible value, so we guard against this.
  // It's unclear whether values between 0 and 1 are possible, otherwise `max(scale, 1)` would
  // suffice.
  var nonZeroDisplayScale: CGFloat {
    displayScale > 0 ? displayScale : 1
  }

}
