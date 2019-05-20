// Created by Bryan Keller on 5/23/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import XCTest

@testable import MagazineLayout

final class RowOffsetTrackerTests: XCTestCase {

  // MARK: Internal

  func testOneRow() {
    var rowOffsetTracker1 = RowOffsetTracker(numberOfRows: 1)

    XCTAssert(rowOffsetTracker1.offsetForRow(at: 0) == 0)

    rowOffsetTracker1.addOffset(-50, forRowsStartingAt: 0)
    XCTAssert(rowOffsetTracker1.offsetForRow(at: 0) == -50)

    rowOffsetTracker1.addOffset(0, forRowsStartingAt: 0)
    XCTAssert(rowOffsetTracker1.offsetForRow(at: 0) == -50)

    rowOffsetTracker1.addOffset(50, forRowsStartingAt: 0)
    XCTAssert(rowOffsetTracker1.offsetForRow(at: 0) == 0)
  }

  func testTwoRows() {
    var rowOffsetTracker2 = RowOffsetTracker(numberOfRows: 2)

    XCTAssert(rowOffsetTracker2.offsetForRow(at: 0) == 0)
    XCTAssert(rowOffsetTracker2.offsetForRow(at: 1) == 0)

    rowOffsetTracker2.addOffset(10, forRowsStartingAt: 0)
    XCTAssert(rowOffsetTracker2.offsetForRow(at: 0) == 10)
    XCTAssert(rowOffsetTracker2.offsetForRow(at: 1) == 10)

    rowOffsetTracker2.addOffset(-5, forRowsStartingAt: 1)
    rowOffsetTracker2.addOffset(20, forRowsStartingAt: 0)
    XCTAssert(rowOffsetTracker2.offsetForRow(at: 1) == 25)
    XCTAssert(rowOffsetTracker2.offsetForRow(at: 0) == 30)
  }

  func testPowerOfTwoNumberOfRows() {
    var rowOffsetTracker64 = RowOffsetTracker(numberOfRows: 64)

    XCTAssert(rowOffsetTracker64.offsetForRow(at: 0) == 0)
    XCTAssert(rowOffsetTracker64.offsetForRow(at: 63) == 0)

    rowOffsetTracker64.addOffset(-50, forRowsStartingAt: 30)
    rowOffsetTracker64.addOffset(100, forRowsStartingAt: 25)
    rowOffsetTracker64.addOffset(10, forRowsStartingAt: 63)
    rowOffsetTracker64.addOffset(10, forRowsStartingAt: 1)
    rowOffsetTracker64.addOffset(-5, forRowsStartingAt: 0)
    rowOffsetTracker64.addOffset(60, forRowsStartingAt: 23)
    rowOffsetTracker64.addOffset(62, forRowsStartingAt: -1)

    let expectedOffsets: [CGFloat] = [
      -5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
      5.0, 5.0, 5.0, 5.0, 5.0, 65.0, 65.0, 165.0, 165.0, 165.0, 165.0, 165.0, 115.0, 115.0, 115.0,
      115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0,
      115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0,
      115.0, 115.0, 115.0, 115.0, 187.0
    ]
    for i in 0..<64 {
      XCTAssert(rowOffsetTracker64.offsetForRow(at: i) == expectedOffsets[i])
    }
  }

  func testNonPowerOfTwoNumberOfRows() {
    var rowOffsetTracker70 = RowOffsetTracker(numberOfRows: 70)

    XCTAssert(rowOffsetTracker70.offsetForRow(at: 0) == 0)
    XCTAssert(rowOffsetTracker70.offsetForRow(at: 69) == 0)

    rowOffsetTracker70.addOffset(-50, forRowsStartingAt: 30)
    rowOffsetTracker70.addOffset(100, forRowsStartingAt: 25)
    rowOffsetTracker70.addOffset(10, forRowsStartingAt: 63)
    rowOffsetTracker70.addOffset(10, forRowsStartingAt: 1)
    rowOffsetTracker70.addOffset(-5, forRowsStartingAt: 0)
    rowOffsetTracker70.addOffset(60, forRowsStartingAt: 23)
    rowOffsetTracker70.addOffset(62, forRowsStartingAt: -1)
    rowOffsetTracker70.addOffset(-100, forRowsStartingAt: 65)
    rowOffsetTracker70.addOffset(0, forRowsStartingAt: 69)

    let expectedOffsets: [CGFloat] = [
      -5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
      5.0, 5.0, 5.0, 5.0, 5.0, 65.0, 65.0, 165.0, 165.0, 165.0, 165.0, 165.0, 115.0, 115.0, 115.0,
      115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0,
      115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0, 115.0,
      115.0, 115.0, 115.0, 115.0, 125.0, 125.0, 25.0, 25.0, 25.0, 25.0, 25.0
    ]
    for i in 0..<70 {
      XCTAssert(rowOffsetTracker70.offsetForRow(at: i) == expectedOffsets[i])
    }
  }

}
