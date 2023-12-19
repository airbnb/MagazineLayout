// Created by bryankeller on 12/8/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

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

// MARK: - TargetContentOffsetAnchor

/// An internal type for calculating the target content offset for various state of the collection view. Various anchors are possible, each
/// changing how the collection view prioritizes keeping certain items visible in target content offset calculations.
enum TargetContentOffsetAnchor: Equatable {
  case top
  case bottom
  case topItem(id: String, distanceFromTop: CGFloat)
  case bottomItem(id: String, distanceFromBottom: CGFloat)

  static func targetContentOffsetAnchor(
    verticalLayoutDirection: MagazineLayoutVerticalLayoutDirection,
    topInset: CGFloat,
    bottomInset: CGFloat,
    bounds: CGRect,
    contentHeight: CGFloat,
    firstVisibleItemID: String,
    lastVisibleItemID: String,
    firstVisibleItemFrame: CGRect,
    lastVisibleItemFrame: CGRect)
    -> Self
  {
    let position: Position
    if bounds.minY <= -topInset {
      position = .atTop
    } else if bounds.minY >= contentHeight + bottomInset - bounds.height {
      position = .atBottom
    } else {
      position = .inMiddle
    }

    switch verticalLayoutDirection {
    case .topToBottom:
      switch position {
      case .atTop:
        return .top
      case .inMiddle, .atBottom:
        let distanceFromTop = firstVisibleItemFrame.minY - (bounds.minY + topInset)
        return .topItem(id: firstVisibleItemID, distanceFromTop: distanceFromTop)
      }
    case .bottomToTop:
      switch position {
      case .atTop, .inMiddle:
        let distanceFromBottom = lastVisibleItemFrame.maxY - (bounds.maxY - bottomInset)
        return .bottomItem(id: lastVisibleItemID, distanceFromBottom: distanceFromBottom)
      case .atBottom:
        return .bottom
      }
    }
  }

  func yOffset(
    topInset: CGFloat,
    bottomInset: CGFloat,
    bounds: CGRect,
    contentHeight: CGFloat,
    indexPathForItemID: (_ id: String) -> IndexPath?,
    frameForItemAtIndexPath: (_ indexPath: IndexPath) -> CGRect)
    -> CGFloat
  {
    switch self {
    case .top:
      return -topInset

    case .bottom:
      return contentHeight - bounds.height + bottomInset

    case .topItem(let id, let distanceFromTop):
      guard let indexPath = indexPathForItemID(id) else { return bounds.minY }
      let itemFrame = frameForItemAtIndexPath(indexPath)
      return itemFrame.minY - topInset - distanceFromTop

    case .bottomItem(let id, let distanceFromBottom):
      guard let indexPath = indexPathForItemID(id) else { return bounds.minY }
      let itemFrame = frameForItemAtIndexPath(indexPath)
      return itemFrame.maxY - bounds.height + bottomInset - distanceFromBottom
    }
  }

}

// MARK: - Position

private enum Position {
  case atTop
  case inMiddle
  case atBottom
}
