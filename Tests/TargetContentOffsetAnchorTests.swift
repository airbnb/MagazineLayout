// Created by bryankeller on 12/15/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

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

final class TargetContentOffsetAnchorTests: XCTestCase {

  // MARK: To-to-Bottom Anchor Tests

  func testAnchor_TopToBottom_ScrolledToTop() throws {
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .topToBottom,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: -50, width: 300, height: 400),
      contentHeight: 2000,
      scale: 1,
      firstVisibleItemID: UUID(),
      lastVisibleItemID: UUID(),
      firstVisibleItemFrame: CGRect(x: 0, y: 0, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 290, width: 300, height: 20))
    XCTAssert(anchor == .top)
  }

  func testAnchor_TopToBottom_ScrolledToMiddle() throws {
    let topID = UUID()
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .topToBottom,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 500, width: 300, height: 400),
      contentHeight: 2000,
      scale: 1,
      firstVisibleItemID: topID,
      lastVisibleItemID: UUID(),
      firstVisibleItemFrame: CGRect(x: 0, y: 560, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 800, width: 300, height: 20))
    XCTAssert(anchor == .topItem(id: topID, distanceFromTop: 10))
  }

  func testAnchor_TopToBottom_ScrolledToBottom() throws {
    let topID = UUID()
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .topToBottom,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 1630, width: 300, height: 400),
      contentHeight: 2000,
      scale: 1,
      firstVisibleItemID: topID,
      lastVisibleItemID: UUID(),
      firstVisibleItemFrame: CGRect(x: 0, y: 1700, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 1950, width: 300, height: 20))
    XCTAssert(anchor == .topItem(id: topID, distanceFromTop: 20))
  }

  func testAnchor_TopToBottom_SmallContentHeight() throws {
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .topToBottom,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: -50, width: 300, height: 400),
      contentHeight: 50,
      scale: 1,
      firstVisibleItemID: UUID(),
      lastVisibleItemID: UUID(),
      firstVisibleItemFrame: CGRect(x: 0, y: 0, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 30, width: 300, height: 20))
    XCTAssert(anchor == .top)
  }

  // MARK: Bottom-to-Top Anchor Tests

  func testAnchor_BottomToTop_ScrolledToTop() throws {
    let bottomID = UUID()
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .bottomToTop,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: -50, width: 300, height: 400),
      contentHeight: 2000,
      scale: 1,
      firstVisibleItemID: UUID(),
      lastVisibleItemID: bottomID,
      firstVisibleItemFrame: CGRect(x: 0, y: 0, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 290, width: 300, height: 20))
    XCTAssert(anchor == .bottomItem(id: bottomID, distanceFromBottom: -10))
  }

  func testAnchor_BottomToTop_ScrolledToMiddle() throws {
    let bottomID = UUID()
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .bottomToTop,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 500, width: 300, height: 400),
      contentHeight: 2000,
      scale: 1,
      firstVisibleItemID: UUID(),
      lastVisibleItemID: bottomID,
      firstVisibleItemFrame: CGRect(x: 0, y: 560, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 800, width: 300, height: 20))
    XCTAssert(anchor == .bottomItem(id: bottomID, distanceFromBottom: -50))
  }

  func testAnchor_BottomToTop_ScrolledToBottom() throws {
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .bottomToTop,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 1630, width: 300, height: 400),
      contentHeight: 2000,
      scale: 1,
      firstVisibleItemID: UUID(),
      lastVisibleItemID: UUID(),
      firstVisibleItemFrame: CGRect(x: 0, y: 1700, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 1950, width: 300, height: 20))
    XCTAssert(anchor == .bottom)
  }

  func testAnchor_BottomToTop_SmallContentHeight() throws {
    let anchor = TargetContentOffsetAnchor.targetContentOffsetAnchor(
      verticalLayoutDirection: .bottomToTop,
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: -50, width: 300, height: 400),
      contentHeight: 50,
      scale: 1,
      firstVisibleItemID: UUID(),
      lastVisibleItemID: UUID(),
      firstVisibleItemFrame: CGRect(x: 0, y: 0, width: 300, height: 20),
      lastVisibleItemFrame: CGRect(x: 0, y: 30, width: 300, height: 20))
    XCTAssert(anchor == .bottom)
  }

  // MARK: Top-to-Bottom Target Content Offset Tests

  func testOffset_TopToBottom_ScrolledToTop() {
    let anchor = TargetContentOffsetAnchor.top
    let offset = anchor.yOffset(
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: -50, width: 300, height: 400),
      contentHeight: 2000,
      indexPathForItemID: { _ in IndexPath(item: 0, section: 0) },
      frameForItemAtIndexPath: { _ in CGRect(x: 0, y: 0, width: 300, height: 20) })
    XCTAssert(offset == -50)
  }

  func testOffset_TopToBottom_ScrolledToMiddle() {
    let anchor = TargetContentOffsetAnchor.topItem(id: UUID(), distanceFromTop: 10)
    let offset = anchor.yOffset(
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 500, width: 300, height: 400),
      contentHeight: 2000,
      indexPathForItemID: { _ in IndexPath(item: 2, section: 0) },
      frameForItemAtIndexPath: { _ in CGRect(x: 0, y: 560, width: 300, height: 20) })
    XCTAssert(offset == 500)
  }

  func testOffset_TopToBottom_ScrolledToBottom() {
    let anchor = TargetContentOffsetAnchor.topItem(id: UUID(), distanceFromTop: 10)
    let offset = anchor.yOffset(
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 1630, width: 300, height: 400),
      contentHeight: 2000,
      indexPathForItemID: { _ in IndexPath(item: 6, section: 0) },
      frameForItemAtIndexPath: { _ in CGRect(x: 0, y: 1700, width: 300, height: 20) })
    XCTAssert(offset == 1630)
  }

  // MARK: Bottom-to-Top Target Content Offset Tests

  func testOffset_BottomToTop_ScrolledToTop() {
    let anchor = TargetContentOffsetAnchor.bottomItem(id: UUID(), distanceFromBottom: -10)
    let offset = anchor.yOffset(
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: -50, width: 300, height: 400),
      contentHeight: 2000,
      indexPathForItemID: { _ in IndexPath(item: 4, section: 0) },
      frameForItemAtIndexPath: { _ in CGRect(x: 0, y: 290, width: 300, height: 20) })
    XCTAssert(offset == -50)
  }

  func testOffset_BottomToTop_ScrolledToMiddle() {
    let anchor = TargetContentOffsetAnchor.bottomItem(id: UUID(), distanceFromBottom: -50)
    let offset = anchor.yOffset(
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 500, width: 300, height: 400),
      contentHeight: 2000,
      indexPathForItemID: { _ in IndexPath(item: 6, section: 0) },
      frameForItemAtIndexPath: { _ in CGRect(x: 0, y: 800, width: 300, height: 20) })
    XCTAssert(offset == 500)
  }

  func testOffset_BottomToTop_ScrolledToBottom() {
    let anchor = TargetContentOffsetAnchor.bottom
    let offset = anchor.yOffset(
      topInset: 50,
      bottomInset: 30,
      bounds: CGRect(x: 0, y: 1630, width: 300, height: 400),
      contentHeight: 2000,
      indexPathForItemID: { _ in IndexPath(item: 10, section: 0) },
      frameForItemAtIndexPath: { _ in CGRect(x: 0, y: 1950, width: 300, height: 20) })
    XCTAssert(offset == 1630)
  }

}
