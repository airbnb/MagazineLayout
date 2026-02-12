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
    XCTAssert(layoutState.targetContentOffsetAnchor == .top(overScrollDistance: 0))
  }

  func testAnchor_TopToBottom_ScrolledToMiddle() throws {
    let bounds = CGRect(x: 0, y: 500, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let indexPath = IndexPath(item: 6, section: 0)
    let id = layoutState.modelState.idForItemModel(at: indexPath)!
    XCTAssert(layoutState.targetContentOffsetAnchor == .topItem(id: id, elementLocation: ElementLocation(indexPath: indexPath), distanceFromTop: -25))
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
    let indexPath = IndexPath(item: 9, section: 0)
    let id = layoutState.modelState.idForItemModel(at: indexPath)!
    XCTAssert(layoutState.targetContentOffsetAnchor == .topItem(id: id, elementLocation: ElementLocation(indexPath: indexPath), distanceFromTop: 25))
  }

  func testAnchor_TopToBottom_NoFullyVisibleCells_UsesFallback() throws {
    // Create a model state with very large items (500px each) that are taller than the bounds (400px)
    let bounds = CGRect(x: 0, y: 250, width: 300, height: 400)
    let modelState = modelStateWithLargeItems(bounds: bounds)
    let layoutState = LayoutState(
      modelState: modelState,
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)

    // Since no items are fully visible, the fallback should use the first partially visible item
    // instead of returning .top or .bottom
    let indexPath = IndexPath(item: 0, section: 0)
    let id = layoutState.modelState.idForItemModel(at: indexPath)!
    XCTAssert(layoutState.targetContentOffsetAnchor == .topItem(id: id, elementLocation: ElementLocation(indexPath: indexPath), distanceFromTop: -300))
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
    let indexPath = IndexPath(item: 3, section: 0)
    let id = layoutState.modelState.idForItemModel(at: indexPath)!
    XCTAssert(layoutState.targetContentOffsetAnchor == .bottomItem(id: id, elementLocation: ElementLocation(indexPath: indexPath), distanceFromBottom: -90))
  }

  func testAnchor_BottomToTop_ScrolledToMiddle() throws {
    let bounds = CGRect(x: 0, y: 500, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let indexPath = IndexPath(item: 10, section: 0)
    let id = layoutState.modelState.idForItemModel(at: indexPath)!
    XCTAssert(layoutState.targetContentOffsetAnchor == .bottomItem(id: id, elementLocation: ElementLocation(indexPath: indexPath), distanceFromBottom: -10))
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
    XCTAssert(layoutState.targetContentOffsetAnchor == .bottom(overScrollDistance: 0))
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
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == -50)
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
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == 500)
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
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == 690)
  }

  func testOffset_TopToBottom_OverscrolledPastTop() {
    // bounds.minY = -80 is 30px past minContentOffset.y (-50), simulating rubber-banding
    let bounds = CGRect(x: 0, y: -80, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .topToBottom)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(targetContentOffsetAnchor == .top(overScrollDistance: 30))
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == -80)
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
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == -50)
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
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == 500)
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
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == 690)
  }

  func testOffset_BottomToTop_OverscrolledPastBottom() {
    let measurementBounds = CGRect(x: 0, y: 0, width: 300, height: 400)
    let measurementLayoutState = LayoutState(
      modelState: modelState(bounds: measurementBounds),
      bounds: measurementBounds,
      contentInset: UIEdgeInsets(top: 50, left: 0, bottom: 30, right: 0),
      scale: 1,
      verticalLayoutDirection: .bottomToTop)
    let maxContentOffset = measurementLayoutState.maxContentOffset

    // 25px past maxContentOffset, simulating rubber-banding
    let bounds = CGRect(x: 0, y: maxContentOffset.y + 25, width: 300, height: 400)
    let layoutState = LayoutState(
      modelState: modelState(bounds: bounds),
      bounds: bounds,
      contentInset: measurementLayoutState.contentInset,
      scale: measurementLayoutState.scale,
      verticalLayoutDirection: measurementLayoutState.verticalLayoutDirection)
    let targetContentOffsetAnchor = layoutState.targetContentOffsetAnchor
    XCTAssert(targetContentOffsetAnchor == .bottom(overScrollDistance: 25))
    XCTAssert(layoutState.yOffset(for: targetContentOffsetAnchor, isPerformingBatchUpdates: false) == maxContentOffset.y + 25)
  }

  // MARK: Private

  private let idGenerator = IDGenerator()

  private func modelState(bounds: CGRect) -> ModelState {
    let modelState = ModelState(currentVisibleBoundsProvider: { bounds })
    let sections = [
      SectionModel(
        idGenerator: idGenerator,
        itemModels: [
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: nil),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 70),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 90),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 80),
          ItemModel(idGenerator: idGenerator, widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: nil),
          ItemModel(idGenerator: idGenerator, widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 135),
          ItemModel(idGenerator: idGenerator, widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 135),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 55),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 105),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 80),
          ItemModel(idGenerator: idGenerator, widthMode: .halfWidth, preferredHeight: 95),
          ItemModel(idGenerator: idGenerator, widthMode: .thirdWidth, preferredHeight: 200),
          ItemModel(idGenerator: idGenerator, widthMode: .thirdWidth, preferredHeight: 200),
          ItemModel(idGenerator: idGenerator, widthMode: .thirdWidth, preferredHeight: nil),
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

  private func modelStateWithLargeItems(bounds: CGRect) -> ModelState {
    let modelState = ModelState(currentVisibleBoundsProvider: { bounds })
    let sections = [
      SectionModel(
        idGenerator: idGenerator,
        itemModels: [
          // Create items that are 500px tall, larger than the 400px bounds height
          ItemModel(idGenerator: idGenerator, widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 500),
          ItemModel(idGenerator: idGenerator, widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 500),
          ItemModel(idGenerator: idGenerator, widthMode: .fullWidth(respectsHorizontalInsets: true), preferredHeight: 500),
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
  init(
    idGenerator: IDGenerator,
    widthMode: MagazineLayoutItemWidthMode,
    preferredHeight: CGFloat?)
  {
    self.init(
      idGenerator: idGenerator,
      sizeMode: .init(widthMode: widthMode, heightMode: .dynamic),
      height: 150)
    self.preferredHeight = preferredHeight
  }
}
