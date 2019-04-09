// Created by bryankeller on 11/28/18.
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

import MagazineLayout
import UIKit

// MARK: - DataSource

final class DataSource: NSObject {

  private(set) var sectionInfos = [SectionInfo]()

  func insert(_ sectionInfo: SectionInfo, atSectionIndex sectionIndex: Int) {
    sectionInfos.insert(sectionInfo, at: sectionIndex)
  }

  func insert(
    _ itemInfo: ItemInfo,
    atItemIndex itemIndex: Int,
    inSectionAtIndex sectionIndex: Int)
  {
    sectionInfos[sectionIndex].itemInfos.insert(itemInfo, at: itemIndex)
  }

  func removeSection(atSectionIndex sectionIndex: Int) {
    sectionInfos.remove(at: sectionIndex)
  }

  func removeItem(atItemIndex itemIndex: Int, inSectionAtIndex sectionIndex: Int) {
    sectionInfos[sectionIndex].itemInfos.remove(at: itemIndex)
  }

  func setHeaderInfo(_ headerInfo: HeaderInfo, forSectionAtIndex sectionIndex: Int) {
    sectionInfos[sectionIndex].headerInfo = headerInfo
  }

  func setFooterInfo(_ footerInfo: FooterInfo, forSectionAtIndex sectionIndex: Int) {
    sectionInfos[sectionIndex].footerInfo = footerInfo
  }

}

// MARK: UICollectionViewDataSource

extension DataSource: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sectionInfos.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int)
    -> Int
  {
    return sectionInfos[section].itemInfos.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: Cell.description(),
      for: indexPath) as! Cell
    let itemInfo = sectionInfos[indexPath.section].itemInfos[indexPath.item]
    cell.set(itemInfo)
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath)
    -> UICollectionReusableView
  {
    switch kind {
    case MagazineLayout.SupplementaryViewKind.sectionHeader:
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: MagazineLayout.SupplementaryViewKind.sectionHeader,
        withReuseIdentifier: Header.description(),
        for: indexPath) as! Header
      header.set(sectionInfos[indexPath.section].headerInfo)
      return header
    case MagazineLayout.SupplementaryViewKind.sectionFooter:
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: MagazineLayout.SupplementaryViewKind.sectionFooter,
        withReuseIdentifier: Footer.description(),
        for: indexPath) as! Footer
      header.set(sectionInfos[indexPath.section].footerInfo)
      return header
    case MagazineLayout.SupplementaryViewKind.sectionBackground:
      return collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: Background.description(),
        for: indexPath)
    default:
      fatalError("Not supported")
    }
  }

}

// MARK: DataSourceCountsProvider

extension DataSource: DataSourceCountsProvider {

  var numberOfSections: Int {
    return sectionInfos.count
  }

  func numberOfItemsInSection(withIndex sectionIndex: Int) -> Int {
    return sectionInfos[sectionIndex].itemInfos.count
  }

}
