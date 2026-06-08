// Created by Bryan Keller on 6/8/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

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

import os

// MARK: - Signposting

let signpostLog = OSLog(subsystem: "com.airbnb.MagazineLayout", category: "MagazineLayout")

enum SignpostName {
  static let collectionViewContentSize: StaticString = "MagazineLayout.collectionViewContentSize"
  static let prepare: StaticString = "MagazineLayout.prepare"
  static let prepareUpdateWidths: StaticString = "MagazineLayout.prepare.prepareUpdateWidths"
  static let prepareUpdateLayoutMetrics: StaticString = "MagazineLayout.prepare.prepareUpdateLayoutMetrics"
  static let prepareRecreateSectionModels: StaticString = "MagazineLayout.prepare.recreateSectionModels"
  static let layoutAttributesForElementsInRect: StaticString = "MagazineLayout.layoutAttributesForElementsInRect"
  static let prepareForCollectionViewUpdates: StaticString = "MagazineLayout.prepareForCollectionViewUpdates"
  static let invalidateLayout: StaticString = "MagazineLayout.invalidateLayout"
  static let preferredLayoutAttributesFittingCell: StaticString = "MagazineLayout.preferredLayoutAttributesFitting.cell"
  static let preferredLayoutAttributesFittingReusableView: StaticString = "MagazineLayout.preferredLayoutAttributesFitting.reusableView"
}
