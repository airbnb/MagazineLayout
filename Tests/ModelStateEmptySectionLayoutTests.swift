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

@available(iOS 18.0, *)
final class ModelStateEmptySectionLayoutTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    modelState = ModelState(currentVisibleBoundsProvider: { return .zero })
  }

  override func tearDown() {
    modelState = nil
  }

  func testEmptySectionsLayout() {
    let metrics0 = MagazineLayoutSectionMetrics.defaultSectionMetrics(
      forCollectionViewWidth: 320,
      sectionInsets: .zero,
      itemInsets: UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0),
      scale: 1)

    let metrics1 = MagazineLayoutSectionMetrics.defaultSectionMetrics(
      forCollectionViewWidth: 320,
      sectionInsets: UIEdgeInsets(top: -25, left: 0, bottom: 20, right: 10),
      itemInsets: UIEdgeInsets(top: 50, left: 0, bottom: 100, right: 0),
      scale: 1)

    let initialSections = [
      SectionModel(
        itemModels: [],
        headerModel: nil,
        footerModel: nil,
        backgroundModel: nil,
        metrics: metrics0),
      SectionModel(
        itemModels: [],
        headerModel: nil,
        footerModel: nil,
        backgroundModel: nil,
        metrics: metrics1),
      ]
    modelState.setSections(initialSections)

    let expectedHeightOfSection0 = metrics0.sectionInsets.top + metrics0.sectionInsets.bottom
    let expectedHeightOfSection1 = metrics1.sectionInsets.top + metrics1.sectionInsets.bottom
    XCTAssert(
      (modelState.sectionMaxY(forSectionAtIndex: 0) == expectedHeightOfSection0 &&
       modelState.sectionMaxY(forSectionAtIndex: 1) == expectedHeightOfSection1),
      "The layout has incorrect heights for its sections")
  }

  func testEmptySectionsWithHeadersFootersAndBackgroundsLayout() {
    let metrics0 = MagazineLayoutSectionMetrics.defaultSectionMetrics(
      forCollectionViewWidth: 320,
      sectionInsets: UIEdgeInsets(top: 10, left: 5, bottom: 20, right: 5),
      itemInsets: UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10),
      scale: 1)

    let metrics1 = MagazineLayoutSectionMetrics.defaultSectionMetrics(
      forCollectionViewWidth: 320,
      sectionInsets: .zero,
      itemInsets: UIEdgeInsets(top: 50, left: 10, bottom: 100, right: 10),
      scale: 1)

    let initialSections = [
      SectionModel(
        itemModels: [],
        headerModel: HeaderModel(
          heightMode: .static(height: 45),
          height: 45,
          pinToVisibleBounds: false),
        footerModel: FooterModel(
          heightMode: .static(height: 45),
          height: 45,
          pinToVisibleBounds: false),
        backgroundModel: BackgroundModel(),
        metrics: metrics0),
      SectionModel(
        itemModels: [],
        headerModel: HeaderModel(
          heightMode: .static(height: 65),
          height: 65,
          pinToVisibleBounds: false),
        footerModel: FooterModel(
          heightMode: .static(height: 65),
          height: 65,
          pinToVisibleBounds: false),
        backgroundModel: BackgroundModel(),
        metrics: metrics1),
      ]
    modelState.setSections(initialSections)

    let expectedHeaderFrames = [
      CGRect(x: 5, y: 10, width: 310, height: 45),
      CGRect(x: 0, y: 120, width: 320, height: 65),
    ]
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedHeaderFrames,
        matchHeaderFramesInSectionIndexRange: 0..<modelState.numberOfSections,
        modelState: modelState),
      "Header frames are incorrect")

    let expectedFooterFrames = [
      CGRect(x: 5, y: 55, width: 310, height: 45),
      CGRect(x: 0, y: 185, width: 320, height: 65)
    ]
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedFooterFrames,
        matchFooterFramesInSectionIndexRange:
        0..<modelState.numberOfSections,
        modelState: modelState),
      "Footer frames are incorrect")

    let expectedBackgroundFrames = [
      CGRect(x: 5, y: 10, width: 310, height: 90),
      CGRect(x: 0, y: 120, width: 320, height: 130),
    ]
    XCTAssert(
      FrameHelpers.expectedFrames(
        expectedBackgroundFrames,
        matchBackgroundFramesInSectionIndexRange: 0..<modelState.numberOfSections,
        modelState: modelState),
      "Background frames are incorrect")
  }

  // MARK: Private

  private var modelState: ModelState!

}
