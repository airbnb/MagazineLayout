// Created by bryankeller on 2/25/18.
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

import UIKit

/// Represents a collection view update with more type-expressivity than
/// `UICollectionViewUpdateItem`.
enum CollectionViewUpdate<SectionModel, ItemModel> {

  case sectionReload(sectionIndex: Int, newSection: SectionModel)
  case itemReload(itemIndexPath: IndexPath, newItem: ItemModel)

  case sectionDelete(sectionIndex: Int)
  case itemDelete(itemIndexPath: IndexPath)

  case sectionInsert(sectionIndex: Int, newSection: SectionModel)
  case itemInsert(itemIndexPath: IndexPath, newItem: ItemModel)

  case sectionMove(initialSectionIndex: Int, finalSectionIndex: Int)
  case itemMove(initialItemIndexPath: IndexPath, finalItemIndexPath: IndexPath)

}
