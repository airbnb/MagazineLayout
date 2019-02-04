// Created by Roman Laitarenko on 31/01/2019.
// Copyright © 2019 Sanoma.

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

import Foundation
import CoreGraphics

/// Represents the layout information for a footer in a section.
struct FooterModel {

    // MARK: Lifecycle

    init(heightMode: MagazineLayoutSupplementaryViewHeightMode, height: CGFloat) {
        self.heightMode = heightMode
        originInSection = .zero
        size = CGSize(width: 0, height: height)
    }

    // MARK: Internal

    var heightMode: MagazineLayoutSupplementaryViewHeightMode
    var originInSection: CGPoint
    var size: CGSize
    var preferredHeight: CGFloat?
}
