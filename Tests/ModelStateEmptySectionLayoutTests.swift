// Created by bryankeller on 11/13/18.
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

final class ModelStateEmptySectionLayoutTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    modelState = ModelState()
  }

  override func tearDown() {
    modelState = nil
  }

  func testEmptySectionsLayout() {
    var metrics0 = MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 320)
    metrics0.itemInsets = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)

    var metrics1 = MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 320)
    metrics1.itemInsets = UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0)

    let initialSections = [
      SectionModel(
        itemModels: [],
        headerModel: nil,
        backgroundModel: nil,
        metrics: metrics0),
      SectionModel(
        itemModels: [],
        headerModel: nil,
        backgroundModel: nil,
        metrics: metrics1),
      ]
    modelState.setSections(initialSections)

    XCTAssert(
      (modelState.sectionMaxY(forSectionAtIndex: 0, .afterUpdates) == 30 &&
        modelState.sectionMaxY(forSectionAtIndex: 1, .afterUpdates) == 150 + 30),
      "The layout has incorrect heights for its sections")
  }

  func testEmptySectionsWithHeadersAndBackgroundsLayout() {
    var metrics0 = MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 320)
    metrics0.itemInsets = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)

    var metrics1 = MagazineLayoutSectionMetrics.defaultSectionMetrics(forCollectionViewWidth: 320)
    metrics1.itemInsets = UIEdgeInsets(top: 50, left: 10, bottom: 100, right: 10)

    let initialSections = [
      SectionModel(
        itemModels: [],
        headerModel: HeaderModel(heightMode: .static(height: 45), height: 45),
        backgroundModel: BackgroundModel(),
        metrics: metrics0),
      SectionModel(
        itemModels: [],
        headerModel: HeaderModel(heightMode: .static(height: 65), height: 65),
        backgroundModel: BackgroundModel(),
        metrics: metrics1),
      ]
    modelState.setSections(initialSections)

    let expectedHeaderFrames = [
      CGRect(x: 0, y: 0, width: 320, height: 45),
      CGRect(x: 0, y: 75, width: 320, height: 65),
    ]
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedHeaderFrames,
        matchHeaderFramesInSectionIndexRange: 0..<modelState.numberOfSections(.afterUpdates),
        modelState: modelState),
      "Header frames are incorrect")

    let expectedBackgroundFrames = [
      CGRect(x: 0, y: 0, width: 320, height: 75),
      CGRect(x: 0, y: 75, width: 320, height: 215),
    ]
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedBackgroundFrames,
        matchBackgroundFramesInSectionIndexRange: 0..<modelState.numberOfSections(.afterUpdates),
        modelState: modelState),
      "Header frames are incorrect")
  }

  // MARK: Private

  private var modelState: ModelState!

}
