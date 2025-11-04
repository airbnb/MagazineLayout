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

// MARK: - ListDemoViewController

final class ListDemoViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "List Layout"
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

  private typealias DataSource = UICollectionViewDiffableDataSource<UUID, ListItem>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<UUID, ListItem>

  private lazy var collectionView: UICollectionView = {
    let layout = MagazineLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    return collectionView
  }()

  private lazy var dataSource: DataSource = {
    let cellRegistration = UICollectionView.CellRegistration<MagazineLayoutCollectionViewCell, ListItem>
    { cell, indexPath, item in
      cell.contentConfiguration = UIHostingConfiguration {
        ListItemView(item: item)
      }
      .margins(.all, 0)
    }

    let headerRegistration = UICollectionView.SupplementaryRegistration<MagazineLayoutCollectionViewCell>(
      elementKind: MagazineLayout.SupplementaryViewKind.sectionHeader
    ) { [weak self] supplementaryView, elementKind, indexPath in
      guard let self, indexPath.section < self.sections.count else { return }

      let section = self.sections[indexPath.section]
      supplementaryView.contentConfiguration = UIHostingConfiguration {
        SectionHeaderView(title: section.title)
      }
      .margins(.all, 0)
    }

    let footerRegistration = UICollectionView.SupplementaryRegistration<MagazineLayoutCollectionViewCell>(
      elementKind: MagazineLayout.SupplementaryViewKind.sectionFooter
    ) { supplementaryView, elementKind, indexPath in
      supplementaryView.contentConfiguration = UIHostingConfiguration {
        SectionFooterView()
      }
      .margins(.all, 0)
    }

    dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration,
          for: indexPath,
          item: item)
      })

    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      switch kind {
      case MagazineLayout.SupplementaryViewKind.sectionHeader:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration,
          for: indexPath)
      case MagazineLayout.SupplementaryViewKind.sectionFooter:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: footerRegistration,
          for: indexPath)
      default:
        return nil
      }
    }

    return dataSource
  }()

  private var sections: [ListSection] = []

  private func loadInitialData() {
    sections = [
      ListSection(
        title: "Featured Items",
        items: [
          ListItem(
            title: "Item 1",
            subtitle: "A featured item with important content",
            color: .systemRed),
          ListItem(
            title: "Item 2",
            subtitle: "Another featured item to showcase",
            color: .systemBlue),
          ListItem(
            title: "Item 3",
            subtitle: "The third item in this section",
            color: .systemGreen),
        ],
        headerPinned: true,
        footerPinned: false),
      ListSection(
        title: "Regular Items",
        items: [
          ListItem(
            title: "Item A",
            subtitle: "A regular item in the list",
            color: .systemPurple),
          ListItem(
            title: "Item B",
            subtitle: "Another regular item",
            color: .systemCyan),
          ListItem(
            title: "Item C",
            subtitle: "Yet another item",
            color: .systemOrange),
          ListItem(
            title: "Item D",
            subtitle: "More content here",
            color: .systemTeal),
        ],
        headerPinned: true,
        footerPinned: false),
      ListSection(
        title: "Special Section",
        items: [
          ListItem(
            title: "Special 1",
            subtitle: "This section has a pinned footer",
            color: .systemPink),
          ListItem(
            title: "Special 2",
            subtitle: "Notice the footer sticks",
            color: .systemYellow),
        ],
        headerPinned: true,
        footerPinned: true),
    ]

    applySnapshot(animatingDifferences: false)
  }

  private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = Snapshot()
    for section in sections {
      snapshot.appendSections([section.id])
      snapshot.appendItems(section.items, toSection: section.id)
    }
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }

  @objc
  private func addButtonTapped() {
    guard !sections.isEmpty else { return }

    let randomSectionIndex = Int.random(in: 0..<sections.count)
    let colors: [UIColor] = [
      .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemTeal,
      .systemBlue, .systemIndigo, .systemPurple, .systemPink, .systemCyan
    ]
    let newItem = ListItem(
      title: "New Item",
      subtitle: "Just added at \(Date().formatted(date: .omitted, time: .shortened))",
      color: colors.randomElement() ?? .systemBlue)

    let updatedSection = sections[randomSectionIndex]
    let insertIndex = Int.random(in: 0...updatedSection.items.count)
    var updatedItems = updatedSection.items
    updatedItems.insert(newItem, at: insertIndex)

    sections[randomSectionIndex] = ListSection(
      id: updatedSection.id,
      title: updatedSection.title,
      items: updatedItems,
      headerPinned: updatedSection.headerPinned,
      footerPinned: updatedSection.footerPinned)

    applySnapshot()
  }

  @objc
  private func shuffleButtonTapped() {
    sections = sections.map { section in
      ListSection(
        id: section.id,
        title: section.title,
        items: section.items.shuffled(),
        headerPinned: section.headerPinned,
        footerPinned: section.footerPinned)
    }
    applySnapshot()
  }

  private func sectionIndex(for sectionId: UUID) -> Int? {
    sections.firstIndex { $0.id == sectionId }
  }
}

// MARK: UICollectionViewDelegate

extension ListDemoViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let section = sections[indexPath.section]

    var updatedItems = section.items
    updatedItems.remove(at: indexPath.item)

    sections[indexPath.section] = ListSection(
      id: section.id,
      title: section.title,
      items: updatedItems,
      headerPinned: section.headerPinned,
      footerPinned: section.footerPinned)

    applySnapshot()
  }
}

// MARK: UICollectionViewDelegateMagazineLayout

extension ListDemoViewController: UICollectionViewDelegateMagazineLayout {
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
    let section = sections[index]
    return .visible(heightMode: .dynamic, pinToVisibleBounds: section.headerPinned)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode
  {
    let section = sections[index]
    return .visible(heightMode: .dynamic, pinToVisibleBounds: section.footerPinned)
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
    UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
}

// MARK: - ListSection

private struct ListSection: Hashable {

  // MARK: Lifecycle

  init(
    id: UUID = UUID(),
    title: String,
    items: [ListItem],
    headerPinned: Bool = true,
    footerPinned: Bool = false)
  {
    self.id = id
    self.title = title
    self.items = items
    self.headerPinned = headerPinned
    self.footerPinned = footerPinned
  }

  // MARK: Internal

  let id: UUID
  let title: String
  let items: [ListItem]
  let headerPinned: Bool
  let footerPinned: Bool

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ListSection, rhs: ListSection) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - ListItem

private struct ListItem: Hashable {

  // MARK: Lifecycle

  init(
    id: UUID = UUID(),
    title: String,
    subtitle: String,
    color: UIColor)
  {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.color = color
  }

  // MARK: Internal

  let id: UUID
  let title: String
  let subtitle: String
  let color: UIColor

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ListItem, rhs: ListItem) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - ListItemView

private struct ListItemView: View {
  let item: ListItem

  var body: some View {
    HStack(spacing: 16) {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(item.color))
        .frame(width: 60, height: 60)

      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .font(.headline)
          .foregroundColor(.primary)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)

        Text(item.subtitle)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()
    }
    .padding(16)
    .background(Color(UIColor.secondarySystemBackground))
    .cornerRadius(12)
  }
}

// MARK: - SectionHeaderView

private struct SectionHeaderView: View {
  let title: String

  var body: some View {
    HStack {
      Text(title)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(.primary)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(Color(UIColor.systemBackground).opacity(0.95))
  }
}

// MARK: - SectionFooterView

private struct SectionFooterView: View {
  var body: some View {
    HStack {
      Spacer()

      Text("Section footer")
        .font(.caption)
        .foregroundColor(.secondary)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(Color(UIColor.systemBackground).opacity(0.95))
  }
}
