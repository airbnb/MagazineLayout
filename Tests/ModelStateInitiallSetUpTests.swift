// Created by bryankeller on 11/12/18.
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

final class ModelStateInitialSetUpTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    modelState = ModelState(currentVisibleBoundsProvider: { return .zero })
  }

  override func tearDown() {
    modelState = nil
  }

  func testInitialEmptyModelState() {
    XCTAssert(
      modelState.numberOfSections == 0,
      "The model state should contain 0 sections")
    XCTAssert(
      modelState.sectionIndicesToInsert.count == 0,
      "`sectionIndicesToInsert` should be empty")
    XCTAssert(
      modelState.sectionIndicesToDelete.count == 0,
      "`sectionIndicesToDelete` should be empty")
    XCTAssert(
      modelState.itemIndexPathsToInsert.count == 0,
      "`itemIndexPathsToInsert` should be empty")
    XCTAssert(
      modelState.itemIndexPathsToDelete.count == 0,
      "`itemIndexPathsToDelete` should be empty")
  }

  func testSetSections() {
    let sectionModels = ModelHelpers.basicSectionModels(
      numberOfSections: 2,
      numberOfItemsPerSection: 3)
    modelState.setSections(sectionModels)

    XCTAssert(
      modelState.numberOfSections == 2,
      "The model state should contain 2 sections")
    XCTAssert(
      (modelState.numberOfItems(inSectionAtIndex: 0) == 3 &&
        modelState.numberOfItems(inSectionAtIndex: 1) == 3),
      "The model state should contain 3 items for each section")

    modelState.setSections([])
    XCTAssert(
      modelState.numberOfSections == 0,
      "The model state should contain 0 sections")
  }

  // MARK: Private

  private var modelState: ModelState!

}
