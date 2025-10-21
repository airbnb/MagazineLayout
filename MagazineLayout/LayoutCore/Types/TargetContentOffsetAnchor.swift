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
  case topItem(id: UUID, distanceFromTop: CGFloat)
  case bottomItem(id: UUID, distanceFromBottom: CGFloat)

  static func targetContentOffsetAnchor(
    verticalLayoutDirection: MagazineLayoutVerticalLayoutDirection,
    topInset: CGFloat,
    bottomInset: CGFloat,
    bounds: CGRect,
    contentHeight: CGFloat,
    scale: CGFloat,
    firstVisibleItemID: UUID,
    lastVisibleItemID: UUID,
    firstVisibleItemFrame: CGRect,
    lastVisibleItemFrame: CGRect)
    -> Self
  {
    let top = (-topInset).alignedToPixel(forScreenWithScale: scale)
    let bottom = (contentHeight + bottomInset - bounds.height).alignedToPixel(forScreenWithScale: scale)
    let isAtTop = bounds.minY <= top
    let isAtBottom = bounds.minY >= bottom
    let position: Position
    if isAtTop, isAtBottom {
      switch verticalLayoutDirection {
      case .topToBottom: 
        position = .atTop
      case .bottomToTop: 
        position = .atBottom
      }
    } else if isAtTop {
      position = .atTop
    } else if isAtBottom {
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
        let top = bounds.minY + topInset
        let distanceFromTop = firstVisibleItemFrame.minY - top
        return .topItem(
          id: firstVisibleItemID,
          distanceFromTop: distanceFromTop.alignedToPixel(forScreenWithScale: scale))
      }
    case .bottomToTop:
      switch position {
      case .atTop, .inMiddle:
        let bottom = bounds.maxY - bottomInset
        let distanceFromBottom = lastVisibleItemFrame.maxY - bottom
        return .bottomItem(
          id: lastVisibleItemID,
          distanceFromBottom: distanceFromBottom.alignedToPixel(forScreenWithScale: scale))
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
    indexPathForItemID: (_ id: UUID) -> IndexPath?,
    frameForItemAtIndexPath: (_ indexPath: IndexPath) -> CGRect)
    -> CGFloat
  {
    let minYOffset = -topInset
    let maxYOffset = max(contentHeight - bounds.height + bottomInset, minYOffset)

    switch self {
    case .top:
      return minYOffset

    case .bottom:
      return maxYOffset

    case .topItem(let id, let distanceFromTop):
      guard let indexPath = indexPathForItemID(id) else { return bounds.minY }
      let itemFrame = frameForItemAtIndexPath(indexPath)
      let proposedYOffset = itemFrame.minY - topInset - distanceFromTop
      return min(max(proposedYOffset, minYOffset), maxYOffset) // Clamp between minYOffset...maxYOffset

    case .bottomItem(let id, let distanceFromBottom):
      guard let indexPath = indexPathForItemID(id) else { return bounds.minY }
      let itemFrame = frameForItemAtIndexPath(indexPath)
      let proposedYOffset = itemFrame.maxY - bounds.height + bottomInset - distanceFromBottom
      return min(max(proposedYOffset, minYOffset), maxYOffset) // Clamp between minYOffset...maxYOffset
    }
  }

}

// MARK: - Position

private enum Position {
  case atTop
  case inMiddle
  case atBottom
}
