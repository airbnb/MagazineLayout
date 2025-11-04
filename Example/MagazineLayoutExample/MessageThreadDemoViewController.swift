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

// MARK: - MessageThreadDemoViewController

final class MessageThreadDemoViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Message Thread"
    view.backgroundColor = .systemBackground

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(
        title: "Send",
        style: .plain,
        target: self,
        action: #selector(sendButtonTapped)),
      UIBarButtonItem(
        title: "Receive",
        style: .plain,
        target: self,
        action: #selector(receiveButtonTapped)),
    ]

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    loadInitialMessages()
  }

  // MARK: Private

  private typealias DataSource = UICollectionViewDiffableDataSource<Int, Message>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Message>

  private lazy var collectionView: UICollectionView = {
    let layout = MagazineLayout()
    layout.verticalLayoutDirection = .bottomToTop
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    return collectionView
  }()

  private lazy var dataSource: DataSource = {
    let cellRegistration = UICollectionView.CellRegistration<MagazineLayoutCollectionViewCell, Message>
    { cell, indexPath, message in
      cell.contentConfiguration = UIHostingConfiguration {
        MessageView(message: message)
      }
      .margins(.all, 0)
    }

    return DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, message in
        collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration,
          for: indexPath,
          item: message)
      })
  }()

  private var messages: [Message] = []
  private var messageCounter = 0
  private var oldestMessageDate = Date()
  private var isLoadingMore = false

  private let sentMessages = [
    "Hey, how are you?",
    "That sounds great!",
    "I'm on my way",
    "See you soon!",
    "Thanks for letting me know",
    "Perfect timing",
    "Can't wait to see it",
    "Definitely interested",
    "Count me in!",
    "That works for me",
  ]

  private let receivedMessages = [
    "Good! How about you?",
    "I know, right?",
    "Great! I'll be here",
    "Looking forward to it!",
    "No problem at all",
    "Glad it works out",
    "Me too!",
    "Awesome, thanks!",
    "Cool, see you there",
    "Sounds like a plan",
  ]

  private func loadInitialMessages() {
    // Create 10 initial messages alternating between sent and received
    var initialMessages: [Message] = []
    var timestamp = Date()

    for i in 0..<20 {
      let isSent = i % 2 == 0
      let text = isSent
        ? sentMessages[i % sentMessages.count]
        : receivedMessages[i % receivedMessages.count]

      initialMessages.append(Message(
        text: text,
        isSent: isSent,
        timestamp: timestamp))

      timestamp = timestamp.addingTimeInterval(-60) // 1 minute earlier
    }

    messages = initialMessages.reversed()
    oldestMessageDate = messages.first?.timestamp ?? Date()
    messageCounter = messages.count

    applySnapshot(animatingDifferences: false)
  }

  private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([0])
    snapshot.appendItems(messages, toSection: 0)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }

  private func loadOlderMessages() {
    guard !isLoadingMore else { return }
    isLoadingMore = true

    // Simulate loading 10 older messages
    var olderMessages: [Message] = []
    var timestamp = oldestMessageDate.addingTimeInterval(-60)

    for i in 0..<10 {
      let isSent = (messageCounter + i) % 2 == 0
      let text = isSent
        ? sentMessages[(messageCounter + i) % sentMessages.count]
        : receivedMessages[(messageCounter + i) % receivedMessages.count]

      olderMessages.append(Message(
        text: text,
        isSent: isSent,
        timestamp: timestamp))

      timestamp = timestamp.addingTimeInterval(-60)
    }

    // Prepend older messages
    messages.insert(contentsOf: olderMessages.reversed(), at: 0)
    oldestMessageDate = messages.first?.timestamp ?? Date()
    messageCounter += 10

    applySnapshot()
    isLoadingMore = false
  }

  @objc
  private func sendButtonTapped() {
    let newMessage = Message(
      text: sentMessages.randomElement() ?? "Hello!",
      isSent: true)

    messages.append(newMessage)
    messageCounter += 1

    applySnapshot()
  }

  @objc
  private func receiveButtonTapped() {
    let newMessage = Message(
      text: receivedMessages.randomElement() ?? "Hi there!",
      isSent: false)

    messages.append(newMessage)
    messageCounter += 1

    applySnapshot()
  }
}

// MARK: UICollectionViewDelegate

extension MessageThreadDemoViewController: UICollectionViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top && !isLoadingMore {
      loadOlderMessages()
    }
  }
}

// MARK: UICollectionViewDelegateMagazineLayout

extension MessageThreadDemoViewController: UICollectionViewDelegateMagazineLayout {
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
    12
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
  {
    8
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
    UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
}

// MARK: - Message

private struct Message: Hashable {

  // MARK: Lifecycle

  init(
    id: UUID = UUID(),
    text: String,
    isSent: Bool,
    timestamp: Date = Date())
  {
    self.id = id
    self.text = text
    self.isSent = isSent
    self.timestamp = timestamp
  }

  // MARK: Internal

  let id: UUID
  let text: String
  let isSent: Bool
  let timestamp: Date

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Message, rhs: Message) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - MessageView

private struct MessageView: View {
  let message: Message

  var body: some View {
    HStack {
      if message.isSent {
        Spacer()
      }

      VStack(alignment: message.isSent ? .trailing : .leading, spacing: 4) {
        Text(message.text)
          .font(.body)
          .foregroundColor(.white)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)

        Text(message.timestamp.formatted(date: .omitted, time: .shortened))
          .font(.caption2)
          .foregroundColor(.white.opacity(0.7))
      }
      .padding(12)
      .background(message.isSent ? Color.blue : Color.gray)
      .cornerRadius(16)
      .frame(maxWidth: 280, alignment: message.isSent ? .trailing : .leading)

      if !message.isSent {
        Spacer()
      }
    }
    .frame(maxWidth: .infinity)
  }
}
