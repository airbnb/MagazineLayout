// Created by bryankeller on 8/20/18.
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

import XCTest

@testable import MagazineLayout

final class ElementLocationFramePairsTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    elementLocationFramePairs = ElementLocationFramePairs()
  }

  func testEmpty() {
    let expectedDescriptions = [String]()

    var descriptions = [String]()
    for elementLocationFramePair in elementLocationFramePairs {
      let description = elementLocationFramePairDescription(from: elementLocationFramePair)
      descriptions.append(description)
    }

    XCTAssert(descriptions == expectedDescriptions)
  }

  func testOneElement() {
    let expectedDescriptions = [
      "{0, 0} & (0.0, 0.0, 100.0, 100.0)",
    ]

    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 0, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))

    var descriptions = [String]()
    for elementLocationFramePair in elementLocationFramePairs {
      let description = elementLocationFramePairDescription(from: elementLocationFramePair)
      descriptions.append(description)
    }

    XCTAssert(descriptions == expectedDescriptions)
  }

  func testTwoElements() {
    let expectedDescriptions = [
      "{0, 0} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 1} & (0.0, 0.0, 100.0, 100.0)",
    ]

    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 0, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 1, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))

    var descriptions = [String]()
    for elementLocationFramePair in elementLocationFramePairs {
      let description = elementLocationFramePairDescription(from: elementLocationFramePair)
      descriptions.append(description)
    }

    XCTAssert(descriptions == expectedDescriptions)
  }

  func testManyElements() {
    let expectedDescriptions = [
      "{0, 0} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 1} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 3} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 4} & (0.0, 0.0, 100.0, 100.0)",
      "{1, 0} & (10.0, 10.0, 200.0, 200.0)",
      "{1, 1} & (10.0, 10.0, 200.0, 200.0)",
      "{1, 2} & (10.0, 10.0, 200.0, 200.0)",
      "{1, 3} & (10.0, 10.0, 200.0, 200.0)",
      ]

    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 0, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 1, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 3, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 4, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))

    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 0, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 1, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 2, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 3, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))

    var descriptions = [String]()
    for elementLocationFramePair in elementLocationFramePairs {
      let indexPathFramePairDescription = elementLocationFramePairDescription(
        from: elementLocationFramePair)
      descriptions.append(indexPathFramePairDescription)
    }

    XCTAssert(descriptions == expectedDescriptions)
  }

  func testManyElementsIteratedOverMultipleTimes() {
    let expectedDescriptions = [
      "{0, 0} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 1} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 3} & (0.0, 0.0, 100.0, 100.0)",
      "{0, 4} & (0.0, 0.0, 100.0, 100.0)",
      "{1, 0} & (10.0, 10.0, 200.0, 200.0)",
      "{1, 1} & (10.0, 10.0, 200.0, 200.0)",
      "{1, 2} & (10.0, 10.0, 200.0, 200.0)",
      "{1, 3} & (10.0, 10.0, 200.0, 200.0)",
      ]

    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 0, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 1, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 3, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 4, sectionIndex: 0),
        frame: CGRect(x: 0, y: 0, width: 100, height: 100)))

    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 0, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 1, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 2, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))
    elementLocationFramePairs.append(
      ElementLocationFramePair(
        elementLocation: ElementLocation(elementIndex: 3, sectionIndex: 1),
        frame: CGRect(x: 10, y: 10, width: 200, height: 200)))

    var descriptions = [String]()
    for elementLocationFramePair in elementLocationFramePairs {
      let description = elementLocationFramePairDescription(from: elementLocationFramePair)
      descriptions.append(description)
    }

    XCTAssert(descriptions == expectedDescriptions)

    var descriptions2 = [String]()
    for elementLocationFramePair in elementLocationFramePairs {
      let description = elementLocationFramePairDescription(from: elementLocationFramePair)
      descriptions2.append(description)
    }

    XCTAssert(descriptions2 == expectedDescriptions)
  }

  // MARK: Private

  private var elementLocationFramePairs: ElementLocationFramePairs!

  private func elementLocationFramePairDescription(
    from elementLocationFramePair: ElementLocationFramePair)
    -> String
  {
    let sectionIndex = elementLocationFramePair.elementLocation.sectionIndex
    let elementIndex = elementLocationFramePair.elementLocation.elementIndex
    let frame = elementLocationFramePair.frame
    return "{\(sectionIndex), \(elementIndex)} & \(frame)"
  }

}
