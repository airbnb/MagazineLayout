// Created by bryankeller on 10/15/18.
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

/// Represents the visibility mode for a background.
public enum MagazineLayoutBackgroundVisibilityMode: Hashable {

  /// This visiblity mode will cause the background to be displayed behind the items and headers in
  /// its respective section.
  case visible

  /// This visibility mode will cause the background to not be visibile behind the items and headers
  /// in its respective section.
  case hidden

}
