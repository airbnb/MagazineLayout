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

final class ModelStateLayoutTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    var metrics = MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 320)
    metrics.itemInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    metrics.horizontalSpacing = 20
    metrics.verticalSpacing = 30

    let sections = zip(
        [headerModel0, headerModel1],
        [sizeModesAndHeights0, sizeModesAndHeights1]
      ).map { headerModel, sizeModesAndHeights in
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
          backgroundModel: BackgroundModel(),
          metrics: metrics)
      }

    modelState = ModelState()
    modelState.setSections(sections)
  }

  override func tearDown() {
    modelState = nil
  }

  func testInitialLayout() {
    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 10.0, y: 60.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 110.0, width: 320.0, height: 150.0),
      CGRect(x: 10.0, y: 290.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 290.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 350.0, width: 140.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 10.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 117.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 10.0, y: 710.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 170.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 250.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 10.0, y: 890.0, width: 44.0, height: 150.0),
      CGRect(x: 10.0, y: 1130.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1130.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1190.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1245.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1290.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1340.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1380.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 1380.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1380.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1445.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1050.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1050.0),
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 420.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
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

        let preferredHeight = modelState.itemModelPreferredHeightDuringPreferredAttributesCheck(
          at: indexPath)
        XCTAssert(preferredHeight == sizeModeAndHeight.height, "Item preferred height is incorrect")
      case .static:
        continue
      }
    }

    let expectedItemFrames0 = [
      CGRect(x: 10.0, y: 60.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 110.0, width: 320.0, height: 15.0),
      CGRect(x: 10.0, y: 155.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 155.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 215.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 270.0, width: 87.0, height: 15.0),
      CGRect(x: 117.0, y: 270.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 315.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 315.0, width: 60.0, height: 15.0),
      CGRect(x: 170.0, y: 315.0, width: 60.0, height: 25.0),
      CGRect(x: 250.0, y: 315.0, width: 60.0, height: 35.0),
      CGRect(x: 10.0, y: 380.0, width: 44.0, height: 30.0),
      CGRect(x: 10.0, y: 480.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 480.0, width: 140.0, height: 30.0),
    ]
    let expectedItemFrames1 = [
      CGRect(x: 170.0, y: 480.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 540.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 595.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 640.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 690.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 730.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 730.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 730.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 730.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 730.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 795.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames0 = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 50.0),
      CGRect(x: 0.0, y: 420.0, width: 320.0, height: 50.0),
    ]
    let expectedHeaderFrames1 = [CGRect]()
    let expectedBackgroundFrames0 = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 420.0),
      CGRect(x: 0.0, y: 420.0, width: 320.0, height: 400.0),
    ]
    let expectedBackgroundFrames1 = [
      CGRect(x: 0.0, y: 420.0, width: 320.0, height: 400.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  func testUpdatingSectionMetrics() {
    var metrics = MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 100)
    metrics.itemInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    metrics.horizontalSpacing = 5
    metrics.verticalSpacing = 100
    modelState.updateMetrics(to: metrics, forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 2.0, y: 52.0, width: 96.0, height: 20.0),
      CGRect(x: 0.0, y: 172.0, width: 100.0, height: 150.0),
      CGRect(x: 2.0, y: 422.0, width: 46.0, height: 10.0),
      CGRect(x: 53.0, y: 422.0, width: 46.0, height: 30.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 2.0, y: 552.0, width: 46.0, height: 150.0),
      CGRect(x: 2.0, y: 802.0, width: 29.0, height: 150.0),
      CGRect(x: 36.0, y: 802.0, width: 29.0, height: 150.0),
      CGRect(x: 2.0, y: 1052.0, width: 20.0, height: 15.0),
      CGRect(x: 27.0, y: 1052.0, width: 20.0, height: 150.0),
      CGRect(x: 52.0, y: 1052.0, width: 20.0, height: 150.0),
      CGRect(x: 77.0, y: 1052.0, width: 20.0, height: 150.0),
      CGRect(x: 2.0, y: 1302.0, width: 15.0, height: 150.0),
      CGRect(x: 10.0, y: 1534.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1534.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1594.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1649.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1694.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1744.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1784.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1784.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1784.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 1784.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1784.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1849.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 100.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 1454.0, width: 320.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 100.0, height: 1454.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 100.0, height: 1454.0),
      CGRect(x: 0.0, y: 1454.0, width: 320.0, height: 420.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
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
      CGRect(x: 10.0, y: 60.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 110.0, width: 320.0, height: 150.0),
      CGRect(x: 10.0, y: 290.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 290.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 350.0, width: 140.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 10.0, y: 530.0, width: 87.0, height: 50.0),
      CGRect(x: 117.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 10.0, y: 710.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 170.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 250.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 10.0, y: 890.0, width: 44.0, height: 150.0),
      CGRect(x: 10.0, y: 1130.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1130.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1190.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1245.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1290.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1340.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1380.0, width: 44.0, height: 35.0),
      CGRect(x: 202.0, y: 1380.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1380.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1445.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1050.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1050.0),
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 420.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)
  }

  func testReplacingHeader() {
    modelState.removeHeader(forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 10.0, y: 10.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 60.0, width: 320.0, height: 150.0),
      CGRect(x: 10.0, y: 240.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 240.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 300.0, width: 140.0, height: 150.0),
      CGRect(x: 10.0, y: 480.0, width: 87.0, height: 150.0),
      CGRect(x: 117.0, y: 480.0, width: 87.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 10.0, y: 480.0, width: 87.0, height: 150.0),
      CGRect(x: 117.0, y: 480.0, width: 87.0, height: 150.0),
      CGRect(x: 10.0, y: 660.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 660.0, width: 60.0, height: 150.0),
      CGRect(x: 170.0, y: 660.0, width: 60.0, height: 150.0),
      CGRect(x: 250.0, y: 660.0, width: 60.0, height: 150.0),
      CGRect(x: 10.0, y: 840.0, width: 44.0, height: 150.0),
      CGRect(x: 10.0, y: 1080.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1080.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1140.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1195.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1240.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1290.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1330.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1330.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1330.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 1330.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1330.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1395.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = []
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 1000.0, width: 320.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1000.0),
    ]
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1000.0),
      CGRect(x: 0.0, y: 1000.0, width: 320.0, height: 420.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.setHeader(
      HeaderModel(heightMode: .static(height: 60), height: 60),
      forSectionAtIndex: 0)
    modelState.setHeader(
      HeaderModel(heightMode: .dynamic, height: 100),
      forSectionAtIndex: 1)

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 10.0, y: 70.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 120.0, width: 320.0, height: 150.0),
      CGRect(x: 10.0, y: 300.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 300.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 360.0, width: 140.0, height: 150.0),
      ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 10.0, y: 360.0, width: 140.0, height: 150.0),
      CGRect(x: 10.0, y: 540.0, width: 87.0, height: 150.0),
      CGRect(x: 117.0, y: 540.0, width: 87.0, height: 150.0),
      CGRect(x: 10.0, y: 720.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 720.0, width: 60.0, height: 150.0),
      CGRect(x: 170.0, y: 720.0, width: 60.0, height: 150.0),
      CGRect(x: 250.0, y: 720.0, width: 60.0, height: 150.0),
      CGRect(x: 10.0, y: 900.0, width: 44.0, height: 150.0),
      CGRect(x: 10.0, y: 1170.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1170.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1230.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1285.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1330.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1380.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1420.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1420.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1420.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 1420.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1420.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1485.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 60.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 0.0, y: 1060.0, width: 320.0, height: 100.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1060.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1060.0),
      CGRect(x: 0.0, y: 1060.0, width: 320.0, height: 450.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  func testReplacingBackground() {
    modelState.removeBackground(forSectionAtIndex: 0)

    let expectedItemFrames0: [CGRect] = [
      CGRect(x: 10.0, y: 60.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 110.0, width: 320.0, height: 150.0),
      CGRect(x: 10.0, y: 290.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 290.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 350.0, width: 140.0, height: 150.0),
    ]
    let expectedItemFrames1: [CGRect] = [
      CGRect(x: 10.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 117.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 10.0, y: 710.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 170.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 250.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 10.0, y: 890.0, width: 44.0, height: 150.0),
      CGRect(x: 10.0, y: 1130.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1130.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1190.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1245.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1290.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1340.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1380.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 1380.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1380.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1445.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames0: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 50.0),
    ]
    let expectedHeaderFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 70.0),
    ]
    let expectedBackgroundFrames0: [CGRect] = []
    let expectedBackgroundFrames1: [CGRect] = [
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 420.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames0,
      expectedItemFrames1: expectedItemFrames1,
      expectedHeaderFrames0: expectedHeaderFrames0,
      expectedHeaderFrames1: expectedHeaderFrames1,
      expectedBackgroundFrames0: expectedBackgroundFrames0,
      expectedBackgroundFrames1: expectedBackgroundFrames1)

    modelState.setBackground(BackgroundModel(), forSectionAtIndex: 0)

    let expectedItemFrames2: [CGRect] = [
      CGRect(x: 10.0, y: 60.0, width: 300.0, height: 20.0),
      CGRect(x: 0.0, y: 110.0, width: 320.0, height: 150.0),
      CGRect(x: 10.0, y: 290.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 290.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 350.0, width: 140.0, height: 150.0),
    ]
    let expectedItemFrames3: [CGRect] = [
      CGRect(x: 10.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 117.0, y: 530.0, width: 87.0, height: 150.0),
      CGRect(x: 10.0, y: 710.0, width: 60.0, height: 15.0),
      CGRect(x: 90.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 170.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 250.0, y: 710.0, width: 60.0, height: 150.0),
      CGRect(x: 10.0, y: 890.0, width: 44.0, height: 150.0),
      CGRect(x: 10.0, y: 1130.0, width: 140.0, height: 10.0),
      CGRect(x: 170.0, y: 1130.0, width: 140.0, height: 30.0),
      CGRect(x: 10.0, y: 1190.0, width: 140.0, height: 25.0),
      CGRect(x: 10.0, y: 1245.0, width: 87.0, height: 15.0),
      CGRect(x: 10.0, y: 1290.0, width: 300.0, height: 20.0),
      CGRect(x: 10.0, y: 1340.0, width: 87.0, height: 10.0),
      CGRect(x: 10.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 74.0, y: 1380.0, width: 44.0, height: 15.0),
      CGRect(x: 138.0, y: 1380.0, width: 44.0, height: 25.0),
      CGRect(x: 202.0, y: 1380.0, width: 44.0, height: 35.0),
      CGRect(x: 266.0, y: 1380.0, width: 44.0, height: 30.0),
      CGRect(x: 0.0, y: 1445.0, width: 320.0, height: 15.0),
    ]
    let expectedHeaderFrames2: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 50.0),
    ]
    let expectedHeaderFrames3: [CGRect] = [
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 70.0),
    ]
    let expectedBackgroundFrames2: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1050.0),
    ]
    let expectedBackgroundFrames3: [CGRect] = [
      CGRect(x: 0.0, y: 0.0, width: 320.0, height: 1050.0),
      CGRect(x: 0.0, y: 1050.0, width: 320.0, height: 420.0),
    ]

    checkExpectedFrames(
      expectedItemFrames0: expectedItemFrames2,
      expectedItemFrames1: expectedItemFrames3,
      expectedHeaderFrames0: expectedHeaderFrames2,
      expectedHeaderFrames1: expectedHeaderFrames3,
      expectedBackgroundFrames0: expectedBackgroundFrames2,
      expectedBackgroundFrames1: expectedBackgroundFrames3)
  }

  // MARK: Private

  private var modelState: ModelState!

  private let visibleRect0 = CGRect(x: 0, y: 0, width: 320, height: 500)
  private let visibleRect1 = CGRect(x: 0, y: 500, width: 320, height: 2000)

  private lazy var headerModel0 = HeaderModel(
    heightMode: .static(height: 50),
    height: 50)
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

  private lazy var headerModel1 = HeaderModel(heightMode: .dynamic, height: 70)
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

  private func checkExpectedFrames(
    expectedItemFrames0: [CGRect],
    expectedItemFrames1: [CGRect],
    expectedHeaderFrames0: [CGRect],
    expectedHeaderFrames1: [CGRect],
    expectedBackgroundFrames0: [CGRect],
    expectedBackgroundFrames1: [CGRect])
  {
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedItemFrames0,
        match: modelState.itemFrameInfo(forItemsIn: visibleRect0)),
      "Item frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedItemFrames1,
        match: modelState.itemFrameInfo(forItemsIn: visibleRect1)),
      "Item frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedItemFrames0 + expectedItemFrames1).removingDuplicates(),
        matchItemFramesInSectionIndexRange: 0..<modelState.numberOfSections(.afterUpdates),
        modelState: modelState),
      "Item frames are incorrect")

    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedHeaderFrames0,
        match: modelState.headerFrameInfo(forHeadersIn: visibleRect0)),
      "Header frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedHeaderFrames1,
        match: modelState.headerFrameInfo(forHeadersIn: visibleRect1)),
      "Header frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedHeaderFrames0 + expectedHeaderFrames1).removingDuplicates(),
        matchHeaderFramesInSectionIndexRange: 0..<modelState.numberOfSections(.afterUpdates),
        modelState: modelState),
      "Header frames are incorrect")

    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedBackgroundFrames0,
        match: modelState.backgroundFrameInfo(forBackgroundsIn: visibleRect0)),
      "Background frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedBackgroundFrames1,
        match: modelState.backgroundFrameInfo(forBackgroundsIn: visibleRect1)),
      "Background frames are incorrect")
    XCTAssert(
      FrameHelpers.expectedFrames(
        (expectedBackgroundFrames0 + expectedBackgroundFrames1).removingDuplicates(),
        matchBackgroundFramesInSectionIndexRange: 0..<modelState.numberOfSections(.afterUpdates),
        modelState: modelState),
      "Background frames are incorrect")
  }

}
