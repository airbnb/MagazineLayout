// Created by Bryan Keller on 5/12/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

// Created by Bryan Keller on 3/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

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

final class CGFloatApproximateEqualityTests: XCTestCase {

  func testApproximateEquality() {
    XCTAssert(CGFloat(1.48).isEqual(to: 1.52, threshold: 0.05))
    XCTAssert(!CGFloat(1.48).isEqual(to: 1.53, threshold: 0.05))

    XCTAssert(CGFloat(1).isEqual(to: 10, threshold: 9))
    XCTAssert(!CGFloat(1).isEqual(to: 11, threshold: 9))

    XCTAssert(CGFloat(1).isEqual(to: 10, threshold: 9))
    XCTAssert(!CGFloat(1).isEqual(to: 11, threshold: 9))

    XCTAssert(CGFloat(1.333).isEqual(to: 1.666, threshold: 1 / 3))
    XCTAssert(!CGFloat(1.332).isEqual(to: 1.666, threshold: 1 / 3))
  }

}

