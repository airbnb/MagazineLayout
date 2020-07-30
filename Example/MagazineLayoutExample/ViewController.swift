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

// MARK: - ViewController

final class ViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "MagazineLayout Example"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addButtonTapped))

    let reloadDataButton = UIBarButtonItem(
      barButtonSystemItem: .refresh,
      target: self,
      action: #selector(reloadButtonTapped))
    navigationItem.leftBarButtonItem = reloadDataButton

    view.addSubview(collectionView)

    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    loadDefaultData()
  }

  // MARK: Private

  private lazy var collectionView: UICollectionView = {
    let layout = MagazineLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.description())
    collectionView.register(
      Header.self,
      forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionHeader,
      withReuseIdentifier: Header.description())
    collectionView.register(
      Footer.self,
      forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionFooter,
      withReuseIdentifier: Footer.description())
    collectionView.register(
      Background.self,
      forSupplementaryViewOfKind: MagazineLayout.SupplementaryViewKind.sectionBackground,
      withReuseIdentifier: Background.description())
    collectionView.isPrefetchingEnabled = false
    collectionView.dataSource = dataSource
    collectionView.delegate = self
    collectionView.backgroundColor = .white
    collectionView.contentInsetAdjustmentBehavior = .always
    return collectionView
  }()

  private lazy var dataSource = DataSource()

  #if os(iOS)
  private var lastItemCreationPanelViewState: ItemCreationPanelViewState?
  #endif

  private func removeAllData() {
    collectionView.performBatchUpdates({
      for sectionIndex in (0..<dataSource.numberOfSections).reversed() {
        dataSource.removeSection(atSectionIndex: sectionIndex)
        collectionView.deleteSections(IndexSet(arrayLiteral: sectionIndex))
      }
    }, completion: nil)
  }

  private func loadDefaultData() {
    removeAllData()

    let section0 = SectionInfo(
      headerInfo: HeaderInfo(
        visibilityMode: .visible(heightMode: .dynamic, pinToVisibleBounds: true),
        title: "Welcome!"),
      itemInfos: [
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "MagazineLayout lets you layout items in vertically scrolling grids and lists.",
          color: Colors.red),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "As you can see...",
          color: Colors.red),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .dynamic),
          text: "items can be vertically self-sized",
          color: Colors.orange),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .dynamic),
          text: "based on their contents.",
          color: Colors.orange),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .dynamic),
          text: "Widths are determined",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .dynamic),
          text: "by item width modes",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .dynamic),
          text: "3 across",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .dynamic),
          text: "3 across",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .dynamic),
          text: "3 across",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "1",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "0",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: " ",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "a",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "c",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "r",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "o",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "s",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: "s",
          color: Colors.blue),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fractionalWidth(divisor: 10),
            heightMode: .dynamic),
          text: ":)",
          color: Colors.blue),
      ],
      footerInfo: FooterInfo(
        visibilityMode: .hidden,
        title: ""),
      backgroundInfo: BackgroundInfo(visibilityMode: .hidden)
    )

    let section1 = SectionInfo(
      headerInfo: HeaderInfo(
        visibilityMode: .visible(heightMode: .dynamic, pinToVisibleBounds: false),
        title: "Self-sizing supplementary views (headers and footers) are also supported."),
      itemInfos: [
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "If you really want to turn off self-sizing for a particular item...",
          color: Colors.red),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .static(height: 200)),
          text: "you can, but any dynamic content could get truncated or have too much padding.",
          color: Colors.red),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "You can also ask items to size dynamically first, but ultimately stretch to match the tallest item in the same row of items.",
          color: Colors.orange),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .dynamic),
          text: "I'm the tallest item because I have so much text...",
          color: Colors.orange),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .halfWidth,
            heightMode: .dynamicAndStretchToTallestItemInRow),
          text: "and I'll stretch to match your height.",
          color: Colors.orange),
      ],
      footerInfo: FooterInfo(
        visibilityMode: .hidden,
        title: ""),
      backgroundInfo: BackgroundInfo(visibilityMode: .visible)
    )

    let section2 = SectionInfo(
      headerInfo: HeaderInfo(
        visibilityMode: .visible(heightMode: .dynamic, pinToVisibleBounds: false),
        title: "Using this app:"),
      itemInfos: [
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "Add new items by tapping the + in the top right.",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "Delete items by tapping them in the collection view.",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .fullWidth(respectsHorizontalInsets: true),
            heightMode: .dynamic),
          text: "Tap the reload icon in the top left to...",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .dynamicAndStretchToTallestItemInRow),
          text: "delete all data,",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .dynamicAndStretchToTallestItemInRow),
          text: "reset to default data,",
          color: Colors.green),
        ItemInfo(
          sizeMode: MagazineLayoutItemSizeMode(
            widthMode: .thirdWidth,
            heightMode: .dynamicAndStretchToTallestItemInRow),
          text: "or invoke reloadData().",
          color: Colors.green),
      ],
      footerInfo: FooterInfo(
        visibilityMode: .visible(heightMode: .dynamic, pinToVisibleBounds: true),
        title: "Enjoy using MagazineLayout!"),
      backgroundInfo: BackgroundInfo(visibilityMode: .hidden)
    )

    collectionView.performBatchUpdates({
      dataSource.insert(section0, atSectionIndex: 0)
      dataSource.insert(section1, atSectionIndex: 1)
      dataSource.insert(section2, atSectionIndex: 2)

      collectionView.insertSections(IndexSet(arrayLiteral: 0, 1, 2))
    }, completion: nil)
  }

  @objc
  private func reloadButtonTapped() {
    let alertController = UIAlertController(
      title: "Reload",
      message: nil,
      preferredStyle: .actionSheet)
    alertController.addAction(
      UIAlertAction(
        title: "Reload data",
        style: .default,
        handler: { [weak self] _ in
          self?.collectionView.reloadData()
        }))
    alertController.addAction(
      UIAlertAction(
        title: "Load default data",
        style: .destructive,
        handler: { [weak self] _ in
          self?.loadDefaultData()
        }))
    alertController.addAction(
      UIAlertAction(
        title: "Remove all data",
        style: .destructive,
        handler: { [weak self] _ in
          self?.removeAllData()
        }))
    alertController.addAction(
      UIAlertAction(
        title: "Cancel",
        style: .cancel,
        handler: nil))

    present(alertController, animated: true, completion: nil)
  }

  @objc
  private func addButtonTapped() {
    #if os(iOS)
    let creationPanelViewController = CreationPanelViewController(
      dataSourceCountsProvider: dataSource,
      initialState: lastItemCreationPanelViewState)

    creationPanelViewController.doneButtonTapHandler = { [weak self] state in
      self?.lastItemCreationPanelViewState = state
      creationPanelViewController.dismiss(animated: true, completion: { [weak self] in
        self?.collectionView.performBatchUpdates({
          let itemInfo = ItemInfo(
            sizeMode: state.sizeMode,
            text: state.text,
            color: state.color)

          if state.sectionIndex < self?.dataSource.numberOfSections ?? 0 {
            self?.dataSource.insert(
              itemInfo,
              atItemIndex: state.itemIndex,
              inSectionAtIndex: state.sectionIndex)
            self?.collectionView.insertItems(
              at: [IndexPath(item: state.itemIndex, section: state.sectionIndex)])
          } else {
            let sectionInfo = SectionInfo(
              headerInfo: HeaderInfo(
                visibilityMode: .visible(heightMode: .dynamic, pinToVisibleBounds: true),
                title: "Header"),
              itemInfos: [itemInfo],
              footerInfo: FooterInfo(
                visibilityMode: .visible(heightMode: .dynamic, pinToVisibleBounds: true),
                title: "Footer"),
              backgroundInfo: BackgroundInfo(visibilityMode: .hidden)
            )
            self?.dataSource.insert(sectionInfo, atSectionIndex: state.sectionIndex)
            self?.collectionView.insertSections(IndexSet(integer: state.sectionIndex))
          }
        }, completion: nil)
      })
    }

    let navigationController = UINavigationController(
      rootViewController: creationPanelViewController)
    present(navigationController, animated: true, completion: nil)
    #else
    let alertController = UIAlertController(
      title: "Error",
      message: "Not implemented for tvOS",
      preferredStyle: .alert)
    alertController.addAction(
      UIAlertAction(
        title: "OK",
        style: .default,
        handler: nil))

    present(alertController, animated: true, completion: nil)
    #endif
  }

}

// MARK: UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.performBatchUpdates({
      if dataSource.numberOfItemsInSection(withIndex: indexPath.section) > 1 {
        dataSource.removeItem(atItemIndex: indexPath.item, inSectionAtIndex: indexPath.section)
        collectionView.deleteItems(at: [indexPath])
      } else {
        dataSource.removeSection(atSectionIndex: indexPath.section)
        collectionView.deleteSections(IndexSet(integer: indexPath.section))
      }
    }, completion: nil)
  }

}

// MARK: UICollectionViewDelegateMagazineLayout

extension ViewController: UICollectionViewDelegateMagazineLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
  {
    return dataSource.sectionInfos[indexPath.section].itemInfos[indexPath.item].sizeMode
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForHeaderInSectionAtIndex index: Int)
    -> MagazineLayoutHeaderVisibilityMode
  {
    return dataSource.sectionInfos[index].headerInfo.visibilityMode
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode
  {
    return dataSource.sectionInfos[index].footerInfo.visibilityMode
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForBackgroundInSectionAtIndex index: Int)
    -> MagazineLayoutBackgroundVisibilityMode
  {
    return dataSource.sectionInfos[index].backgroundInfo.visibilityMode
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    horizontalSpacingForItemsInSectionAtIndex index: Int)
    -> CGFloat
  {
    return 12
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
  {
    return 12
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    return UIEdgeInsets(top: 24, left: 4, bottom: 24, right: 4)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    return UIEdgeInsets(top: 24, left: 4, bottom: 24, right: 4)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    // Fade and drop out
    finalLayoutAttributes.alpha = 0
    finalLayoutAttributes.transform = .init(scaleX: 0.2, y: 0.2)
  }

}
