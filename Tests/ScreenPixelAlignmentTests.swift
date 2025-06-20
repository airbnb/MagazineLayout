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

import XCTest
@testable import MagazineLayout

final class ScreenPixelAlignmentTests: XCTestCase {

  // MARK: Value alignment tests

  func test1xScaleValueAlignment() {
    XCTAssert(
      CGFloat(1).alignedToPixel(forScreenWithScale: 1) == CGFloat(1),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(1.5).alignedToPixel(forScreenWithScale: 1) == CGFloat(2),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(500.8232134315).alignedToPixel(forScreenWithScale: 1) == CGFloat(501),
      "Incorrect screen pixel alignment")
  }

  func test2xScaleValueAlignment() {
    XCTAssert(
      CGFloat(1).alignedToPixel(forScreenWithScale: 2) == CGFloat(1),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(1.5).alignedToPixel(forScreenWithScale: 2) == CGFloat(1.5),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(500.8232134315).alignedToPixel(forScreenWithScale: 2) == CGFloat(501),
      "Incorrect screen pixel alignment")
  }

  func test3xScaleValueAlignment() {
    XCTAssert(
      CGFloat(1).alignedToPixel(forScreenWithScale: 3) == CGFloat(1),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(1.5).alignedToPixel(forScreenWithScale: 3) == CGFloat(1.6666666666666667),
      "Incorrect screen pixel alignment")
    XCTAssert(
      CGFloat(500.8232134315).alignedToPixel(forScreenWithScale: 3) == CGFloat(500.6666666666667),
      "Incorrect screen pixel alignment")
  }

  // MARK: Approximate equality tests

  func testApproximateEquality() {
    XCTAssert(CGFloat(1.48).isEqual(to: 1.52, screenScale: 2))
    XCTAssert(!CGFloat(1).isEqual(to: 10, screenScale: 9))
    XCTAssert(!CGFloat(1).isEqual(to: 10, screenScale: 9))
    XCTAssert(!CGFloat(1).isEqual(to: 9, screenScale: 9))
    XCTAssert(!CGFloat(1.333).isEqual(to: 1.666, screenScale: 3))
  }

}

