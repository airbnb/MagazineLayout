// Created by tsushanth on 6/9/26.
// Copyright © 2026 Airbnb, Inc.

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

import XCTest

@testable import MagazineLayout

/// Re-runs every test in `ModelStateLayoutTests` with
/// `MagazineLayout._enableExperimentalOptimizations = true`.
///
/// The static flag is currently documented as "A temporary flag to enable safely
/// testing some optimizations" (see `MagazineLayout.swift`). It gates 35+ branches
/// across `MagazineLayout.swift`, `SectionModel.swift`, and `ModelState.swift`.
/// Without an automated check, the optimized code paths can drift away from the
/// legacy paths silently.
///
/// By subclassing `ModelStateLayoutTests` and flipping the flag in `setUp`, every
/// existing layout assertion is automatically rerun against the optimized path.
/// Any divergence between the two paths now fails a test.
///
/// `tearDown` always restores the flag to `false` so subsequent suites are not
/// affected by ordering.
@available(iOS 18.0, *)
final class ModelStateLayoutTestsWithExperimentalOptimizations: ModelStateLayoutTests {

  override func setUp() {
    MagazineLayout._enableExperimentalOptimizations = true
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
    MagazineLayout._enableExperimentalOptimizations = false
  }

}
