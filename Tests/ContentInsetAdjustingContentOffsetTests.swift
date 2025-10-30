// Created by Bryn Bodayle on 6/20/25.
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

import XCTest
@testable import MagazineLayout

final class ContentInsetAdjustingContentOffsetTests: XCTestCase {

  func testContentOffsetIsNotAdjustedForTopInsetChangeWithToTopBottomLayout() {
    let layout = MagazineLayout()
    let collectionView = StubCollectionView(
      frame: .zero,
      collectionViewLayout: layout)
    let context = MagazineLayoutInvalidationContext()
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .zero)

    collectionView.stubAdjustedContentInset = .init(top: 50, left: 0, bottom: 50, right: 0)
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .zero)
  }

  func testContentOffsetIsAdjustedForTopInsetChangeWithBottomToTopLayout() {
    let layout = MagazineLayout()
    layout.verticalLayoutDirection = .bottomToTop
    let collectionView = StubCollectionView(
      frame: .zero,
      collectionViewLayout: layout)
    let context = MagazineLayoutInvalidationContext()
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .zero)

    collectionView.stubAdjustedContentInset = .init(top: 50, left: 0, bottom: 0, right: 0)
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .init(x: 0, y: 50))
  }

  func testContentOffsetIsAdjustedForBottomInsetChangeWithBottomToTopLayout() {
    let layout = MagazineLayout()
    layout.verticalLayoutDirection = .bottomToTop
    let collectionView = StubCollectionView(
      frame: .zero,
      collectionViewLayout: layout)
    let context = MagazineLayoutInvalidationContext()
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .zero)

    collectionView.stubAdjustedContentInset = .init(top: 0, left: 0, bottom: 75, right: 0)
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .init(x: 0, y: 75))
  }

  func testContentOffsetIsAdjustedForTopAndBottomInsetChangesWithBottomToTopLayout() {
    let layout = MagazineLayout()
    layout.verticalLayoutDirection = .bottomToTop
    let collectionView = StubCollectionView(
      frame: .zero,
      collectionViewLayout: layout)
    let context = MagazineLayoutInvalidationContext()
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .zero)

    collectionView.stubAdjustedContentInset = .init(top: 100, left: 0, bottom: 100, right: 0)
    layout.invalidateLayout(with: context)
    XCTAssertEqual(context.contentOffsetAdjustment, .init(x: 0, y: 200))
  }
}

private class StubCollectionView: UICollectionView {

  var stubAdjustedContentInset: UIEdgeInsets = .zero
  override var adjustedContentInset: UIEdgeInsets {
    stubAdjustedContentInset
  }
}
