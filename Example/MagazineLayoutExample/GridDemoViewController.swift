// Created by Bryan Keller on 11/4/25.
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

// MARK: - GridDemoViewController

final class GridDemoViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Grid Layout"
    view.backgroundColor = .systemBackground

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addButtonTapped)),
      UIBarButtonItem(
        image: UIImage(systemName: "shuffle"),
        style: .plain,
        target: self,
        action: #selector(shuffleButtonTapped)),
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

  private typealias DataSource = UICollectionViewDiffableDataSource<Int, GridItem>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, GridItem>

  private lazy var collectionView: UICollectionView = {
    let layout = MagazineLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    return collectionView
  }()

  private lazy var dataSource: DataSource = {
    let cellRegistration = UICollectionView.CellRegistration<MagazineLayoutCollectionViewCell, GridItem>
    { cell, indexPath, item in
      cell.contentConfiguration = UIHostingConfiguration {
        GridItemView(item: item)
      }
      .margins(.all, 0)
    }

    return DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration,
          for: indexPath,
          item: item)
      })
  }()

  private var items: [GridItem] = []

  private func loadInitialData() {
    let widthModes: [MagazineLayoutItemWidthMode] = [
      .fullWidth(respectsHorizontalInsets: true),
      .halfWidth,
      .halfWidth,
      .thirdWidth,
      .thirdWidth,
      .thirdWidth,
      .fractionalWidth(divisor: 4),
      .fractionalWidth(divisor: 4),
      .fractionalWidth(divisor: 4),
      .fractionalWidth(divisor: 4),
      .fractionalWidth(divisor: 5),
      .fractionalWidth(divisor: 5),
      .fractionalWidth(divisor: 5),
      .fractionalWidth(divisor: 5),
      .fractionalWidth(divisor: 5),
      .fullWidth(respectsHorizontalInsets: true),
      .thirdWidth,
      .halfWidth,
    ]

    items = widthModes.map { widthMode in
      GridItem(
        text: textForWidthMode(widthMode),
        color: colorForWidthMode(widthMode),
        widthMode: widthMode)
    }

    applySnapshot(animatingDifferences: false)
  }

  private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([0])
    snapshot.appendItems(items, toSection: 0)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }

  private func colorForWidthMode(_ widthMode: MagazineLayoutItemWidthMode) -> UIColor {
    switch widthMode {
    case .fullWidth:
      return .systemRed
    case .halfWidth:
      return .systemBlue
    case .thirdWidth:
      return .systemGreen
    case let .fractionalWidth(divisor):
      if divisor == 4 {
        return .systemPurple
      } else if divisor == 5 {
        return .systemOrange
      } else if divisor == 6 {
        return .systemCyan
      } else {
        return .systemTeal
      }
    @unknown default:
      return .systemRed
    }
  }

  private func textForWidthMode(_ widthMode: MagazineLayoutItemWidthMode) -> String {
    switch widthMode {
    case .fullWidth:
      return "Full Width"
    case .halfWidth:
      return "Half Width"
    case .thirdWidth:
      return "Third Width"
    case let .fractionalWidth(divisor):
      if divisor == 4 {
        return "Quarter Width"
      } else if divisor == 5 {
        return "1/5 Width"
      } else {
        return "1/\(divisor) Width"
      }
    @unknown default:
      return "Unknown Width"
    }
  }

  @objc
  private func addButtonTapped() {
    let widthModes: [MagazineLayoutItemWidthMode] = [
      .fullWidth(respectsHorizontalInsets: true),
      .halfWidth,
      .thirdWidth,
      .fractionalWidth(divisor: 4),
      .fractionalWidth(divisor: 5),
    ]

    let selectedWidthMode = widthModes.randomElement() ?? .halfWidth

    let newItem = GridItem(
      text: textForWidthMode(selectedWidthMode),
      color: colorForWidthMode(selectedWidthMode),
      widthMode: selectedWidthMode)

    let insertIndex = Int.random(in: 0...items.count)
    items.insert(newItem, at: insertIndex)

    applySnapshot()
  }

  @objc
  private func shuffleButtonTapped() {
    items.shuffle()
    applySnapshot()
  }
}

// MARK: UICollectionViewDelegate

extension GridDemoViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    items.remove(at: indexPath.item)
    applySnapshot()
  }
}

// MARK: UICollectionViewDelegateMagazineLayout

extension GridDemoViewController: UICollectionViewDelegateMagazineLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
  {
    return MagazineLayoutItemSizeMode(
      widthMode: items[indexPath.item].widthMode,
      heightMode: .dynamic)
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

// MARK: - GridItem

private struct GridItem: Hashable {

  // MARK: Lifecycle

  init(
    id: UUID = UUID(),
    text: String,
    color: UIColor,
    widthMode: MagazineLayoutItemWidthMode)
  {
    self.id = id
    self.text = text
    self.color = color
    self.widthMode = widthMode
  }

  // MARK: Internal

  let id: UUID
  let text: String
  let color: UIColor
  let widthMode: MagazineLayoutItemWidthMode

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: GridItem, rhs: GridItem) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - GridItemView

private struct GridItemView: View {
  let item: GridItem

  var body: some View {
    VStack {
      Text(item.text)
        .font(.body)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, minHeight: 80)
    .padding(16)
    .background(Color(item.color))
    .cornerRadius(12)
  }
}
