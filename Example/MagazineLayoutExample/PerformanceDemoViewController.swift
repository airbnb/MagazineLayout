// Created by Bryan Keller on 11/5/25.
// Copyright © 2025 Airbnb, Inc.
//
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
import SwiftUI
import UIKit

// MARK: - PerformanceDemoViewController

final class PerformanceDemoViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Performance (10K Items)"
    view.backgroundColor = .systemBackground

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addButtonTapped)),
    ]

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    loadInitialData()
  }

  // MARK: Private

  private lazy var collectionView: UICollectionView = {
    let layout = MagazineLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(
      MagazineLayoutCollectionViewCell.self,
      forCellWithReuseIdentifier: "PerformanceCell")
    return collectionView
  }()

  private var items: [PerformanceItem] = []
  private var nextItemID = 0

  private let colors: [UIColor] = [
    .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemTeal,
    .systemBlue, .systemIndigo, .systemPurple, .systemPink, .systemCyan
  ]

  private func loadInitialData() {
    // Create 10,000 items
    items = (0..<10_000).map { index in
      let color = colors[index % colors.count]
      let item = PerformanceItem(id: nextItemID, color: color)
      nextItemID += 1
      return item
    }

    collectionView.reloadData()
  }

  @objc
  private func addButtonTapped() {
    let newItem = PerformanceItem(
      id: nextItemID,
      color: colors.randomElement() ?? .systemBlue)
    nextItemID += 1

    // Insert at index 0 with manual batch update
    collectionView.performBatchUpdates({
      items.insert(newItem, at: 0)
      collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }, completion: nil)
  }
}

// MARK: UICollectionViewDataSource

extension PerformanceDemoViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int)
    -> Int
  {
    return items.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "PerformanceCell",
      for: indexPath)

    let item = items[indexPath.item]

    cell.contentConfiguration = UIHostingConfiguration {
      PerformanceItemView(item: item)
    }
    .margins(.all, 0)

    return cell
  }
}

// MARK: UICollectionViewDelegate

extension PerformanceDemoViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.item < items.count else { return }

    // Delete with manual batch update
    collectionView.performBatchUpdates({
      items.remove(at: indexPath.item)
      collectionView.deleteItems(at: [indexPath])
    }, completion: nil)
  }
}

// MARK: UICollectionViewDelegateMagazineLayout

extension PerformanceDemoViewController: UICollectionViewDelegateMagazineLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
  {
    MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .dynamic)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForHeaderInSectionAtIndex index: Int)
    -> MagazineLayoutHeaderVisibilityMode
  {
    .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode
  {
    .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForBackgroundInSectionAtIndex index: Int)
    -> MagazineLayoutBackgroundVisibilityMode
  {
    .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    horizontalSpacingForItemsInSectionAtIndex index: Int)
    -> CGFloat
  {
    12
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
  {
    12
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    .zero
  }
}

// MARK: - PerformanceItem

private struct PerformanceItem {
  let id: Int
  let color: UIColor
}

// MARK: - PerformanceItemView

private struct PerformanceItemView: View {
  let item: PerformanceItem

  var body: some View {
    VStack {
      Text("Item \(item.id)")
        .font(.body)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, minHeight: 80)
    .padding(16)
    .background(Color(item.color))
    .cornerRadius(12)
  }
}
