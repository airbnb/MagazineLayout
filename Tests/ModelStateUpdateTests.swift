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
    modelState.applyUpdates([.sectionInsert(sectionIndex: 0, newSection: sectionToInsert)])

    XCTAssert(
      modelState.isPerformingBatchUpdates == true,
      "`isPerformingBatchUpdates` should be true")

    modelState.clearInProgressBatchUpdateState()

    XCTAssert(
      modelState.isPerformingBatchUpdates == false,
      "`isPerformingBatchUpdates` should be false")
  }

  func testSectionReload() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 3)
    modelState.setSections(initialSections)

    let replacementSection = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 1).first!
    modelState.applyUpdates(
      [
        .sectionReload(sectionIndex: 0, newSection: replacementSection)
      ])

    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .afterUpdates) == 1,
      "The model state should contain 1 item in section 0")
    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .beforeUpdates) == 3,
      "The model state's section models before updates should contain 3 items in section 0")
  }

  func testItemReload() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 1,
      numberOfItemsPerSection: 3)
    modelState.setSections(initialSections)

    let replacementItem = ModelHelpers.basicItemModel()
    let indexPath = IndexPath(item: 0, section: 0)
    modelState.applyUpdates(
      [
        .itemReload(itemIndexPath: indexPath, newItem: replacementItem)
      ])

    XCTAssert(
      modelState.idForItemModel(at: indexPath, .afterUpdates) == replacementItem.id,
      "The model state should contain 1 item in section 0")
    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .beforeUpdates) == 3,
      "The model state's section models before updates should contain 3 items in section 0")
  }

  func testSectionInserts() {
    let sectionsToInsert = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 0)
    modelState.applyUpdates(
      [
        .sectionInsert(sectionIndex: 2, newSection: sectionsToInsert[2]),
        .sectionInsert(sectionIndex: 1, newSection: sectionsToInsert[1]),
        .sectionInsert(sectionIndex: 0, newSection: sectionsToInsert[0]),
      ])

    XCTAssert(
      modelState.numberOfSections(.afterUpdates) == 3,
      "The model state should contain 3 sections")
    XCTAssert(
      modelState.numberOfSections(.beforeUpdates) == 0,
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
    modelState.applyUpdates(
      [
        .itemInsert(itemIndexPath: IndexPath(item: 2, section: 0), newItem: itemsToInsert[2]),
        .itemInsert(itemIndexPath: IndexPath(item: 0, section: 0), newItem: itemsToInsert[0]),
        .itemInsert(itemIndexPath: IndexPath(item: 1, section: 0), newItem: itemsToInsert[1]),
      ])

    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .afterUpdates) == 3,
      "The model state should contain 3 items in section 0")
    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .beforeUpdates) == 0,
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

    modelState.applyUpdates(
      [
        .sectionDelete(sectionIndex: 2),
        .sectionDelete(sectionIndex: 0),
        .sectionDelete(sectionIndex: 1),
      ])

    XCTAssert(
      modelState.numberOfSections(.afterUpdates) == 0,
      "The model state should contain 0 sections")
    XCTAssert(
      modelState.numberOfSections(.beforeUpdates) == 3,
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

    modelState.applyUpdates(
      [
        .itemDelete(itemIndexPath: IndexPath(item: 2, section: 0)),
        .itemDelete(itemIndexPath: IndexPath(item: 0, section: 0)),
        .itemDelete(itemIndexPath: IndexPath(item: 1, section: 0)),
      ])

    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .afterUpdates) == 0,
      "The model state should contain 0 items in section 0")
    XCTAssert(
      modelState.numberOfItems(inSectionAtIndex: 0, .beforeUpdates) == 3,
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

    modelState.applyUpdates(
      [
        .sectionMove(initialSectionIndex: 0, finalSectionIndex: 1),
        .itemMove(initialItemIndexPath: .init(item: 0, section: 0), finalItemIndexPath: .init(item: 0, section: 1)),
        .itemMove(initialItemIndexPath: .init(item: 1, section: 0), finalItemIndexPath: .init(item: 1, section: 1)),

        .sectionMove(initialSectionIndex: 2, finalSectionIndex: 0),
        .itemMove(initialItemIndexPath: .init(item: 0, section: 2), finalItemIndexPath: .init(item: 0, section: 0)),
        .itemMove(initialItemIndexPath: .init(item: 1, section: 2), finalItemIndexPath: .init(item: 1, section: 0)),
      ])

    XCTAssert(
      (
        modelState.idForSectionModel(atIndex: 0, .beforeUpdates) ==
          modelState.idForSectionModel(atIndex: 1, .afterUpdates) &&
        modelState.idForSectionModel(atIndex: 1, .beforeUpdates) ==
          modelState.idForSectionModel(atIndex: 2, .afterUpdates) &&
        modelState.idForSectionModel(atIndex: 2, .beforeUpdates) ==
          modelState.idForSectionModel(atIndex: 0, .afterUpdates)
      ),
      "The model state's section models before / after updates are in an incorrect state")

    XCTAssert(
      (
        modelState.indexForSectionModel(withID: initialSections[0].id, .beforeUpdates) == 0 &&
        modelState.indexForSectionModel(withID: initialSections[1].id, .beforeUpdates) == 1 &&
        modelState.indexForSectionModel(withID: initialSections[2].id, .beforeUpdates) == 2 &&
        modelState.indexForSectionModel(withID: initialSections[0].id, .afterUpdates) == 1 &&
        modelState.indexForSectionModel(withID: initialSections[1].id, .afterUpdates) == 2 &&
        modelState.indexForSectionModel(withID: initialSections[2].id, .afterUpdates) == 0
      ),
      "The model state's section models before / after updates are in an incorrect state")

    XCTAssert(
      (
        modelState.numberOfItems(inSectionAtIndex: 0, .beforeUpdates) ==
          modelState.numberOfItems(inSectionAtIndex: 1, .afterUpdates) &&
        modelState.numberOfItems(inSectionAtIndex: 1, .beforeUpdates) ==
          modelState.numberOfItems(inSectionAtIndex: 2, .afterUpdates) &&
        modelState.numberOfItems(inSectionAtIndex: 2, .beforeUpdates) ==
          modelState.numberOfItems(inSectionAtIndex: 0, .afterUpdates)
      ),
      "The model state's section models before / after updates are in an incorrect state")
  }

  func testItemMoves() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 3,
      numberOfItemsPerSection: 2)
    modelState.setSections(initialSections)

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
      ])

    XCTAssert(
      (
        modelState.idForItemModel(at: IndexPath(item: 0, section: 0), .beforeUpdates) ==
          modelState.idForItemModel(at: IndexPath(item: 3, section: 1), .afterUpdates) &&
        modelState.idForItemModel(at: IndexPath(item: 1, section: 0), .beforeUpdates) ==
          modelState.idForItemModel(at: IndexPath(item: 0, section: 1), .afterUpdates) &&
        modelState.idForItemModel(at: IndexPath(item: 0, section: 2), .beforeUpdates) ==
          modelState.idForItemModel(at: IndexPath(item: 1, section: 2), .afterUpdates)
      ),
      "The model state item models before / after updates are in an incorrect state")

    XCTAssert(
      (
        modelState.indexPathForItemModel(
          withID: modelState.idForItemModel(at: IndexPath(item: 0, section: 0), .beforeUpdates)!,
          .beforeUpdates)! == IndexPath(item: 0, section: 0) &&
        modelState.indexPathForItemModel(
          withID: modelState.idForItemModel(at: IndexPath(item: 1, section: 0), .beforeUpdates)!,
          .beforeUpdates)! == IndexPath(item: 1, section: 0) &&
        modelState.indexPathForItemModel(
          withID: modelState.idForItemModel(at: IndexPath(item: 0, section: 2), .beforeUpdates)!,
          .beforeUpdates)! == IndexPath(item: 0, section: 2) &&
        modelState.indexPathForItemModel(
          withID: modelState.idForItemModel(at: IndexPath(item: 0, section: 0), .beforeUpdates)!,
          .afterUpdates)! == IndexPath(item: 3, section: 1) &&
        modelState.indexPathForItemModel(
          withID: modelState.idForItemModel(at: IndexPath(item: 1, section: 0), .beforeUpdates)!,
          .afterUpdates)! == IndexPath(item: 0, section: 1) &&
        modelState.indexPathForItemModel(
          withID: modelState.idForItemModel(at: IndexPath(item: 0, section: 2), .beforeUpdates)!,
          .afterUpdates)! == IndexPath(item: 1, section: 2)
      ),
      "The model state item models before / after updates are in an incorrect state")
  }

  func testAllUpdatesNoCrash() {
    let initialSections = ModelHelpers.basicSectionModels(
      numberOfSections: 6,
      numberOfItemsPerSection: 2)
    modelState.setSections(initialSections)

    modelState.applyUpdates(
      [
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
      ])

    XCTAssert(true)
  }

  // MARK: Private

  private var modelState: ModelState!

}
