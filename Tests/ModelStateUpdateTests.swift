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

final class ModelStateUpdateTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    modelState = ModelState(currentVisibleBoundsProvider: { return .zero })
  }

  override func tearDown() {
    modelState = nil

  }

  func testIsPerformingBatchUpdates() {
    let sectionToInsert = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 0).first!
    modelState.applyUpdates([
        .sectionInsert(sectionIndex: 0, newSection: sectionToInsert)
      ],
      modelStateBeforeBatchUpdates: modelState.copy())

    XCTAssert(
      !modelState.sectionIndicesToInsert.isEmpty,
      "`sectionIndicesToInsert` should not be empty")

    modelState.clearInProgressBatchUpdateState()

    XCTAssert(
      modelState.sectionIndicesToInsert.isEmpty,
      "`sectionIndicesToInsert` should be empty")
  }

  func testSectionReload() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 3)
    modelState.setSections(initialSections)
    let replacementSection = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 1).first!

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .sectionReload(sectionIndex: 0, newSection: replacementSection)
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0) == 1,
      "The model state should contain 1 item in section 0")
    XCTAssert(
      modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 0) == 3,
      "The model state's section models before updates should contain 3 items in section 0")
  }

  func testItemReload() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 3)
    modelState.setSections(initialSections)

    let replacementItem = ModelHelpers.basicItemModel()
    let indexPath = IndexPath(item: 0, section: 0)

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .itemReload(itemIndexPath: indexPath, newItem: replacementItem)
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      modelState.idForItemModel(at: indexPath) == replacementItem.id,
      "The model state should contain 1 item in section 0")
    XCTAssert(
      modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 0) == 3,
      "The model state's section models before updates should contain 3 items in section 0")
  }

  func testSectionInserts() {
    let sectionsToInsert = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 0)

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .sectionInsert(sectionIndex: 2, newSection: sectionsToInsert[2]),
        .sectionInsert(sectionIndex: 1, newSection: sectionsToInsert[1]),
        .sectionInsert(sectionIndex: 0, newSection: sectionsToInsert[0]),
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      modelState.numberOfSections == 3,
      "The model state should contain 3 sections")
    XCTAssert(
      modelStateBeforeBatchUpdates.numberOfSections == 0,
      "The model state's section models before updates should contain 0 sections")
    XCTAssert(
      modelState.sectionIndicesToInsert == [0, 1, 2],
      "`sectionIndicesToInsert` should contain 0, 1, and 2")
  }

  func testItemInserts() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 0)
    modelState.setSections(initialSections)

    let itemsToInsert = [
      ModelHelpers.basicItemModel(),
      ModelHelpers.basicItemModel(),
      ModelHelpers.basicItemModel(),
    ]

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .itemInsert(itemIndexPath: IndexPath(item: 2, section: 0), newItem: itemsToInsert[2]),
        .itemInsert(itemIndexPath: IndexPath(item: 0, section: 0), newItem: itemsToInsert[0]),
        .itemInsert(itemIndexPath: IndexPath(item: 1, section: 0), newItem: itemsToInsert[1]),
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0) == 3,
      "The model state should contain 3 items in section 0")
    XCTAssert(
      modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 0) == 0,
      "The model state's section models before updates should contain 0 items in section 0")
    XCTAssert(
      modelState.itemIndexPathsToInsert == Set([0, 1, 2].map { IndexPath(item: $0, section: 0) }),
      "`itemIndexPathsToInsert` should contain {0, 0}, {0, 1}, and {0, 2}")
  }

  func testSectionDeletes() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 0)
    modelState.setSections(initialSections)

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .sectionDelete(sectionIndex: 2),
        .sectionDelete(sectionIndex: 0),
        .sectionDelete(sectionIndex: 1),
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      modelState.numberOfSections == 0,
      "The model state should contain 0 sections")
    XCTAssert(
      modelStateBeforeBatchUpdates.numberOfSections == 3,
      "The model state's section models before updates should contain 3 sections")
    XCTAssert(
      modelState.sectionIndicesToDelete == [0, 1, 2],
      "`sectionIndicesToDelete` should contain 0, 1, and 2")
  }

  func testItemDeletes() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 3)
    modelState.setSections(initialSections)

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .itemDelete(itemIndexPath: IndexPath(item: 2, section: 0)),
        .itemDelete(itemIndexPath: IndexPath(item: 0, section: 0)),
        .itemDelete(itemIndexPath: IndexPath(item: 1, section: 0)),
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0) == 0,
      "The model state should contain 0 items in section 0")
    XCTAssert(
      modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 0) == 3,
      "The model state's section models before updates should contain 3 items in section 0")
    XCTAssert(
      modelState.itemIndexPathsToDelete == Set([0, 1, 2].map { IndexPath(item: $0, section: 0) }),
      "`itemIndexPathsToDelete` should contain {0, 0}, {0, 1}, and {0, 2}")
  }

  func testSectionMoves() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 2)
    modelState.setSections(initialSections)

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .sectionMove(initialSectionIndex: 0, finalSectionIndex: 1),
        .itemMove(initialItemIndexPath: .init(item: 0, section: 0), finalItemIndexPath: .init(item: 0, section: 1)),
        .itemMove(initialItemIndexPath: .init(item: 1, section: 0), finalItemIndexPath: .init(item: 1, section: 1)),

        .sectionMove(initialSectionIndex: 2, finalSectionIndex: 0),
        .itemMove(initialItemIndexPath: .init(item: 0, section: 2), finalItemIndexPath: .init(item: 0, section: 0)),
        .itemMove(initialItemIndexPath: .init(item: 1, section: 2), finalItemIndexPath: .init(item: 1, section: 0)),
    ],
    modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      (
        modelStateBeforeBatchUpdates.idForSectionModel(atIndex: 0) ==
          modelState.idForSectionModel(atIndex: 1) &&
        modelStateBeforeBatchUpdates.idForSectionModel(atIndex: 1) ==
          modelState.idForSectionModel(atIndex: 2) &&
        modelStateBeforeBatchUpdates.idForSectionModel(atIndex: 2) ==
          modelState.idForSectionModel(atIndex: 0)
      ),
      "The model state's section models before / after updates are in an incorrect state")

    XCTAssert(
      (
        modelStateBeforeBatchUpdates.indexForSectionModel(withID: initialSections[0].id) == 0 &&
        modelStateBeforeBatchUpdates.indexForSectionModel(withID: initialSections[1].id) == 1 &&
        modelStateBeforeBatchUpdates.indexForSectionModel(withID: initialSections[2].id) == 2 &&
        modelState.indexForSectionModel(withID: initialSections[0].id) == 1 &&
        modelState.indexForSectionModel(withID: initialSections[1].id) == 2 &&
        modelState.indexForSectionModel(withID: initialSections[2].id) == 0
      ),
      "The model state's section models before / after updates are in an incorrect state")

    XCTAssert(
      (
        modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 0) ==
          modelState.numberOfItems(inSectionAtIndex: 1) &&
        modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 1) ==
          modelState.numberOfItems(inSectionAtIndex: 2) &&
        modelStateBeforeBatchUpdates.numberOfItems(inSectionAtIndex: 2) ==
          modelState.numberOfItems(inSectionAtIndex: 0)
      ),
      "The model state's section models before / after updates are in an incorrect state")
  }

  func testItemMoves() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 2)
    modelState.setSections(initialSections)

    let modelStateBeforeBatchUpdates = modelState.copy()
    modelState.applyUpdates([
        .itemMove(
          initialItemIndexPath: IndexPath(item: 0, section: 0),
          finalItemIndexPath: IndexPath(item: 3, section: 1)),
        .itemMove(
          initialItemIndexPath: IndexPath(item: 1, section: 0),
          finalItemIndexPath: IndexPath(item: 0, section: 1)),
        .itemMove(
          initialItemIndexPath: IndexPath(item: 0, section: 2),
          finalItemIndexPath: IndexPath(item: 1, section: 2)),
      ],
      modelStateBeforeBatchUpdates: modelStateBeforeBatchUpdates)

    XCTAssert(
      (
        modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 0, section: 0)) ==
          modelState.idForItemModel(at: IndexPath(item: 3, section: 1)) &&
        modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 1, section: 0)) ==
          modelState.idForItemModel(at: IndexPath(item: 0, section: 1)) &&
        modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 0, section: 2)) ==
          modelState.idForItemModel(at: IndexPath(item: 1, section: 2))
      ),
      "The model state item models before / after updates are in an incorrect state")

    XCTAssert(
      (
        modelStateBeforeBatchUpdates.indexPathForItemModel(
          withID: modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 0, section: 0))!)! ==
          IndexPath(item: 0, section: 0) &&
        modelStateBeforeBatchUpdates.indexPathForItemModel(
          withID: modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 1, section: 0))!)! ==
          IndexPath(item: 1, section: 0) &&
        modelStateBeforeBatchUpdates.indexPathForItemModel(
          withID: modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 0, section: 2))!)! ==
          IndexPath(item: 0, section: 2) &&
        modelState.indexPathForItemModel(
          withID: modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 0, section: 0))!)! ==
          IndexPath(item: 3, section: 1) &&
        modelState.indexPathForItemModel(
          withID: modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 1, section: 0))!)! ==
          IndexPath(item: 0, section: 1) &&
        modelState.indexPathForItemModel(
          withID: modelStateBeforeBatchUpdates.idForItemModel(at: IndexPath(item: 0, section: 2))!)! ==
          IndexPath(item: 1, section: 2)
      ),
      "The model state item models before / after updates are in an incorrect state")
  }

  func testAllUpdatesNoCrash() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 6,
      numberOfItemsPerSection: 2)
    modelState.setSections(initialSections)

    modelState.applyUpdates([
        .sectionReload(
          sectionIndex: 3,
          newSection: ModelHelpers.basicSectionModels(
            numberOfSections: 1,
            numberOfItemsPerSection: 2).first!),
        .itemReload(
          itemIndexPath: IndexPath(item: 0, section: 4),
          newItem: ModelHelpers.basicItemModel()),
        .sectionInsert(
          sectionIndex: 2,
          newSection: ModelHelpers.basicSectionModels(
            numberOfSections: 1,
            numberOfItemsPerSection: 5).first!),
        .itemInsert(
          itemIndexPath: IndexPath(item: 5, section: 2),
          newItem: ModelHelpers.basicItemModel()),
        .sectionDelete(sectionIndex: 0),
        .itemDelete(itemIndexPath: IndexPath(item: 0, section: 1)),
        .sectionMove(initialSectionIndex: 5, finalSectionIndex: 0),
        .itemMove(
          initialItemIndexPath: IndexPath(item: 0, section: 4),
          finalItemIndexPath: IndexPath(item: 0, section: 1)),
      ],
      modelStateBeforeBatchUpdates: modelState.copy())

    XCTAssert(true)
  }

  // MARK: Private

  private var modelState: ModelState!

}
