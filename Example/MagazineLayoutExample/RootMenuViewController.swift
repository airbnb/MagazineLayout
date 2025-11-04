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

// MARK: - RootMenuViewController

final class RootMenuViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "MagazineLayout Demos"
    view.backgroundColor = .systemBackground

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    applyInitialSnapshot()
  }

  // MARK: Private

  private lazy var collectionView: UICollectionView = {
    let layout = MagazineLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    return collectionView
  }()

  private typealias DataSource = UICollectionViewDiffableDataSource<Int, DemoOption>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DemoOption>

  private lazy var dataSource: DataSource = {
    let cellRegistration = UICollectionView.CellRegistration<MagazineLayoutCollectionViewCell, DemoOption>
    { cell, indexPath, option in
      cell.contentConfiguration = UIHostingConfiguration {
        MenuItemView(option: option)
      }
      .margins(.all, 0)
    }

    return DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, option in
        collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration,
          for: indexPath,
          item: option)
      })
  }()

  private func applyInitialSnapshot() {
    var snapshot = Snapshot()
    snapshot.appendSections([0])
    snapshot.appendItems(DemoOption.allCases, toSection: 0)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

// MARK: UICollectionViewDelegate

extension RootMenuViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let option = dataSource.itemIdentifier(for: indexPath) else { return }

    let viewController: UIViewController
    switch option {
    case .grid:
      viewController = GridDemoViewController()
    case .list:
      viewController = ListDemoViewController()
    case .messageThread:
      viewController = MessageThreadDemoViewController()
    case .performance:
      viewController = PerformanceDemoViewController()
    }

    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: UICollectionViewDelegateMagazineLayout

extension RootMenuViewController: UICollectionViewDelegateMagazineLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
  {
    MagazineLayoutItemSizeMode(
      widthMode: .fullWidth(respectsHorizontalInsets: true),
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
    16
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
  {
    16
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
  }
}

// MARK: - DemoOption

private enum DemoOption: String, CaseIterable {
  case grid = "Grid Layout"
  case list = "List Layout"
  case messageThread = "Message Thread"
  case performance = "Performance"

  var subtitle: String {
    switch self {
    case .grid:
      return "Various width modes and flexible layouts"
    case .list:
      return "Full-width items with pinned headers & footers"
    case .messageThread:
      return "Bottom-to-top layout with pagination"
    case .performance:
      return "10,000 items with traditional data source"
    }
  }

  var color: UIColor {
    switch self {
    case .grid:
      return .systemBlue
    case .list:
      return .systemRed
    case .messageThread:
      return .systemPurple
    case .performance:
      return .systemGreen
    }
  }
}

// MARK: - MenuItemView

private struct MenuItemView: View {
  let option: DemoOption

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(option.rawValue)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)

      Text(option.subtitle)
        .font(.subheadline)
        .foregroundColor(.white.opacity(0.9))
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(24)
    .background(Color(option.color))
    .cornerRadius(16)
  }
}
