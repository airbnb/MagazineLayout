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
  case topItem(id: String, itemEdge: ItemEdge, distanceFromTop: CGFloat)
  case bottomItem(id: String, itemEdge: ItemEdge, distanceFromBottom: CGFloat)

  static func targetContentOffsetAnchor(
    verticalLayoutDirection: MagazineLayoutVerticalLayoutDirection,
    topInset: CGFloat,
    bottomInset: CGFloat,
    bounds: CGRect,
    contentHeight: CGFloat,
    scale: CGFloat,
    firstVisibleItemID: String,
    lastVisibleItemID: String,
    firstVisibleItemFrame: CGRect,
    lastVisibleItemFrame: CGRect)
    -> Self
  {
    let top = (-topInset).alignedToPixel(forScreenWithScale: scale)
    let bottom = (contentHeight + bottomInset - bounds.height).alignedToPixel(forScreenWithScale: scale)
    let position: Position
    if bounds.minY <= top {
      position = .atTop
    } else if bounds.minY >= bottom {
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
        let topDistanceFromTop = firstVisibleItemFrame.value(for: .top) - top
        let bottomDistanceFromTop = firstVisibleItemFrame.value(for: .bottom) - top
        if abs(topDistanceFromTop) < abs(bottomDistanceFromTop) {
          return .topItem(
            id: firstVisibleItemID,
            itemEdge: .top,
            distanceFromTop: topDistanceFromTop.alignedToPixel(forScreenWithScale: scale))
        } else {
          return .topItem(
            id: firstVisibleItemID,
            itemEdge: .bottom,
            distanceFromTop: bottomDistanceFromTop.alignedToPixel(forScreenWithScale: scale))
        }
      }
    case .bottomToTop:
      switch position {
      case .atTop, .inMiddle:
        let bottom = bounds.maxY - bottomInset
        let topDistanceFromBottom = lastVisibleItemFrame.value(for: .top) - bottom
        let bottomDistanceFromBottom = lastVisibleItemFrame.value(for: .bottom) - bottom
        if abs(topDistanceFromBottom) < abs(bottomDistanceFromBottom) {
          return .bottomItem(
            id: lastVisibleItemID,
            itemEdge: .top,
            distanceFromBottom: topDistanceFromBottom.alignedToPixel(forScreenWithScale: scale))
        } else {
          return .bottomItem(
            id: lastVisibleItemID,
            itemEdge: .bottom,
            distanceFromBottom: bottomDistanceFromBottom.alignedToPixel(forScreenWithScale: scale))
        }
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

    case .topItem(let id, let itemEdge, let distanceFromTop):
      guard let indexPath = indexPathForItemID(id) else { return bounds.minY }
      let itemFrame = frameForItemAtIndexPath(indexPath)
      return itemFrame.value(for: itemEdge) - topInset - distanceFromTop

    case .bottomItem(let id, let itemEdge, let distanceFromBottom):
      guard let indexPath = indexPathForItemID(id) else { return bounds.minY }
      let itemFrame = frameForItemAtIndexPath(indexPath)
      return itemFrame.value(for: itemEdge) - bounds.height + bottomInset - distanceFromBottom
    }
  }

}

// MARK: ItemEdge

enum ItemEdge {
  case top
  case bottom
}

// MARK: CGRect + Item Edge Value

private extension CGRect {

  func value(for itemEdge: ItemEdge) -> CGFloat {
    switch itemEdge {
    case .top:
      return minY
    case .bottom:
      return maxY
    }
  }

}

// MARK: - Position

private enum Position {
  case atTop
  case inMiddle
  case atBottom
}
