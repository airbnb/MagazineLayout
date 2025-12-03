// Created by Bryan Keller on 12/3/25.
// Copyright © 2025 Airbnb Inc. All rights reserved.

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

/// Generates sequential `UInt64` IDs for section and item models. 18,446,744,073,709,551,615 ought to be enough for any layout.
final class IDGenerator {

  // MARK: Internal

  func next() -> UInt64 {
    defer { id &+= 1 }
    return id
  }

  // MARK: Private

  private var id: UInt64 = 0
}
