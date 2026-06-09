// Created by Bryan Keller on 6/5/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

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

extension Array {

  subscript(safe index: Int) -> Element? {
    index >= 0 && index < count ? self[index] : nil
  }

  /// Grows the array (if needed) so `index` is in bounds, back-filling any gap between the current
  /// `count` and `index` with `filler` so the array stays dense and positionally addressable.
  mutating func grow(toInclude index: Int, fillingWith filler: @autoclosure () -> Element) {
    while index >= count { append(filler()) }
  }
}
