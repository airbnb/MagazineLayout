// Created by Bryan Keller on 10/31/25.
// Copyright © 2025 Airbnb Inc. All rights reserved.

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

// MARK: - LayoutState

/// Represents the state of the layout, including metrics and the current `ModelState`.
struct LayoutState {

  // MARK: Internal

  let modelState: ModelState

  var bounds: CGRect
  var contentInset: UIEdgeInsets
  var scale: CGFloat
  var verticalLayoutDirection: MagazineLayoutVerticalLayoutDirection

  var minContentOffset: CGPoint {
    CGPoint(x: -contentInset.left, y: -contentInset.top)
  }

  var maxContentOffset: CGPoint {
    let x = contentSize.width - bounds.width + contentInset.right
    let y = contentSize.height - bounds.height + contentInset.bottom
    return CGPoint(x: max(x, minContentOffset.x), y: max(y, minContentOffset.y))
  }

  var contentSize: CGSize {
    // This is a workaround for `layoutAttributesForElementsInRect:` not getting invoked enough
    // times if `collectionViewContentSize.width` is not smaller than the width of the collection
    // view, minus horizontal insets. This results in visual defects when performing batch
    // updates. To work around this, we subtract 0.0001 from our content size width calculation;
    // this small decrease in `collectionViewContentSize.width` is enough to work around the
    // incorrect, internal collection view `CGRect` checks, without introducing any visual
    // differences for elements in the collection view.
    // See https://openradar.appspot.com/radar?id=5025850143539200 for more details.
    let width = bounds.width - contentInset.left - contentInset.right - 0.0001

    let numberOfSections = modelState.numberOfSections
    let height: CGFloat =
      if numberOfSections <= 0 {
        0
      } else {
        modelState.sectionMaxY(forSectionAtIndex: numberOfSections - 1)
      }

    return CGSize(width: width, height: height)
  }

  var targetContentOffsetAnchor: TargetContentOffsetAnchor {
    var visibleItemLocationFramePairs = [ElementLocationFramePair]()
    for itemLocationFramePair in modelState.itemLocationFramePairs(forItemsIn: bounds) {
      // Only consider fully-visible items
      guard bounds.contains(itemLocationFramePair.frame) else { continue }
      visibleItemLocationFramePairs.append(itemLocationFramePair)
    }
    visibleItemLocationFramePairs.sort { $0.elementLocation < $1.elementLocation }

    let firstVisibleItemLocationFramePair = visibleItemLocationFramePairs.first {
      // When scrolling up, only calculate a target content offset based on visible, already-sized
      // cells. Otherwise, scrolling will be jumpy.
      modelState.isItemHeightSettled(indexPath: $0.elementLocation.indexPath)
    } ?? visibleItemLocationFramePairs.first // fallback to the first item if we can't find one with a settled height

    let lastVisibleItemLocationFramePair = visibleItemLocationFramePairs.last {
      // When scrolling down, only calculate a target content offset based on visible, already-sized
      // cells. Otherwise, scrolling will be jumpy.
      modelState.isItemHeightSettled(indexPath: $0.elementLocation.indexPath)
    } ?? visibleItemLocationFramePairs.last // fallback to the last item if we can't find one with a settled height

    guard
      let firstVisibleItemLocationFramePair,
      let lastVisibleItemLocationFramePair,
      let firstVisibleItemID = modelState.idForItemModel(
        at: firstVisibleItemLocationFramePair.elementLocation.indexPath),
      let lastVisibleItemID = modelState.idForItemModel(
        at: lastVisibleItemLocationFramePair.elementLocation.indexPath)
    else {
      switch verticalLayoutDirection {
      case .topToBottom: return .top
      case .bottomToTop: return .bottom
      }
    }

    let top = minContentOffset.y.alignedToPixel(forScreenWithScale: scale)
    let bottom = maxContentOffset.y.alignedToPixel(forScreenWithScale: scale)
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
        let top = bounds.minY + contentInset.top
        let distanceFromTop = firstVisibleItemLocationFramePair.frame.minY - top
        return .topItem(
          id: firstVisibleItemID,
          distanceFromTop: distanceFromTop.alignedToPixel(forScreenWithScale: scale))
      }
    case .bottomToTop:
      switch position {
      case .atTop, .inMiddle:
        let bottom = bounds.maxY - contentInset.bottom
        let distanceFromBottom = lastVisibleItemLocationFramePair.frame.maxY - bottom
        return .bottomItem(
          id: lastVisibleItemID,
          distanceFromBottom: distanceFromBottom.alignedToPixel(forScreenWithScale: scale))
      case .atBottom:
        return .bottom
      }
    }
  }

  func yOffset(for targetContentOffsetAnchor: TargetContentOffsetAnchor) -> CGFloat {
    switch targetContentOffsetAnchor {
    case .top:
      return minContentOffset.y

    case .bottom:
      return maxContentOffset.y

    case .topItem(let id, let distanceFromTop):
      guard let indexPath = modelState.indexPathForItemModel(withID: id) else { return bounds.minY }
      let itemFrame = modelState.frameForItem(at: ElementLocation(indexPath: indexPath))
      let proposedYOffset = itemFrame.minY - contentInset.top - distanceFromTop
      // Clamp between minYOffset...maxYOffset
      return min(max(proposedYOffset, minContentOffset.y), maxContentOffset.y)

    case .bottomItem(let id, let distanceFromBottom):
      guard let indexPath = modelState.indexPathForItemModel(withID: id) else { return bounds.minY }
      let itemFrame = modelState.frameForItem(at: ElementLocation(indexPath: indexPath))
      let proposedYOffset = itemFrame.maxY - bounds.height + contentInset.bottom - distanceFromBottom
      // Clamp between minYOffset...maxYOffset
      return min(max(proposedYOffset, minContentOffset.y), maxContentOffset.y)
    }
  }
}

// MARK: - Position

private enum Position {
  case atTop
  case inMiddle
  case atBottom
}
