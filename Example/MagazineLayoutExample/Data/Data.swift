// Created by bryankeller on 11/30/18.
// Copyright © 2018 Airbnb, Inc.

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
import UIKit

// MARK: - SectionInfo

struct SectionInfo {

  var headerInfo: HeaderInfo
  var itemInfos: [ItemInfo]
  var footerInfo: FooterInfo
  var backgroundInfo: BackgroundInfo

}

// MARK: - HeaderInfo

struct HeaderInfo {

  let visibilityMode: MagazineLayoutHeaderVisibilityMode
  let title: String

}

// MARK: - FooterInfo

struct FooterInfo {

  let visibilityMode: MagazineLayoutFooterVisibilityMode
  let title: String

}

// MARK: - ItemInfo

struct ItemInfo {

  let sizeMode: MagazineLayoutItemSizeMode
  let text: String
  let color: UIColor

}

// MARK: - BackgroundInfo

struct BackgroundInfo {

  let visibilityMode: MagazineLayoutBackgroundVisibilityMode

}
