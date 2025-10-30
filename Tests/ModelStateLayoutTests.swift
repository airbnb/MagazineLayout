// Created by bryankeller on 11/17/18.
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

@available(iOS 18.0, *)
final class ModelStateLayoutTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    let metrics = MagazineLayoutSectionMetrics.defaultSectionMetrics(
      forCollectionViewWidth: 320,
      verticalSpacing: 30,
      horizontalSpacing: 20,
      sectionInsets: UIEdgeInsets(top: 30, left: 15, bottom: 20, right: 5),
      itemInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
      scale: 1)

    let sections = [
      (headerModel0, sizeModesAndHeights0, footerModel0),
      (headerModel1, sizeModesAndHeights1, footerModel1)
    ].map { headerModel, sizeModesAndHeights, footerModel in
      SectionModel(
        itemModels: sizeModesAndHeights.map { sizeMode, height in
          switch sizeMode.heightMode {
          case .static:
            return ItemModel(sizeMode: sizeMode, height: height)
          case .dynamic, .dynamicAndStretchToTallestItemInRow:
            return ItemModel(sizeMode: sizeMode, height: 150)
          }
        },
        headerModel: headerModel,
        footerModel: footerModel,
        backgroundModel: BackgroundModel(),
        metrics: metrics)
    }

    modelState = ModelState(currentVisibleBoundsProvider: {
      return CGRect(x: 0, y: 100, width: 320, height: 480)
    })
    modelState.setSections(sections)
  }

  override func tearDown() {
    modelState = nil
  }

  func testInitialLayout() {
    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1320.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1375.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1420.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1470.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1510.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1510.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1575.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
      ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1600.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  func testUpdatingPreferredHeights() {
    modelState.updateHeaderHeight(toPreferredHeight: 50, forSectionAtIndex: 1)

    for (itemIndex, sizeModeAndHeight) in sizeModesAndHeights0.enumerated() {
      switch sizeModeAndHeight.sizeMode.heightMode {
      case .dynamic, .dynamicAndStretchToTallestItemInRow:
        let indexPath = IndexPath(item: itemIndex, section: 0)
        modelState.updateItemHeight(
          toPreferredHeight: sizeModeAndHeight.height,
          forItemAt: indexPath)

        let preferredHeight = modelState.itemModelPreferredHeight(at: indexPath)
        XCTAssert(preferredHeight == sizeModeAndHeight.height, "Item preferred height is incorrect")
      case .static:
        continue
      }
    }

    modelState.updateFooterHeight(toPreferredHeight: 50, forSectionAtIndex: 1)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 15.0),
      CGRect(x: 25.0, y: 185.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 185.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 245.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 300.0, width: 80.0, height: 15.0),
      CGRect(x: 125.0, y: 300.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 345.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 345.0, width: 55.0, height: 15.0),
      CGRect(x: 175.0, y: 345.0, width: 55.0, height: 25.0),
      CGRect(x: 250.0, y: 345.0, width: 55.0, height: 35.0),
      CGRect(x: 25.0, y: 410.0, width: 40.0, height: 30.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 610.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 610.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 670.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 725.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 770.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 820.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 860.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 860.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 860.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 860.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 860.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 925.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 550.0, width: 300.0, height: 50.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 450.0, width: 300.0, height: 50.0),
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 950.0, width: 300.0, height: 50.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 470.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 550.0, width: 300.0, height: 450.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  func testUpdatingSectionMetrics() {
    let metrics = MagazineLayoutSectionMetrics.defaultSectionMetrics(
      forCollectionViewWidth: 100,
      verticalSpacing: 100,
      horizontalSpacing: 5,
      sectionInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4),
      itemInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
      scale: 1)

    modelState.updateMetrics(to: metrics, forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 6.0, y: 56.0, width: 88.0, height: 20.0),
      CGRect(x: 4.0, y: 176.0, width: 92.0, height: 150.0),
      CGRect(x: 6.0, y: 426.0, width: 42.0, height: 10.0),
      CGRect(x: 53.0, y: 426.0, width: 42.0, height: 30.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 6.0, y: 556.0, width: 42.0, height: 150.0),
      CGRect(x: 6.0, y: 806.0, width: 26.0, height: 150.0),
      CGRect(x: 37.0, y: 806.0, width: 26.0, height: 150.0),
      CGRect(x: 6.0, y: 1056.0, width: 18.0, height: 15.0),
      CGRect(x: 29.0, y: 1056.0, width: 18.0, height: 150.0),
      CGRect(x: 52.0, y: 1056.0, width: 18.0, height: 150.0),
      CGRect(x: 75.0, y: 1056.0, width: 18.0, height: 150.0),
      CGRect(x: 6.0, y: 1306.0, width: 14.0, height: 150.0),
      CGRect(x: 25.0, y: 1622.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1622.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1682.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1737.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1782.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1832.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1872.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1872.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1872.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1872.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1872.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1937.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 4.0, y: 4.0, width: 92.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1542.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 4.0, y: 1458.0, width: 92.0, height: 50.0),
      CGRect(x: 15.0, y: 1962.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 4.0, y: 4.0, width: 92.0, height: 1504.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 4.0, y: 4.0, width: 92.0, height: 1504.0),
      CGRect(x: 15.0, y: 1542.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  func testUpdatingItemSizeMode() {
    modelState.updateItemSizeMode(
      to: MagazineLayoutItemSizeMode(
        widthMode: .thirdWidth,
        heightMode: .static(height: 50)),
      forItemAt: IndexPath(item: 5, section: 0))
    modelState.updateItemSizeMode(
      to: MagazineLayoutItemSizeMode(
        widthMode: .fifthWidth,
        heightMode: .dynamicAndStretchToTallestItemInRow),
      forItemAt: IndexPath(item: 8, section: 1))

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 50.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1320.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1375.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1420.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1470.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 205.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1510.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1575.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1600.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  func testLayoutAfterInsertingItems() {
    // This test would have caught this issue https://github.com/airbnb/MagazineLayout/issues/40

    modelState.applyUpdates([
      .itemInsert(
        itemIndexPath: IndexPath(item: 3, section: 1),
        newItem: ItemModel(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .static(height: 10)),
          height: 10)),
      ],
      modelStateBeforeBatchUpdates: modelState.copyForBatchUpdates())

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1320.0, width: 130.0, height: 25.0),
      CGRect(x: 175.0, y: 1320.0, width: 130.0, height: 10.0),
      CGRect(x: 25.0, y: 1375.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1420.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1470.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1510.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1510.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1575.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1600.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.applyUpdates([
      .itemInsert(
        itemIndexPath: IndexPath(item: 4, section: 0),
        newItem: ItemModel(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .static(height: 100)),
          height: 100)),
      .itemInsert(
        itemIndexPath: IndexPath(item: 5, section: 0),
        newItem: ItemModel(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .static(height: 50)),
          height: 50)),
      .itemInsert(
        itemIndexPath: IndexPath(item: 6, section: 0),
        newItem: ItemModel(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .static(height: 20)),
          height: 20)),
      ],
      modelStateBeforeBatchUpdates: modelState.copyForBatchUpdates())

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 125.0, y: 380.0, width: 80.0, height: 50.0),
      CGRect(x: 25.0, y: 380.0, width: 80.0, height: 100.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 225.0, y: 380.0, width: 80.0, height: 20.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 175.0, y: 870.0, width: 55.0, height: 150.0),
      CGRect(x: 100.0, y: 870.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 870.0, width: 55.0, height: 15.0),
      CGRect(x: 125.0, y: 690.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 690.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 510.0, width: 130.0, height: 150.0),
      CGRect(x: 250.0, y: 870.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 1050.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1390.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1390.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1450.0, width: 130.0, height: 25.0),
      CGRect(x: 175.0, y: 1450.0, width: 130.0, height: 10.0),
      CGRect(x: 25.0, y: 1505.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1550.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1600.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1640.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1640.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1640.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1640.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1640.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1705.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1310.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames2: [CGRect] = [
    ]
    let expectedFooterFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1210.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1730.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1230.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1230.0),
      CGRect(x: 15.0, y: 1310.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedFooterFrames0: expectedFooterFrames2,
      expectedFooterFrames1: expectedFooterFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testLayoutAfterDeletingItems() {
    modelState.applyUpdates([
        .itemDelete(itemIndexPath: IndexPath(item: 5, section: 0)),
      ],
      modelStateBeforeBatchUpdates: modelState.copyForBatchUpdates())

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1320.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1375.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1420.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1470.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1510.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1510.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1575.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1600.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.applyUpdates([
        .itemDelete(itemIndexPath: IndexPath(item: 1, section: 0)),
        .itemDelete(itemIndexPath: IndexPath(item: 6, section: 1)),
        .itemDelete(itemIndexPath: IndexPath(item: 0, section: 1)),
        .itemDelete(itemIndexPath: IndexPath(item: 5, section: 0)),
      ],
      modelStateBeforeBatchUpdates: modelState.copyForBatchUpdates())

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 25.0, y: 200.0, width: 130.0, height: 150.0),
      CGRect(x: 175.0, y: 140.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 140.0, width: 130.0, height: 10.0),
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 380.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 380.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 380.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 380.0, width: 55.0, height: 150.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 25.0, y: 560.0, width: 40.0, height: 150.0),
      CGRect(x: 250.0, y: 380.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 380.0, width: 55.0, height: 150.0),
      CGRect(x: 100.0, y: 380.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 900.0, width: 130.0, height: 30.0),
      CGRect(x: 175.0, y: 900.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 960.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1005.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1055.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1095.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1095.0, width: 40.0, height: 25.0),
      CGRect(x: 145.0, y: 1095.0, width: 40.0, height: 35.0),
      CGRect(x: 205.0, y: 1095.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1160.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 820.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames2: [CGRect] = [
    ]
    let expectedFooterFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 720.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1185.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 740.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 740.0),
      CGRect(x: 15.0, y: 820.0, width: 300.0, height: 435.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedFooterFrames0: expectedFooterFrames2,
      expectedFooterFrames1: expectedFooterFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testLayoutAfterMovingItems() {
    modelState.applyUpdates([
        .itemMove(
          initialItemIndexPath: IndexPath(item: 0, section: 1),
          finalItemIndexPath: IndexPath(item: 5, section: 0)),
      ],
      modelStateBeforeBatchUpdates: modelState.copyForBatchUpdates())

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 175.0, y: 380.0, width: 130.0, height: 10.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1320.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1365.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1415.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1455.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1455.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1455.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1455.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1455.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1520.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1545.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 435.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.applyUpdates([
        .itemMove(
          initialItemIndexPath: IndexPath(item: 7, section: 1),
          finalItemIndexPath: IndexPath(item: 5, section: 1)),
        .itemMove(
          initialItemIndexPath: IndexPath(item: 0, section: 0),
          finalItemIndexPath: IndexPath(item: 1, section: 1)),
        .itemMove(
          initialItemIndexPath: IndexPath(item: 3, section: 0),
          finalItemIndexPath: IndexPath(item: 6, section: 0)),
        .itemMove(
          initialItemIndexPath: IndexPath(item: 2, section: 1),
          finalItemIndexPath: IndexPath(item: 0, section: 1)),
      ],
      modelStateBeforeBatchUpdates: modelState.copyForBatchUpdates())

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 25.0, y: 490.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 450.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 270.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 270.0, width: 130.0, height: 10.0),
      CGRect(x: 15.0, y: 90.0, width: 300.0, height: 150.0),
      CGRect(x: 125.0, y: 490.0, width: 80.0, height: 150.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 250.0, y: 730.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 730.0, width: 55.0, height: 150.0),
      CGRect(x: 100.0, y: 730.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 730.0, width: 55.0, height: 15.0),
      CGRect(x: 25.0, y: 670.0, width: 130.0, height: 30.0),
      CGRect(x: 125.0, y: 490.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 490.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 910.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1250.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1295.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1345.0, width: 130.0, height: 30.0),
      CGRect(x: 175.0, y: 1345.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1405.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1455.0, width: 40.0, height: 25.0),
      CGRect(x: 25.0, y: 1510.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1550.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1550.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1550.0, width: 40.0, height: 35.0),
      CGRect(x: 205.0, y: 1550.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1615.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1170.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames2: [CGRect] = [
    ]
    let expectedFooterFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1070.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1640.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1090.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1090.0),
      CGRect(x: 15.0, y: 1170.0, width: 300.0, height: 540.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedFooterFrames0: expectedFooterFrames2,
      expectedFooterFrames1: expectedFooterFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testReplacingHeader() {
    modelState.removeHeader(forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 40.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 90.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 270.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 270.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 330.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 510.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 510.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 690.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 690.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 690.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 690.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 870.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1210.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1210.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1270.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1325.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1370.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1420.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1460.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1460.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1460.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1460.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1460.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1525.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1130.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1030.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1550.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1050.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1050.0),
      CGRect(x: 15.0, y: 1130.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.setHeader(
      HeaderModel(heightMode: .static(height: 60), height: 60, pinToVisibleBounds: false),
      forSectionAtIndex: 0)
    modelState.setHeader(
      HeaderModel(heightMode: .dynamic, height: 100, pinToVisibleBounds: false),
      forSectionAtIndex: 1)

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 25.0, y: 100.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 150.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 330.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 330.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 390.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 25.0, y: 390.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 570.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 570.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 750.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 750.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 750.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 750.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 930.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1300.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1300.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1360.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1415.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1460.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1510.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1550.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1550.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1550.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1550.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1550.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1615.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 60.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1190.0, width: 300.0, height: 100.0),
    ]
    let expectedFooterFrames2: [CGRect] = [
    ]
    let expectedFooterFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1090.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1640.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1110.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1110.0),
      CGRect(x: 15.0, y: 1190.0, width: 300.0, height: 520.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedFooterFrames0: expectedFooterFrames2,
      expectedFooterFrames1: expectedFooterFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testReplacingFooter() {
    modelState.removeFooter(forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1210.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1210.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1270.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1325.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1370.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1420.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1460.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1460.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1460.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1460.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1460.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1525.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1130.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1550.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1050.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1050.0),
      CGRect(x: 15.0, y: 1130.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)


    modelState.setFooter(
      FooterModel(heightMode: .static(height: 40), height: 40, pinToVisibleBounds: false),
      forSectionAtIndex: 0)
    modelState.setFooter(
      FooterModel(heightMode: .dynamic, height: 120, pinToVisibleBounds: false),
      forSectionAtIndex: 1)

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1250.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1250.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1310.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1365.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1410.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1460.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1500.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1500.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1500.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1500.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1500.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1565.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1170.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames2: [CGRect] = [
    ]
    let expectedFooterFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 40.0),
      CGRect(x: 15.0, y: 1590.0, width: 300.0, height: 120.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1090.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1090.0),
      CGRect(x: 15.0, y: 1170.0, width: 300.0, height: 540.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedFooterFrames0: expectedFooterFrames2,
      expectedFooterFrames1: expectedFooterFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testReplacingBackground() {
    modelState.removeBackground(forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1320.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1375.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1420.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1470.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1510.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1510.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1575.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1600.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.setBackground(BackgroundModel(), forSectionAtIndex: 0)

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 25.0, y: 90.0, width: 280.0, height: 20.0),
      CGRect(x: 15.0, y: 140.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 320.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 320.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 25.0, y: 380.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 125.0, y: 560.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 740.0, width: 55.0, height: 15.0),
      CGRect(x: 100.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 250.0, y: 740.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 920.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1260.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1260.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1320.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1375.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1420.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1470.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1510.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1510.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1510.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1510.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1575.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 50.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 70.0),
    ]
    let expectedFooterFrames2: [CGRect] = [
    ]
    let expectedFooterFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 1080.0, width: 300.0, height: 50.0),
      CGRect(x: 15.0, y: 1600.0, width: 300.0, height: 70.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1100.0),
      CGRect(x: 15.0, y: 1180.0, width: 300.0, height: 490.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedFooterFrames0: expectedFooterFrames2,
      expectedFooterFrames1: expectedFooterFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testPinnedHeadersAndFooters() {
    modelState.setHeader(
      HeaderModel(
        heightMode: .dynamic,
        height: 50,
        pinToVisibleBounds: true),
      forSectionAtIndex: 0)
    modelState.setHeader(
      HeaderModel(
        heightMode: .static(height: 100),
        height: 100,
        pinToVisibleBounds: true),
      forSectionAtIndex: 1)
    modelState.setFooter(
      FooterModel(
        heightMode: .static(height: 150),
        height: 150,
        pinToVisibleBounds: true),
      forSectionAtIndex: 0)
    modelState.setFooter(
      FooterModel(
        heightMode: .dynamic,
        height: 25,
        pinToVisibleBounds: true),
      forSectionAtIndex: 1)

    modelState.updateHeaderHeight(toPreferredHeight: 75, forSectionAtIndex: 0)
    modelState.updateFooterHeight(toPreferredHeight: 50, forSectionAtIndex: 1)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 165.0, width: 300.0, height: 150.0),
      CGRect(x: 25.0, y: 115.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 345.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 345.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 405.0, width: 130.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 250.0, y: 765.0, width: 55.0, height: 150.0),
      CGRect(x: 175.0, y: 765.0, width: 55.0, height: 150.0),
      CGRect(x: 100.0, y: 765.0, width: 55.0, height: 150.0),
      CGRect(x: 25.0, y: 765.0, width: 55.0, height: 15.0),
      CGRect(x: 125.0, y: 585.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 585.0, width: 80.0, height: 150.0),
      CGRect(x: 25.0, y: 405.0, width: 130.0, height: 150.0),
      CGRect(x: 25.0, y: 945.0, width: 40.0, height: 150.0),
      CGRect(x: 25.0, y: 1415.0, width: 130.0, height: 10.0),
      CGRect(x: 175.0, y: 1415.0, width: 130.0, height: 30.0),
      CGRect(x: 25.0, y: 1475.0, width: 130.0, height: 25.0),
      CGRect(x: 25.0, y: 1530.0, width: 80.0, height: 15.0),
      CGRect(x: 25.0, y: 1575.0, width: 280.0, height: 20.0),
      CGRect(x: 25.0, y: 1625.0, width: 80.0, height: 10.0),
      CGRect(x: 25.0, y: 1665.0, width: 40.0, height: 15.0),
      CGRect(x: 85.0, y: 1665.0, width: 40.0, height: 15.0),
      CGRect(x: 145.0, y: 1665.0, width: 40.0, height: 25.0),
      CGRect(x: 205.0, y: 1665.0, width: 40.0, height: 35.0),
      CGRect(x: 265.0, y: 1665.0, width: 40.0, height: 30.0),
      CGRect(x: 15.0, y: 1730.0, width: 300.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 100.0, width: 300.0, height: 75.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 1305.0, width: 300.0, height: 100.0),
    ]
    let expectedFooterFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 430.0, width: 300.0, height: 150.0),
    ]
    let expectedFooterFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 430.0, width: 300.0, height: 150.0),
      CGRect(x: 15.0, y: 1405.0, width: 300.0, height: 50.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1225.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 15.0, y: 30.0, width: 300.0, height: 1225.0),
      CGRect(x: 15.0, y: 1305.0, width: 300.0, height: 500.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedFooterFrames0: expectedFooterFrames0,
      expectedFooterFrames1: expectedFooterFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  // MARK: Private

  private var modelState: ModelState!

  private let visibleRect0 = CGRect(x: 0, y: 0, width: 320, height: 500)
  private let visibleRect1 = CGRect(x: 0, y: 500, width: 320, height: 2000)

  private lazy var headerModel0 = HeaderModel(
    heightMode: .static(height: 50),
    height: 50,
    pinToVisibleBounds: false)
  private lazy var sizeModesAndHeights0: [(sizeMode: MagazineLayoutItemSizeMode, height: CGFloat)] = [
    (MagazineLayoutItemSizeMode(
      widthMode: .fullWidth(respectsHorizontalInsets: true),
      heightMode: .static(height: 20)),
     20),

    (MagazineLayoutItemSizeMode(
      widthMode: .fullWidth(respectsHorizontalInsets: false),
      heightMode: .dynamic),
     15),

    (MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: 10)), 10),
    (MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: 30)), 30),
    (MagazineLayoutItemSizeMode(
      widthMode: .halfWidth,
      heightMode: .dynamicAndStretchToTallestItemInRow),
     25),

    (MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .dynamic), 15),
    (MagazineLayoutItemSizeMode(
      widthMode: .thirdWidth,
      heightMode: .dynamicAndStretchToTallestItemInRow),
     10),

    (MagazineLayoutItemSizeMode(widthMode: .fourthWidth, heightMode: .static(height: 35)), 15),
    (MagazineLayoutItemSizeMode(widthMode: .fourthWidth, heightMode: .dynamic), 15),
    (MagazineLayoutItemSizeMode(widthMode: .fourthWidth, heightMode: .dynamic), 25),
    (MagazineLayoutItemSizeMode(widthMode: .fourthWidth, heightMode: .dynamic), 35),

    (MagazineLayoutItemSizeMode(widthMode: .fifthWidth, heightMode: .dynamic), 30),
  ]
  private lazy var footerModel0 = FooterModel(
    heightMode: .static(height: 50),
    height: 50,
    pinToVisibleBounds: false)

  private lazy var headerModel1 = HeaderModel(
    heightMode: .dynamic,
    height: 70,
    pinToVisibleBounds: false)
  private lazy var sizeModesAndHeights1: [(sizeMode: MagazineLayoutItemSizeMode, height: CGFloat)] = [
    (MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: 10)), 10),
    (MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: 30)), 30),
    (MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: 25)), 25),

    (MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .static(height: 15)), 15),

    (MagazineLayoutItemSizeMode(
      widthMode: .fullWidth(respectsHorizontalInsets: true),
      heightMode: .static(height: 20)),
     20),

    (MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .static(height: 10)), 10),

    (MagazineLayoutItemSizeMode(widthMode: .fifthWidth, heightMode: .static(height: 35)), 15),
    (MagazineLayoutItemSizeMode(widthMode: .fifthWidth, heightMode: .static(height: 15)), 15),
    (MagazineLayoutItemSizeMode(widthMode: .fifthWidth, heightMode: .static(height: 25)), 25),
    (MagazineLayoutItemSizeMode(widthMode: .fifthWidth, heightMode: .static(height: 35)), 35),
    (MagazineLayoutItemSizeMode(widthMode: .fifthWidth, heightMode: .static(height: 30)), 30),

    (MagazineLayoutItemSizeMode(
      widthMode: .fullWidth(respectsHorizontalInsets: false),
      heightMode: .static(height: 15)),
     15),
  ]
  private lazy var footerModel1 = FooterModel(
    heightMode: .dynamic,
    height: 70,
    pinToVisibleBounds: false)

  private func checkExpectedFrames(
    expectedItemFrames0: [CGRect],
    expectedItemFrames1: [CGRect],
    expectedHeaderFrames0: [CGRect],
    expectedHeaderFrames1: [CGRect],
    expectedFooterFrames0: [CGRect],
    expectedFooterFrames1: [CGRect],
    expectedBackgroundFrames0: [CGRect],
    expectedBackgroundFrames1: [CGRect])
  {
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedItemFrames0,
        match: modelState.itemLocationFramePairs(forItemsIn: visibleRect0)),
      "Item frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedItemFrames1,
        match: modelState.itemLocationFramePairs(forItemsIn: visibleRect1)),
      "Item frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedItemFrames0 + expectedItemFrames1).removingDuplicates(),
        matchItemFramesInSectionIndexRange: 0..<modelState.numberOfSections,
        modelState: modelState),
      "Item frames are incorrect")

    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedHeaderFrames0,
        match: modelState.headerLocationFramePairs(forHeadersIn: visibleRect0)),
      "Header frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedHeaderFrames1,
        match: modelState.headerLocationFramePairs(forHeadersIn: visibleRect1)),
      "Header frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedHeaderFrames0 + expectedHeaderFrames1).removingDuplicates(),
        matchHeaderFramesInSectionIndexRange: 0..<modelState.numberOfSections,
        modelState: modelState),
      "Header frames are incorrect")

    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedFooterFrames0,
        match: modelState.footerLocationFramePairs(forFootersIn: visibleRect0)),
      "Footer frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedFooterFrames1,
        match: modelState.footerLocationFramePairs(forFootersIn: visibleRect1)),
      "Footer frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedFooterFrames0 + expectedFooterFrames1).removingDuplicates(),
        matchFooterFramesInSectionIndexRange: 0..<modelState.numberOfSections,
        modelState: modelState),
      "Footer frames are incorrect")

    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedBackgroundFrames0,
        match: modelState.backgroundLocationFramePairs(forBackgroundsIn: visibleRect0)),
      "Background frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedBackgroundFrames1,
        match: modelState.backgroundLocationFramePairs(forBackgroundsIn: visibleRect1)),
      "Background frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedBackgroundFrames0 + expectedBackgroundFrames1).removingDuplicates(),
        matchBackgroundFramesInSectionIndexRange: 0..<modelState.numberOfSections,
        modelState: modelState),
      "Background frames are incorrect")
  }

}
