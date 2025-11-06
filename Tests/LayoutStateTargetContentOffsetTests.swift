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

final class LayoutStateTargetContentOffsetTests: XCTestCase {

  // MARK: Top-to-Bottom Anchor Tests

  func testAnchor_TopToBottom_ScrolledToTop() throws {
    let bounds = CGRect(x: 0, y: -50, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    XCTAssert(layoutState.targetContentOffsetAnchor == .top)
  }

  func testAnchor_TopToBottom_ScrolledToMiddle() throws {
    let bounds = CGRect(x: 0, y: 500, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let id = layoutState.modelState.idForItemModel(at: IndexPath(item: 5, section: 0))!
    XCTAssert(layoutState.targetContentOffsetAnchor == .topItem(id: id, distanceFromTop: -160))
  }

  func testAnchor_TopToBottom_ScrolledToBottom() throws {
    let measurementBounds = CGRect(x: 0, y: 0, width: 300, height: 400)
    let measurementLayoutState = LayoutState(
      modelState: modelState(bounds: measurementBounds),
      bounds: measurementBounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let maxContentOffset = measurementLayoutState.maxContentOffset

    let bounds = CGRect(origin: maxContentOffset, size: measurementBounds.size)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: measurementLayoutState.contentInset,
      scale: measurementLayoutState.scale,
      verticalLayoutDirection: measurementLayoutState.verticalLayoutDirection)
    let id = layoutState.modelState.idForItemModel(at: IndexPath(item: 7, section: 0))!
    XCTAssert(layoutState.targetContentOffsetAnchor == .topItem(id: id, distanceFromTop: -80))
  }

  // MARK: Bottom-to-Top Anchor Tests

  func testAnchor_BottomToTop_ScrolledToTop() throws {
    let bounds = CGRect(x: 0, y: -50, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let id = layoutState.modelState.idForItemModel(at: IndexPath(item: 3, section: 0))!
    XCTAssert(layoutState.targetContentOffsetAnchor == .bottomItem(id: id, distanceFromBottom: -90))
  }

  func testAnchor_BottomToTop_ScrolledToMiddle() throws {
    let bounds = CGRect(x: 0, y: 500, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let id = layoutState.modelState.idForItemModel(at: IndexPath(item: 12, section: 0))!
    XCTAssert(layoutState.targetContentOffsetAnchor == .bottomItem(id: id, distanceFromBottom: 190))
  }

  func testAnchor_BottomToTop_ScrolledToBottom() throws {
    let measurementBounds = CGRect(x: 0, y: 0, width: 300, height: 400)
    let measurementLayoutState = LayoutState(
      modelState: modelState(bounds: measurementBounds),
      bounds: measurementBounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let maxContentOffset = measurementLayoutState.maxContentOffset

    let bounds = CGRect(origin: maxContentOffset, size: measurementBounds.size)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: measurementLayoutState.contentInset,
      scale: measurementLayoutState.scale,
      verticalLayoutDirection: measurementLayoutState.verticalLayoutDirection)
    XCTAssert(layoutState.targetContentOffsetAnchor == .bottom)
  }

  // MARK: Top-to-Bottom Target Content Offset Tests

  func testOffset_TopToBottom_ScrolledToTop() {
    let bounds = CGRect(x: 0, y: -50, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor) == -50)
  }

  func testOffset_TopToBottom_ScrolledToMiddle() {
    let bounds = CGRect(x: 0, y: 500, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor) == 500)
  }

  func testOffset_TopToBottom_ScrolledToBottom() {
    let measurementBounds = CGRect(x: 0, y: 0, width: 300, height: 400)
    let measurementLayoutState = LayoutState(
      modelState: modelState(bounds: measurementBounds),
      bounds: measurementBounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let maxContentOffset = measurementLayoutState.maxContentOffset

    let bounds = CGRect(origin: maxContentOffset, size: measurementBounds.size)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: measurementLayoutState.contentInset,
      scale: measurementLayoutState.scale,
      verticalLayoutDirection: measurementLayoutState.verticalLayoutDirection)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor) == 690)
  }

  // MARK: Bottom-to-Top Target Content Offset Tests

  func testOffset_BottomToTop_ScrolledToTop() {
    let bounds = CGRect(x: 0, y: -50, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor) == -50)
  }

  func testOffset_BottomToTop_ScrolledToMiddle() {
    let bounds = CGRect(x: 0, y: 500, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor) == 500)
  }

  func testOffset_BottomToTop_ScrolledToBottom() {
    let measurementBounds = CGRect(x: 0, y: 0, width: 300, height: 400)
    let measurementLayoutState = LayoutState(
      modelState: modelState(bounds: measurementBounds),
      bounds: measurementBounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let maxContentOffset = measurementLayoutState.maxContentOffset

    let bounds = CGRect(origin: maxContentOffset, size: measurementBounds.size)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: measurementLayoutState.contentInset,
      scale: measurementLayoutState.scale,
      verticalLayoutDirection: measurementLayoutState.verticalLayoutDirection)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor) == 690)
  }

  // MARK: Private

  private func modelState(bounds: CGRect) -> ModelState {
    let modelState = ModelState(currentVisibleBoundsProvider: { bounds })
    let sections = [
      SectionModel(
        itemModels: [
          ItemModel(widthMode: .halfWidth, preferredHeight: nil),
          ItemModel(widthMode: .halfWidth, preferredHeight: 70),
          ItemModel(widthMode: .halfWidth, preferredHeight: 90),
          ItemModel(widthMode: .halfWidth, preferredHeight: 80),
          ItemModel(widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: nil),
          ItemModel(widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 135),
          ItemModel(widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 135),
          ItemModel(widthMode: .halfWidth, preferredHeight: 55),
          ItemModel(widthMode: .halfWidth, preferredHeight: 105),
          ItemModel(widthMode: .halfWidth, preferredHeight: 80),
          ItemModel(widthMode: .halfWidth, preferredHeight: 95),
          ItemModel(widthMode: .thirdWidth, preferredHeight: 200),
          ItemModel(widthMode: .thirdWidth, preferredHeight: 200),
          ItemModel(widthMode: .thirdWidth, preferredHeight: nil),
        ],
        headerModel: nil,
        footerModel: nil,
        backgroundModel: nil,
        metrics: MagazineLayoutSectionMetrics(
          collectionViewWidth: bounds.width,
          collectionViewContentInset: .zero,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          sectionInsets: .zero,
          itemInsets: .zero,
          scale: 1))
    ]
    modelState.setSections(sections)
    return modelState
  }

}

// MARK: - ItemModel

private extension ItemModel {
  init(widthMode: MagazineLayoutItemWidthMode, preferredHeight: CGFloat?) {
    self.init(sizeMode: .init(widthMode: widthMode, heightMode: .dynamic), height: 150)
    self.preferredHeight = preferredHeight
  }
}
